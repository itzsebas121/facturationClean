import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;
  // Map para almacenar el conteo real de productos por OrderId
  final Map<String, int> _productCounts = {};
  // Flag para controlar si el widget está siendo destruido
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
  Future<void> _loadOrderHistory() async {
    if (_isDisposed) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });      

    try {
      final orders = await CartService.getOrderHistory();
      
      if (!_isDisposed && mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        
        // Cargar conteos de productos de manera asíncrona (sin bloquear la UI)
        _loadProductCountsAsync();
      }
      
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Historial de Órdenes',
          style: TextStyle(
            color: AppColors.backgroundLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.backgroundLight,
            ),
            onPressed: _loadOrderHistory,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _orders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrdersList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Error al cargar el historial',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!.replaceAll('Exception: ', ''),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrderHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.backgroundLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes órdenes aún',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus compras aparecerán aquí cuando realices tu primera orden',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Ir de Compras'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.backgroundLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order, index);
      },
    );
  }
  Widget _buildOrderCard(dynamic order, int index) {
    final orderId = order['OrderId'] ?? order['orderId'] ?? order['id'] ?? (index + 1);
    final date = order['OrderDate'] ?? order['orderDate'] ?? order['CreatedAt'] ?? order['createdAt'] ?? order['date'];
    final total = order['Total'] ?? order['total'] ?? order['amount'] ?? 0;
    final status = order['Status'] ?? order['status'] ?? 'Completada';
    final itemCount = _getOrderItemCount(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: AppColors.backgroundLight,
        elevation: 3,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _navigateToOrderDetail(order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con número de orden y fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Orden #$orderId',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(date),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.accentColor,
                      size: 28,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Información de la orden
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Solo mostrar conteo de productos si es mayor que 0
                            if (itemCount > 0) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$itemCount productos',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.backgroundLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '\$${_formatPrice(total)}',
                              style: TextStyle(
                                color: AppColors.backgroundLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Botón para ver detalles
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _navigateToOrderDetail(order),
                    icon: Icon(
                      Icons.visibility,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      'Ver Detalles',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOrderDetail(dynamic order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
  }  int _getOrderItemCount(dynamic order) {
    final orderId = (order['OrderId'] ?? order['orderId'] ?? order['id'])?.toString();
    
    // Si ya tenemos el conteo real cargado asincrónamente, usarlo
    if (orderId != null && _productCounts.containsKey(orderId)) {
      return _productCounts[orderId]!;
    }
    
    // Primero intentar buscar un campo directo de conteo de productos
    final directCount = order['ProductCount'] ?? order['productCount'] ?? order['ItemCount'] ?? order['itemCount'];
    if (directCount != null && directCount is num && directCount > 0) {
      return directCount.toInt();
    }
    
    // Si hay una lista de items, contar desde ahí
    final items = order['Items'] ?? order['items'] ?? order['products'] ?? [];
    if (items is List && items.isNotEmpty) {
      return items.fold<int>(0, (sum, item) {
        final quantity = item['Quantity'] ?? item['quantity'] ?? 1;
        return sum + (quantity as int);
      });
    }
    
    // Si no hay datos de productos disponibles en el historial, 
    // no mostrar el conteo en lugar de mostrar un valor incorrecto
    return 0; // Esto hará que se oculte el campo en la UI
  }
  /// Carga los conteos de productos de manera asíncrona para todas las órdenes
  Future<void> _loadProductCountsAsync() async {
    if (_isDisposed) return;
    
    for (final order in _orders) {
      if (_isDisposed) break; // Salir del loop si el widget está siendo destruido
      
      final orderId = (order['OrderId'] ?? order['orderId'] ?? order['id'])?.toString();
      if (orderId != null && orderId != 'N/A') {
        // No esperar (usar unawaited) para que sea realmente asíncrono
        _loadProductCountForOrder(orderId);
      }
    }
  }

  /// Carga el conteo real de productos para una orden específica
  Future<void> _loadProductCountForOrder(String orderId) async {
    try {
      final details = await CartService.getOrderDetails(int.parse(orderId));
      final items = details['Items'] ?? [];
      
      if (items is List) {
        final count = items.fold<int>(0, (sum, item) {
          final quantity = item['Quantity'] ?? item['quantity'] ?? 1;
          return sum + (quantity as int);
        });
        
        // Verificar múltiples condiciones antes de llamar setState
        if (!_isDisposed && mounted && count > 0) {
          setState(() {
            _productCounts[orderId] = count;
          });
        }
      }
    } catch (e) {
      // Solo mantener logs para errores críticos, no para debug
      // print('Error al cargar conteo de productos para orden $orderId: $e');
      // No actualizar el state en caso de error, mantener el valor por defecto
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      if (date is String) {
        final dateTime = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
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
