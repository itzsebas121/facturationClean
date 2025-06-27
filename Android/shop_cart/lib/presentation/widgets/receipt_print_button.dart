import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/client_service.dart';
import '../../models/client.dart';

class ReceiptPrintButton extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const ReceiptPrintButton({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      child: ElevatedButton.icon(
        onPressed: () => _generateAndPrintReceipt(context),
        icon: const Icon(Icons.print, size: 20),
        label: const Text('Imprimir Recibo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.backgroundLight,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _generateAndPrintReceipt(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Obtener datos del cliente
      final client = await ClientService.getCurrentClient();
      
      // Generar PDF
      final pdf = await _generateReceiptPDF(client);
      
      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (format) async => pdf.save(),
        );
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar recibo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generateReceiptPDF(Client? client) async {
    final pdf = pw.Document();
    
    // Extraer datos de la orden
    final orderId = _getOrderId();
    final orderDate = _getOrderDate();
    final orderStatus = _getOrderStatus();
    final items = _getOrderItems();
    final subtotal = _getOrderSubtotal();
    final tax = _getOrderTax();
    final total = _getOrderTotal();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'RECIBO DE COMPRA',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'ShopCart',
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 32),
              
              // Información del cliente
              if (client != null) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
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
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Nombre:'),
                          pw.Text('${client.firstName} ${client.lastName}'),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Cédula:'),
                          pw.Text(client.cedula),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Email:'),
                          pw.Text(client.email),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Teléfono:'),
                          pw.Text(client.phone),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('Dirección: ${client.address}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],
              
              // Información de la orden
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
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
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Número de Orden:'),
                        pw.Text('#$orderId'),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Fecha:'),
                        pw.Text(_formatDate(orderDate)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Estado:'),
                        pw.Text(orderStatus),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 24),
              
              // Lista de productos
              pw.Text(
                'Productos',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              
              // Tabla de productos
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Producto',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Cantidad',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Precio',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Productos
                  ...items.map((item) {
                    final name = item['Name'] ?? item['name'] ?? item['productName'] ?? 'Producto';
                    final quantity = item['Quantity'] ?? item['quantity'] ?? 1;
                    final price = item['Price'] ?? item['price'] ?? item['unitPrice'] ?? 0;
                    final itemTotal = item['Total'] ?? item['total'] ?? (quantity * price);
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(name.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            quantity.toString(),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '\$${_formatPrice(price)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '\$${_formatPrice(itemTotal)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              
              pw.SizedBox(height: 24),
              
              // Resumen de totales
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Subtotal:'),
                        pw.Text('\$${_formatPrice(subtotal)}'),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Impuestos:'),
                        pw.Text('\$${_formatPrice(tax)}'),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total:',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '\$${_formatPrice(total)}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Gracias por su compra',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Helper methods para extraer datos de la orden
  String _getOrderId() {
    return (orderData['OrderId'] ?? orderData['orderId'] ?? orderData['id'] ?? 'N/A').toString();
  }

  String _getOrderDate() {
    return orderData['OrderDate'] ?? orderData['orderDate'] ?? orderData['CreatedAt'] ?? orderData['createdAt'] ?? orderData['date'] ?? '';
  }

  String _getOrderStatus() {
    return orderData['Status'] ?? orderData['status'] ?? 'Completada';
  }

  dynamic _getOrderTotal() {
    return orderData['Total'] ?? orderData['total'] ?? orderData['amount'] ?? 0;
  }

  dynamic _getOrderSubtotal() {
    return orderData['Subtotal'] ?? orderData['subtotal'] ?? _getOrderTotal();
  }

  dynamic _getOrderTax() {
    return orderData['Tax'] ?? orderData['tax'] ?? 0;
  }

  List<dynamic> _getOrderItems() {
    return orderData['Items'] ?? orderData['items'] ?? orderData['products'] ?? [];
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    try {
      final numPrice = price is num ? price : double.parse(price.toString());
      return numPrice.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }
}
