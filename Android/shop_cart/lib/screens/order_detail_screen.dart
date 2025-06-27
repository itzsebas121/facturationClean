import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/cart_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final dynamic order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });    try {
      final orderId = _getOrderId();
      if (orderId.isNotEmpty && orderId != 'N/A') {
        final details = await CartService.getOrderDetails(int.parse(orderId));
        setState(() {
          _orderDetails = details;
          _isLoading = false;
        });
      } else {
        // Si no hay orderId válido, usar los datos básicos de la orden
        setState(() {
          _orderDetails = Map<String, dynamic>.from(widget.order);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar detalles de orden: $e');
      setState(() {
        _error = e.toString();
        // En caso de error, usar los datos básicos que tenemos
        _orderDetails = Map<String, dynamic>.from(widget.order);
        _isLoading = false;
      });
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Detalle de Orden #${_getOrderId()}',
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar los detalles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrderDetails,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con información principal
                      _buildOrderHeader(),
                      const SizedBox(height: 24),

                      // Información de la orden
                      _buildOrderInfo(),
                      const SizedBox(height: 24),

                      // Lista de productos
                      _buildProductsList(),
                      const SizedBox(height: 24),

                      // Resumen de totales
                      _buildOrderSummary(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.accentColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.backgroundLight,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orden #${_getOrderId()}',
                      style: TextStyle(
                        color: AppColors.backgroundLight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(_getOrderDate()),
                      style: TextStyle(
                        color: AppColors.backgroundLight.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getOrderStatus(),
              style: TextStyle(
                color: AppColors.backgroundLight,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de la Orden',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Fecha de Orden',
                value: _formatFullDate(_getOrderDate()),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.info_outline,
                label: 'Estado',
                value: _getOrderStatus(),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.shopping_cart,
                label: 'Total de Productos',
                value: '${_getProductCount()} items',
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.attach_money,
                label: 'Total Pagado',
                value: '\$${_formatPrice(_getOrderTotal())}',
                valueColor: AppColors.accentColor,
                valueWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: valueWeight ?? FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    final products = _getOrderItems();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos Ordenados',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay productos en esta orden',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.borderColor,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductItem(product);
                  },
                ),
        ),
      ],
    );
  }
  Widget _buildProductItem(dynamic product) {
    final name = product['Name'] ?? product['name'] ?? product['productName'] ?? 'Producto';
    final quantity = product['Quantity'] ?? product['quantity'] ?? 1;
    final price = product['UnitPrice'] ?? product['Price'] ?? product['price'] ?? product['unitPrice'] ?? 0;
    final total = product['SubTotal'] ?? product['Total'] ?? product['total'] ?? (quantity * price);
    final imageUrl = product['ImageUrl'] ?? product['imageUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: $quantity',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (price > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Precio unitario: \$${_formatPrice(price)}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentColor.withOpacity(0.3)),
            ),
            child: Text(
              '\$${_formatPrice(total)}',
              style: TextStyle(
                color: AppColors.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = _getOrderSubtotal();
    final tax = _getOrderTax();
    final total = _getOrderTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de Pago',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal:', '\$${_formatPrice(subtotal)}'),
              const SizedBox(height: 12),
              _buildSummaryRow('Impuestos:', '\$${_formatPrice(tax)}'),
              const Divider(height: 24),
              _buildSummaryRow(
                'Total:',
                '\$${_formatPrice(total)}',
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.accentColor : AppColors.textPrimary,
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }  // Helper methods para extraer datos de la orden
  String _getOrderId() {
    // Priorizar el ID de la orden original del historial
    final originalOrder = widget.order;
    final orderId = (originalOrder['OrderId'] ?? originalOrder['orderId'] ?? originalOrder['id'] ?? 'N/A').toString();
    return orderId != 'N/A' ? orderId : (_orderDetails?['OrderId'] ?? _orderDetails?['orderId'] ?? _orderDetails?['id'] ?? 'N/A').toString();
  }String _getOrderDate() {
    // Priorizar la fecha de la orden original (del historial) sobre los detalles cargados
    final originalOrder = widget.order;
    final detailsOrder = _orderDetails;
    
    // Primero intentar con la orden original del historial
    String dateFromOriginal = originalOrder['OrderDate'] ?? originalOrder['orderDate'] ?? originalOrder['CreatedAt'] ?? originalOrder['createdAt'] ?? originalOrder['date'] ?? '';
    
    // Si no hay fecha en la orden original, usar la de los detalles
    if (dateFromOriginal.isNotEmpty) {
      return dateFromOriginal;
    }
    
    // Fallback a los detalles cargados si no hay fecha en la orden original
    return detailsOrder?['OrderDate'] ?? detailsOrder?['orderDate'] ?? detailsOrder?['CreatedAt'] ?? detailsOrder?['createdAt'] ?? detailsOrder?['date'] ?? '';
  }
  String _getOrderStatus() {
    // Priorizar el estado de la orden original del historial
    final originalOrder = widget.order;
    final status = originalOrder['Status'] ?? originalOrder['status'] ?? '';
    return status.isNotEmpty ? status : (_orderDetails?['Status'] ?? _orderDetails?['status'] ?? 'Completada');
  }
  dynamic _getOrderTotal() {
    // Priorizar el total de la orden original del historial
    final originalOrder = widget.order;
    final originalTotal = originalOrder['Total'] ?? originalOrder['total'] ?? originalOrder['amount'];
    
    if (originalTotal != null && originalTotal != 0) {
      return originalTotal;
    }
    
    // Fallback a los detalles cargados
    return _orderDetails?['Total'] ?? _orderDetails?['total'] ?? _orderDetails?['amount'] ?? 0;
  }

  dynamic _getOrderSubtotal() {
    final order = _orderDetails ?? widget.order;
    return order['SubTotal'] ?? order['Subtotal'] ?? order['subtotal'] ?? _getOrderTotal();
  }

  dynamic _getOrderTax() {
    final order = _orderDetails ?? widget.order;
    return order['Tax'] ?? order['tax'] ?? 0;
  }

  List<dynamic> _getOrderItems() {
    final order = _orderDetails ?? widget.order;
    return order['Items'] ?? order['items'] ?? order['products'] ?? [];
  }
  int _getProductCount() {
    final items = _getOrderItems();
    return items.fold<int>(0, (sum, item) {
      final quantity = item['Quantity'] ?? item['quantity'] ?? 1;
      return sum + (quantity as int);
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatFullDate(String? dateStr) {
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
