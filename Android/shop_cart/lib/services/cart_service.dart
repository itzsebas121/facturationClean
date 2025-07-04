import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'client_service.dart';
import 'user_service.dart';
import 'product_service.dart';

class CartService {
  static const String _baseUrl =
      'https://facturationclean.vercel.app/api/carts';

  // Variable para guardar la URL del endpoint que funciona
  static String? _workingOrdersEndpoint;

  // Variable para rastrear si se necesita un carrito nuevo
  static bool _needsNewCart = false;
  static Future<List<CartItem>> getCartItems() async {
    try {
      final clientId = await ClientService.getClientId();
      final response = await http.get(Uri.parse('$_baseUrl/$clientId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Crear un mapa para obtener todos los productos necesarios
        Set<int> productIds =
            data.map((item) => item['ProductId'] as int).toSet();

        // Obtener información completa de productos (incluyendo stock)
        Map<int, Product> productsMap = {};
        try {
          // Obtener todos los productos para obtener el stock real
          final productPage = await ProductService.fetchProducts(
            pageSize: 1000, // Usar pageSize en lugar de limit
          ); // Obtener muchos productos
          for (Product product in productPage.products) {
            if (productIds.contains(product.productId)) {
              productsMap[product.productId] = product;
            }
          }
        } catch (e) {
          // Continuar sin stock si falla
        }

        return data.map((item) {
          final productId = item['ProductId'] as int;
          final productFromService = productsMap[productId];

          return CartItem(
            cartId: item['CartId'],
            cartItemId: item['CartItemId'],
            product: Product(
              productId: productId,
              categoryId: productFromService?.categoryId ?? 0,
              name: item['Name'],
              description: productFromService?.description ?? '',
              price: (item['UnitPrice'] as num).toDouble(),
              stock:
                  productFromService?.stock ??
                  0, // ✅ Usar stock real del servicio de productos
              imageUrl: item['ImageUrl'] ?? '',
            ),
            quantity: item['Quantity'] ?? 1,
          );
        }).toList();
      } else if (response.statusCode == 404) {
        // No hay carrito para este cliente, es normal
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> addToCart({
    required Product product,
    int quantity = 1,
  }) async {
    try {
      final clientId = await ClientService.getClientId();

      // Intentar obtener items del carrito actual
      final existingItems = await getCartItems();

      // Si hay items existentes, verificar si el producto ya existe
      if (existingItems.isNotEmpty) {
        final existingItem =
            existingItems
                .where((item) => item.product.productId == product.productId)
                .firstOrNull;
        if (existingItem != null) {
          // El producto ya existe, intentar actualizar cantidad
          try {
            await updateCartItem(
              cartId: existingItem.cartId!,
              productId: product.productId,
              quantity: existingItem.quantity + quantity,
            );
            return;
          } catch (e) {
            // Si falla la actualización, crear un carrito nuevo
          }
        }
      }

      // Crear nuevo item en carrito (POST siempre crea o usa carrito activo)
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clientId': clientId,
          'productId': product.productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _needsNewCart = false; // Reset flag después de operación exitosa
      } else {
        throw Exception(
          'Error al agregar producto al carrito: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error al agregar producto al carrito: $e');
    }
  }

  static Future<void> updateCartItem({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cartID': cartId,
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = response.body;

        if (errorBody.contains('carrito no existe') ||
            errorBody.contains('ya fue procesado')) {
          // El carrito fue procesado, marcar que necesitamos uno nuevo
          _needsNewCart = true;
          throw Exception(
            'El carrito ya fue procesado. Se creará uno nuevo en la próxima compra.',
          );
        }
        throw Exception('Error al actualizar carrito: $errorBody');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeFromCart({
    required int cartId,
    required int productId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$cartId/$productId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Success - product removed
      } else if (response.statusCode == 404) {
        final responseData = json.decode(response.body);
        if (responseData['Error'] != null) {
          throw Exception(responseData['Error']);
        }
        throw Exception('El producto no existe en el carrito');
      } else {
        final errorBody = response.body;
        throw Exception('Error al eliminar producto del carrito: $errorBody');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearCart() async {
    // Método para limpiar el carrito manualmente si es necesario
    try {
      final cartItems = await getCartItems();
      if (cartItems.isEmpty) {
        return;
      }

      // Si hay items, intentar eliminarlos uno por uno
      for (final item in cartItems) {
        await updateCartItem(
          cartId: item.cartId!,
          productId: item.product.productId,
          quantity: 0,
        );
      }
    } catch (e) {
      // Error al limpiar carrito
    }
  } // Método para confirmar compra (convertir carrito a orden)

  static Future<void> confirmCart() async {
    // Obtener items del carrito para obtener el cartId
    final cartItems = await getCartItems();
    if (cartItems.isEmpty) {
      throw Exception('No hay items en el carrito para confirmar');
    }

    final cartId = cartItems.first.cartId;

    final response = await http.post(
      Uri.parse('$_baseUrl/convert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cartID': cartId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(
        error['error'] ?? 'Error al convertir el carrito a orden.',
      );
    }

    // Marcar que se necesita un carrito nuevo para la próxima compra
    markCartAsCompleted();

    // El carrito se limpia automáticamente en el backend después de convertir a orden
  } // Método para obtener historial de compras/órdenes

  static Future<List<dynamic>> getOrderHistory() async {
    try {
      // Obtener token de autenticación y clientId
      final token = await UserService.getToken();
      final clientId = await ClientService.getClientId();

      print('=== getOrderHistory DEBUG ===');
      print('Token presente: ${token != null}');
      print('ClientId: $clientId');

      if (clientId == null) {
        print('ClientId es null, devolviendo lista vacía');
        return [];
      }

      if (token == null) {
        print('Token es null, devolviendo lista vacía');
        return [];
      }

      // Headers de autenticación
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Si ya sabemos qué endpoint funciona, verificar que es para el cliente correcto
      if (_workingOrdersEndpoint != null) {
        print('Verificando endpoint guardado: $_workingOrdersEndpoint para cliente: $clientId');
        
        // Verificar que el endpoint guardado es para el cliente actual
        final isForCurrentClient = _workingOrdersEndpoint!.contains('clientId=$clientId') || 
                                    _workingOrdersEndpoint!.endsWith('/$clientId');
        
        print('¿Endpoint es para cliente actual? $isForCurrentClient');
        
        if (!isForCurrentClient) {
          print('Endpoint conocido es para otro cliente, reseteando: $_workingOrdersEndpoint');
          _workingOrdersEndpoint = null; // Reset porque es para otro cliente
        } else {
          print('Intentando con endpoint conocido: $_workingOrdersEndpoint');
          final response = await http.get(
            Uri.parse(_workingOrdersEndpoint!),
            headers: headers,
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Respuesta exitosa del endpoint conocido: ${data.runtimeType}');
            
            List<dynamic> orders = [];
            if (data is List) {
              orders = data;
            } else if (data is Map && data['orders'] != null) {
              orders = data['orders'] as List;
            } else if (data is Map && data['data'] != null) {
              orders = data['data'] as List;
            }
            
            // Filtrar órdenes para asegurar que pertenecen al cliente actual
            final filteredOrders = orders.where((order) {
              final orderClientId = order['ClientId']?.toString() ?? 
                                   order['clientId']?.toString() ?? 
                                   order['client_id']?.toString();
              return orderClientId == clientId.toString();
            }).toList();
            
            print('Órdenes filtradas: ${filteredOrders.length} de ${orders.length}');
            return filteredOrders;
          } else {
            print('Endpoint conocido falló con código: ${response.statusCode}');
            _workingOrdersEndpoint = null; // Reset
          }
        }
      }

      // Intentar diferentes endpoints posibles con autenticación
      final possibleUrls = [
        'https://facturationclean.vercel.app/api/orders?clientId=$clientId', // query parameter con filtro
        'https://facturationclean.vercel.app/api/client/$clientId/orders',
        'https://facturationclean.vercel.app/api/clients/$clientId/orders',
        'https://facturationclean.vercel.app/api/order/$clientId', // singular
        'https://facturationclean.vercel.app/api/orders/$clientId', // original
      ];
      
      for (String url in possibleUrls) {
        print('Intentando endpoint: $url');
        try {
          final response = await http.get(
            Uri.parse(url),
            headers: headers,
          );

          print('Respuesta del endpoint $url: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Datos recibidos tipo: ${data.runtimeType}');
            
            List<dynamic> orders = [];
            if (data is List) {
              orders = data;
            } else if (data is Map && data['orders'] != null) {
              orders = data['orders'] as List;
            } else if (data is Map && data['data'] != null) {
              orders = data['data'] as List;
            }
            
            if (orders.isNotEmpty) {
              // Filtrar órdenes para asegurar que pertenecen al cliente actual
              final filteredOrders = orders.where((order) {
                final orderClientId = order['ClientId']?.toString() ?? 
                                     order['clientId']?.toString() ?? 
                                     order['client_id']?.toString();
                return orderClientId == clientId.toString();
              }).toList();
              
              print('Órdenes filtradas: ${filteredOrders.length} de ${orders.length}');
              
              if (filteredOrders.isNotEmpty) {
                // Guardar el endpoint que funciona específicamente para este cliente
                _workingOrdersEndpoint = url;
                print('Guardando endpoint exitoso para cliente $clientId: $url');
                return filteredOrders;
              } else {
                print('Endpoint $url no devolvió órdenes para cliente $clientId');
              }
            }
          }
        } catch (e) {
          print('Error en endpoint $url: $e');
          continue;
        }
      }

      print('Ningún endpoint devolvió órdenes válidas');
      return [];
    } catch (e) {
      print('Error general en getOrderHistory: $e');
      return [];
    }
  }

  // Método para marcar que se necesita un carrito nuevo
  static void markCartAsCompleted() {
    _needsNewCart = true;
  }

  // Método para resetear el endpoint de órdenes (útil al cambiar de usuario)
  static void resetOrdersEndpoint() {
    _workingOrdersEndpoint = null;
  }

  // Método para verificar si se necesita un carrito nuevo
  static bool needsNewCart() {
    return _needsNewCart;
  } // Método para resetear el flag de carrito nuevo

  static void resetCartFlag() {
    _needsNewCart = false;
  }

  /// Obtiene los detalles de una orden específica desde el endpoint de órdenes
  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final clientId = await ClientService.getClientId();
      if (clientId == null) {
        throw Exception('Client ID no disponible');
      }

      // Primera llamada: obtener detalles de la orden (items, etc.)
      final detailsResponse = await http.get(
        Uri.parse('https://facturationclean.vercel.app/api/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Segunda llamada: obtener impuestos específicamente
      final taxResponse = await http.get(
        Uri.parse('https://facturationclean.vercel.app/api/orders?clientId=$clientId/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (detailsResponse.statusCode == 200) {
        final orderDetailsList = json.decode(detailsResponse.body) as List;

        if (orderDetailsList.isNotEmpty) {
          // Obtener datos básicos del primer endpoint
          double subtotal = 0.0;
          double tax = 0.0;
          double total = 0.0;

          // Calcular subtotal desde los items
          for (var item in orderDetailsList) {
            subtotal += (item['SubTotal'] ?? 0.0).toDouble();
          }

          // Obtener impuesto del segundo endpoint si está disponible
          if (taxResponse.statusCode == 200) {
            try {
              final taxData = json.decode(taxResponse.body);
              if (taxData is List && taxData.isNotEmpty) {
                tax = (taxData.first['Tax'] ?? 0.0).toDouble();
                total = (taxData.first['Total'] ?? subtotal + tax).toDouble();
              } else if (taxData is Map) {
                tax = (taxData['Tax'] ?? 0.0).toDouble();
                total = (taxData['Total'] ?? subtotal + tax).toDouble();
              }
            } catch (e) {
              // Si falla la obtención del impuesto, usar valores por defecto
              tax = 0.0;
              total = subtotal;
            }
          } else {
            // Si no se puede obtener el impuesto, usar subtotal como total
            total = subtotal;
          }
          
          // Construir objeto de orden con los detalles
          final orderDetails = {
            'OrderId': orderId,
            'Items': orderDetailsList,
            'Total': total,
            'SubTotal': subtotal,
            'Tax': tax,
            'Status': 'Completada',
            'ProductCount': orderDetailsList.length,
            // Intentar obtener la fecha desde los items si está disponible
            'OrderDate': orderDetailsList.isNotEmpty ? 
              (orderDetailsList.first['OrderDate'] ?? 
               orderDetailsList.first['CreatedAt'] ?? 
               orderDetailsList.first['created_at'] ?? 
               DateTime.now().toIso8601String()) : 
              DateTime.now().toIso8601String(),
          };

          return orderDetails;
        } else {
          throw Exception('No se encontraron detalles para esta orden');
        }
      } else if (detailsResponse.statusCode == 404) {
        throw Exception('Orden no encontrada');
      } else {
        throw Exception('Error del servidor: ${detailsResponse.statusCode}');
      }
    } catch (e) {
      // En caso de error, devolver datos básicos para que la app no falle
      return {
        'OrderId': orderId,
        'Message': 'No se pudieron cargar los detalles completos',
        'Items': [],
        'Total': 0.0,
        'SubTotal': 0.0,
        'Tax': 0.0,
        'Status': 'Error',
        'ProductCount': 0,
        'OrderDate': DateTime.now().toIso8601String(),
      };
    }
  }

  // Método para imprimir recibo usando el servicio de impresión nativo
  static Future<bool> printReceipt(int orderId) async {
    try {
      // Obtener los detalles de la orden y los datos del cliente
      final orderDetails = await getOrderDetails(orderId);
      final clientData = await ClientService.getCurrentClient();
      
      if (orderDetails['Items'] == null || orderDetails['Items'].isEmpty) {
        throw Exception('No se encontraron items en la orden');
      }
      
      // Crear el documento PDF
      final pdf = pw.Document();
      
      // Agregar página al PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RECIBO DE ORDEN',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Orden #${orderDetails['OrderId']}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Información del cliente
                _buildClientInfoSection(clientData),
                
                pw.SizedBox(height: 20),
                
                // Información de la orden
                _buildOrderInfoSection(orderDetails),
                
                pw.SizedBox(height: 20),
                
                // Tabla de productos
                _buildProductsTable(orderDetails['Items']),
                
                pw.SizedBox(height: 20),
                
                // Totales
                _buildTotalsSection(orderDetails),
                
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Gracias por su compra',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Documento generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Enviar al servicio de impresión nativo
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Recibo_Orden_$orderId',
        format: PdfPageFormat.a4,
      );
      
      return true;
      
    } catch (e) {
      throw Exception('Error al preparar el documento para impresión: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  static Future<bool> generatePdf(int orderId) async {
    try {
      // Obtener los detalles de la orden y los datos del cliente
      final orderDetails = await getOrderDetails(orderId);
      final clientData = await ClientService.getCurrentClient();
      
      if (orderDetails['Items'] == null || orderDetails['Items'].isEmpty) {
        throw Exception('No se encontraron items en la orden');
      }
      
      // Crear el documento PDF
      final pdf = pw.Document();
      
      // Agregar página al PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FACTURA / RECIBO',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Orden #${orderDetails['OrderId']}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Información del cliente
                _buildClientInfoSection(clientData),
                
                pw.SizedBox(height: 20),
                
                // Información de la orden
                _buildOrderInfoSection(orderDetails),
                
                pw.SizedBox(height: 20),
                
                // Tabla de productos
                _buildProductsTable(orderDetails['Items']),
                
                pw.SizedBox(height: 20),
                
                // Totales
                _buildTotalsSection(orderDetails),
                
                pw.Spacer(),
                
                // Footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Gracias por su compra',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Documento generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      // Guardar el PDF
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/orden_${orderId}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return true;
      
    } catch (e) {
      throw Exception('Error al generar PDF: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
  
  static pw.Widget _buildOrderInfoSection(Map<String, dynamic> orderDetails) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Información de la Orden',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Número de Orden:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${orderDetails['OrderId']}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Fecha:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(_formatDate(orderDetails['OrderDate'])),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Estado:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${orderDetails['Status']}'),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildProductsTable(List<dynamic> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Producto - más espacio
        1: const pw.FlexColumnWidth(1), // Cantidad
        2: const pw.FlexColumnWidth(1.5), // Precio Unit.
        3: const pw.FlexColumnWidth(1.5), // Subtotal
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Producto', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Precio Unit.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Subtotal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ),
          ],
        ),
        // Items
        ...items.map((item) => pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('${item['ProductName'] ?? item['Name'] ?? 'Producto'}'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('${item['Quantity'] ?? 1}', textAlign: pw.TextAlign.center),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('\$${(item['UnitPrice'] ?? 0.0).toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('\$${(item['SubTotal'] ?? 0.0).toStringAsFixed(2)}', textAlign: pw.TextAlign.right),
            ),
          ],
        )).toList(),
      ],
    );
  }
  
  static pw.Widget _buildTotalsSection(Map<String, dynamic> orderDetails) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 14)),
              pw.Text('\$${(orderDetails['SubTotal'] ?? 0.0).toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 14), textAlign: pw.TextAlign.right),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Impuestos:', style: pw.TextStyle(fontSize: 14)),
              pw.Text('\$${(orderDetails['Tax'] ?? 0.0).toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 14), textAlign: pw.TextAlign.right),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('\$${(orderDetails['Total'] ?? 0.0).toStringAsFixed(2)}', 
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ],
          ),
        ],
      ),
    );
  }
  
  static String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  static pw.Widget _buildClientInfoSection(dynamic clientData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Información del Cliente',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Nombre:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${clientData?.firstName ?? 'N/A'} ${clientData?.lastName ?? ''}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Email:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${clientData?.email ?? 'N/A'}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Teléfono:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${clientData?.phone ?? 'N/A'}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Dirección:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Expanded(
                child: pw.Text(
                  '${clientData?.address ?? 'N/A'}',
                  textAlign: pw.TextAlign.right,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          if (clientData?.cedula != null && clientData?.cedula != 'No disponible')
            pw.Column(
              children: [
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Cédula:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('${clientData?.cedula}'),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
