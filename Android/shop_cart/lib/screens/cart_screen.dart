import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;  final void Function(Product) onRemove;
  final Future<String?> Function(Product) onIncrease;
  final Future<String?> Function(Product) onDecrease;
  final VoidCallback onClearCart;
  final Future<void> Function() onReloadCart;
  
  const CartScreen({
    Key? key,
    required this.cartItems,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
    required this.onClearCart,
    required this.onReloadCart,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Map para manejar los controladores de texto de cada item
  final Map<int, TextEditingController> _quantityControllers = {};
  
  // Variable para forzar reconstrucción del widget
  int _rebuildKey = 0;
  
  // Estados para mejorar la experiencia del usuario
  bool _isLoading = false;
  bool _isUpdating = false;
  final Set<int> _updatingItems = {}; // Track items being updated
  
  // Cache para optimizar renders
  double? _cachedTotal;
  List<CartItem>? _cachedItems;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _cacheCurrentState();
    
    // Recargar datos en segundo plano después de mostrar la UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCartInBackground();
    });
  }
  
  @override
  void didUpdateWidget(CartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verificar cambios de forma eficiente
    bool shouldUpdate = false;
    
    if (oldWidget.cartItems.length != widget.cartItems.length) {
      shouldUpdate = true;
    } else {
      // Verificar si alguna cantidad cambió de forma optimizada
      for (int i = 0; i < widget.cartItems.length; i++) {
        final newItem = widget.cartItems[i];
        final oldItem = oldWidget.cartItems.firstWhere(
          (item) => item.product.productId == newItem.product.productId,
          orElse: () => newItem,
        );
        if (oldItem.quantity != newItem.quantity) {
          shouldUpdate = true;
          break;
        }
      }
    }
    
    if (shouldUpdate) {
      _initializeControllers();
      _cacheCurrentState();
      setState(() {
        _rebuildKey++;
      });
    }
  }
  void _initializeControllers() {
    // Limpiar controladores existentes
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    _quantityControllers.clear();
    
    // Crear controladores para cada item del carrito de forma eficiente
    for (var item in widget.cartItems) {
      _quantityControllers[item.product.productId] = TextEditingController(
        text: item.quantity.toString(),
      );
    }
  }
  
  @override
  void dispose() {
    // Limpiar todos los controladores
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Refresca el carrito en segundo plano sin bloquear la UI
  Future<void> _refreshCartInBackground() async {
    try {
      // Pequeño delay para asegurar que la UI se haya renderizado
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        await widget.onReloadCart();
        if (mounted) {
          _cacheCurrentState();
        }
      }
    } catch (e) {
      // Error silencioso, no bloquear la UI
      print('Error al refrescar carrito en segundo plano: $e');
    }
  }

  /// Método para cachear el estado actual y evitar recálculos innecesarios
  void _cacheCurrentState() {
    _cachedItems = List.from(widget.cartItems);
    _cachedTotal = _calculateTotal();
  }
  
  /// Cálculo optimizado del total
  double _calculateTotal() {
    if (_cachedItems != null && _cachedItems!.length == widget.cartItems.length) {
      // Verificar si los items han cambiado
      bool itemsChanged = false;
      for (int i = 0; i < widget.cartItems.length; i++) {
        if (_cachedItems![i].quantity != widget.cartItems[i].quantity ||
            _cachedItems![i].product.price != widget.cartItems[i].product.price) {
          itemsChanged = true;
          break;
        }
      }
      
      // Si no han cambiado, usar el total cacheado
      if (!itemsChanged && _cachedTotal != null) {
        return _cachedTotal!;
      }
    }
    
    // Recalcular y cachear
    final total = widget.cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
    _cachedTotal = total;
    return total;
  }

  double get total => _calculateTotal();

  // Método para actualizar cantidad manualmente with validación de stock
  Future<void> _updateQuantityManually(Product product, String quantityText) async {
    try {
      final newQuantity = int.tryParse(quantityText);
      if (newQuantity == null || newQuantity < 1) {
        // Si el valor no es válido, restaurar el valor anterior
        _quantityControllers[product.productId]?.text = 
            widget.cartItems.firstWhere((item) => item.product.productId == product.productId).quantity.toString();
        return;
      }
      
      // Validar que no exceda el stock disponible
      if (newQuantity > product.stock) {
        // Mostrar mensaje de error y restaurar valor anterior
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock disponible: ${product.stock} unidades'),
            backgroundColor: Colors.red.shade600,
          ),
        );
        _quantityControllers[product.productId]?.text = 
            widget.cartItems.firstWhere((item) => item.product.productId == product.productId).quantity.toString();
        return;
      }
      
      setState(() {
        _isUpdating = true;
        _updatingItems.add(product.productId);
      });
      
      // Actualizar la cantidad usando el método principal del carrito
      final currentItem = widget.cartItems.firstWhere((item) => item.product.productId == product.productId);
      await CartService.updateCartItem(
        cartId: currentItem.cartId!, 
        productId: product.productId, 
        quantity: newQuantity
      );
      
      // Recargar el carrito
      await widget.onReloadCart();
      
      setState(() {
        _cacheCurrentState();
        _isUpdating = false;
        _updatingItems.remove(product.productId);
      });
      
    } catch (e) {
      print('Error al actualizar cantidad manualmente: $e');
      // Restaurar valor anterior en caso de error
      _quantityControllers[product.productId]?.text = 
          widget.cartItems.firstWhere((item) => item.product.productId == product.productId).quantity.toString();
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar cantidad'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }  // Método para incrementar cantidad con validación de stock
  Future<void> _increaseQuantityWithValidation(Product product) async {
    final currentItem = widget.cartItems.firstWhere((item) => item.product.productId == product.productId);
    
    if (currentItem.quantity >= product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock máximo disponible: ${product.stock} unidades'),
          backgroundColor: Colors.orange.shade600,
        ),
      );
      return;
    }
    
    setState(() {
      _isUpdating = true;
      _updatingItems.add(product.productId);
    });
    
    final errorMessage = await widget.onIncrease(product);
    
    setState(() {
      _isUpdating = false;
      _updatingItems.remove(product.productId);
    });
    
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange.shade600,
        ),
      );
    } else {
      _updateControllerForProduct(product);
      _cacheCurrentState();
      setState(() {
        _rebuildKey++;
      });
    }
  }

  // Método para decrementar cantidad 
  Future<void> _decreaseQuantityWithValidation(Product product) async {
    // Obtener la cantidad actual
    final currentItem = widget.cartItems.firstWhere((item) => item.product.productId == product.productId);
    
    // Si la cantidad actual es 1, mostrar diálogo de confirmación para eliminar
    if (currentItem.quantity <= 1) {
      await _showRemoveConfirmationDialog(product);
      return; // No continuar con la disminución
    }
    
    setState(() {
      _isUpdating = true;
      _updatingItems.add(product.productId);
    });
    
    // Si la cantidad es mayor a 1, proceder normalmente
    final errorMessage = await widget.onDecrease(product);
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.orange.shade600,
        ),
      );    } else {
      // Actualizar el controlador directamente
      _updateControllerForProduct(product);
      // Actualizar caché
      _cacheCurrentState();
      // Forzar actualización del estado local
      setState(() {
        _rebuildKey++; // Incrementar la key para forzar reconstrucción
      });    }
    
    setState(() {
      _isUpdating = false;
      _updatingItems.remove(product.productId);
    });
  }

  // Método para eliminar un producto del carrito directamente
  Future<void> _removeProductFromCart(Product product) async {
    try {
      final currentItem = widget.cartItems.firstWhere((item) => item.product.productId == product.productId);
      await CartService.removeFromCart(cartId: currentItem.cartId!, productId: product.productId);
      await widget.onReloadCart();
      setState(() {
        _rebuildKey++; // Forzar reconstrucción
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar producto: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }
  Future<void> _showRemoveConfirmationDialog(Product product) async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        final colorScheme = theme.colorScheme;
        
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Eliminar producto',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${product.name}" del carrito?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    
    // Si el usuario confirmó, eliminar el producto
    if (shouldRemove == true) {
      await _removeProductFromCart(product);
    }
  }

  Future<void> _buy(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Recargar carrito para obtener stock actualizado
      await widget.onReloadCart();
      
      // Cerrar diálogo de carga
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Validar stock antes de procesar la compra
      List<String> stockErrors = [];
      for (CartItem item in widget.cartItems) {
        if (item.quantity > item.product.stock) {
          stockErrors.add('${item.product.name}: Tienes ${item.quantity} en el carrito pero solo hay ${item.product.stock} disponibles');
        }
      }
      
      // Si hay errores de stock, mostrar diálogo y no proceder
      if (stockErrors.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (dialogContext) {
            final dialogTheme = Theme.of(dialogContext);
            final dialogColorScheme = dialogTheme.colorScheme;
            return AlertDialog(
              backgroundColor: dialogColorScheme.surface,
              title: Text(
                'Stock Insuficiente',
                style: dialogTheme.textTheme.headlineSmall?.copyWith(
                  color: dialogColorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Los siguientes productos tienen stock insuficiente:',
                    style: dialogTheme.textTheme.bodyMedium?.copyWith(
                      color: dialogTheme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...stockErrors.map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $error',
                      style: dialogTheme.textTheme.bodySmall?.copyWith(
                        color: dialogColorScheme.error,
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                  Text(
                    'Las cantidades han sido actualizadas. Por favor revisa tu carrito.',
                    style: dialogTheme.textTheme.bodyMedium?.copyWith(
                      color: dialogTheme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: dialogColorScheme.secondary,
                  ),
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
        return; // No continuar con la compra
      }
      
      // Confirmar la compra en el backend
      await CartService.confirmCart();
      
      // Recargar carrito (debería estar vacío después de la compra)
      await widget.onReloadCart();
      
      // Mostrar mensaje de éxito y navegar de vuelta
      await showDialog(
        context: context,
        builder: (dialogContext) {
          final dialogTheme = Theme.of(dialogContext);
          final dialogColorScheme = dialogTheme.colorScheme;
          return AlertDialog(
            backgroundColor: dialogColorScheme.surface,
            title: Text(
              '¡Compra exitosa!',
              style: dialogTheme.textTheme.headlineSmall?.copyWith(
                color: dialogColorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Tu compra se ha realizado correctamente. El carrito ha sido limpiado.',
              style: dialogTheme.textTheme.bodyMedium?.copyWith(
                color: dialogTheme.textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Cerrar diálogo
                },
                style: TextButton.styleFrom(
                  foregroundColor: dialogColorScheme.secondary,
                ),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      
      // Navegar de vuelta a la pantalla principal después del éxito
      if (context.mounted) {
        Navigator.of(context).pop(); // Volver a la pantalla de productos
      }
        } catch (e) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          final dialogTheme = Theme.of(dialogContext);
          final dialogColorScheme = dialogTheme.colorScheme;
          return AlertDialog(
            backgroundColor: dialogColorScheme.surface,
            title: Text(
              'Error',
              style: dialogTheme.textTheme.headlineSmall?.copyWith(
                color: dialogColorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Error al procesar la compra: ${e.toString()}',
              style: dialogTheme.textTheme.bodyMedium?.copyWith(
                color: dialogTheme.textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: dialogColorScheme.secondary,
                ),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  // Método para actualizar el controlador de un producto específico
  void _updateControllerForProduct(Product product) {
    // Encontrar el item en el carrito
    final cartItem = widget.cartItems.firstWhere(
      (item) => item.product.productId == product.productId,
      orElse: () => throw Exception('Product not found in cart'),
    );
    
    // Actualizar el controlador correspondiente
    final controller = _quantityControllers[product.productId];
    if (controller != null) {
      final newQuantity = cartItem.quantity.toString();
      controller.text = newQuantity;
      
      // Mover el cursor al final del texto
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    } else {
      _quantityControllers[product.productId] = TextEditingController(
        text: cartItem.quantity.toString(),
      );
    }
  }

  /// Método para manejar el pull-to-refresh
  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await widget.onReloadCart();
      _cacheCurrentState();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para validar y actualizar cantidad desde el TextField
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de compras'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      backgroundColor: colorScheme.surface,
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu carrito está vacío',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega algunos productos para comenzar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      final subtotal = item.product.price * item.quantity;
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Card(
                          color: colorScheme.surface,
                          elevation: 2,
                          shadowColor: theme.cardTheme.shadowColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outline, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen del producto
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Image.network(
                                      item.product.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, o, s) => Icon(
                                        Icons.image,
                                        color: theme.iconTheme.color,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Información del producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),                                      const SizedBox(height: 4),
                                      Text(
                                        item.product.description,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stock disponible: ${item.product.stock}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: item.product.stock <= 5 
                                              ? Colors.orange.shade600
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: colorScheme.secondary),
                                        ),
                                        child: Text(
                                          'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Controles de cantidad
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: _updatingItems.contains(item.product.productId)
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: colorScheme.secondary,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.remove,
                                                  color: colorScheme.secondary,
                                                  size: 20,
                                                ),
                                          onPressed: _updatingItems.contains(item.product.productId)
                                              ? null
                                              : () => _decreaseQuantityWithValidation(item.product),
                                          style: IconButton.styleFrom(
                                            backgroundColor: colorScheme.surfaceContainerHighest,
                                            side: BorderSide(color: colorScheme.outline),
                                            minimumSize: const Size(36, 36),
                                          ),
                                        ),                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 8),
                                          width: 60,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: colorScheme.outline),
                                          ),                                          child: TextField(
                                            key: ValueKey('quantity_${item.product.productId}_${item.quantity}_$_rebuildKey'), // Key única para forzar reconstrucción
                                            controller: _quantityControllers[item.product.productId],
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                                            ),                                            onSubmitted: (value) {
                                              FocusScope.of(context).unfocus();
                                              _updateQuantityManually(item.product, value);
                                            },
                                            onEditingComplete: () {
                                              FocusScope.of(context).unfocus();
                                              final value = _quantityControllers[item.product.productId]?.text ?? '';
                                              _updateQuantityManually(item.product, value);
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: _updatingItems.contains(item.product.productId)
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: colorScheme.secondary,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.add,
                                                  color: colorScheme.secondary,
                                                  size: 20,
                                                ),
                                          onPressed: _updatingItems.contains(item.product.productId)
                                              ? null
                                              : () => _increaseQuantityWithValidation(item.product),
                                          style: IconButton.styleFrom(
                                            backgroundColor: colorScheme.surfaceContainerHighest,
                                            side: BorderSide(color: colorScheme.outline),
                                            minimumSize: const Size(36, 36),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                      onPressed: () => _showRemoveConfirmationDialog(item.product),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        side: BorderSide(color: Colors.red.shade200),
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ),
                ),
                // Sección del total y botón de compra
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total:',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: widget.cartItems.isEmpty ? null : () => _buy(context),
                              icon: const Icon(Icons.shopping_bag_outlined),
                              label: const Text('Comprar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
