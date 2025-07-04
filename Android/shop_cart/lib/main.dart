import 'package:flutter/material.dart';
import './screens/login_screen.dart';
import './screens/product_list_screen_new.dart';
import 'theme/app_theme.dart';
import 'models/product.dart';
import 'models/cart_item.dart';
import 'services/cart_service.dart';
import 'services/user_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;
  bool _isLoading = true; // Nuevo estado para el splash screen
  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Verificar si el usuario ya está logueado
  }

  /// Verifica si el usuario tiene una sesión válida guardada
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await UserService.isLoggedIn();
      
      setState(() {
        _loggedIn = isLoggedIn;
        _isLoading = false;
      });
      
      if (isLoggedIn) {
        // Si está logueado, cargar el carrito
        await _loadCart();
      }
    } catch (e) {
      // Si hay error verificando la sesión, mostrar login
      setState(() {
        _loggedIn = false;
        _isLoading = false;
      });
    }
  }
  Future<void> _loadCart() async {
    try {
      final items = await CartService.getCartItems();
      setState(() {
        _cart.clear();
        _cart.addAll(items);
      });
    } catch (e) {
      setState(() {
        _cart.clear(); // Limpiar carrito local en caso de error
      });
    }
  }
  void _onLoginSuccess() async {
    setState(() {
      _loggedIn = true;
    });
    
    try {
      await _loadCart();
      // Mostrar mensaje de bienvenida
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido! Sesión iniciada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Error loading cart, but user is still logged in
      print('Error cargando carrito después del login: $e');
    }
  }

  void _onLogout() async {
    try {
      // Limpiar la sesión del usuario
      await UserService.logout();
      
      setState(() {
        _loggedIn = false;
        _cart.clear();
      });
      
      // Limpiar el carrito y resetear el estado
      CartService.clearCart();
      CartService.resetCartFlag(); // Resetear flag de carrito nuevo
      CartService.resetOrdersEndpoint(); // Resetear endpoint de órdenes
      
      // Mostrar mensaje de cierre de sesión exitoso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // En caso de error, forzar el logout local
      setState(() {
        _loggedIn = false;
        _cart.clear();
      });
      CartService.clearCart();
      CartService.resetCartFlag();
      CartService.resetOrdersEndpoint();
    }
  }

  Future<void> _addToCart(Product product) async {    try {
      await CartService.addToCart(product: product, quantity: 1);
      await _loadCart();
    } catch (e) {
      // Intentar recargar el carrito para mostrar el estado actual
      await _loadCart();
    }
  }  Future<void> _removeFromCart(Product product) async {
    try {
      final currentItem = _cart.firstWhere((item) => item.product.productId == product.productId);
      await CartService.removeFromCart(cartId: currentItem.cartId!, productId: product.productId);
      await _loadCart();    } catch (e) {
      if (e.toString().contains('ya fue procesado')) {
        // El carrito fue procesado, recargar para mostrar estado actual
        await _loadCart();
      }
    }
  }

  Future<String?> _increaseQuantity(Product product) async {
    try {
      final currentItem = _cart.firstWhere((item) => item.product.productId == product.productId);
      
      // Validar que no supere el stock disponible
      if (currentItem.quantity >= product.stock) {
        return 'No puedes agregar más. Stock disponible: ${product.stock}';
      }
        await CartService.updateCartItem(cartId: currentItem.cartId!, productId: product.productId, quantity: currentItem.quantity + 1);
      await _loadCart();
      return null; // Sin error
    } catch (e) {
      if (e.toString().contains('ya fue procesado')) {
        // El carrito fue procesado, recargar para mostrar estado actual
        await _loadCart();
      }
      return 'Error al aumentar cantidad: $e';
    }
  }  Future<String?> _decreaseQuantity(Product product) async {
    try {
      final currentItem = _cart.firstWhere((item) => item.product.productId == product.productId);
      final newQuantity = currentItem.quantity - 1;
      
      // Validar que la cantidad no sea menor a 1
      if (newQuantity < 1) {
        return 'La cantidad mínima es 1. Usa el botón eliminar para quitar el producto.';
      }
        await CartService.updateCartItem(cartId: currentItem.cartId!, productId: product.productId, quantity: newQuantity);
      await _loadCart();
      return null; // Sin error
    } catch (e) {
      if (e.toString().contains('ya fue procesado')) {
        // El carrito fue procesado, recargar para mostrar estado actual
        await _loadCart();
      }
      return 'Error al disminuir cantidad: $e';
    }
  }

  Future<void> _clearCart() async {
    await CartService.clearCart();
    await _loadCart();
  }
  Future<void> _forceRefreshAfterPurchase() async {
    // Método específico para refrescar después de una compra
    // Intenta múltiples veces para asegurar que el carrito esté limpio
    
    for (int i = 0; i < 3; i++) {
      await _loadCart();
      
      if (_cart.isEmpty) {
        break;
      }
      
      if (i < 2) { // No esperar en el último intento
        await Future.delayed(const Duration(milliseconds: 500));      }    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrito de Compras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Seguir el sistema
      home: _isLoading 
          ? _buildSplashScreen() // Mostrar splash mientras se verifica la sesión
          : _loggedIn
              ? ProductListScreenNew(
                  onAddToCart: _addToCart,
                  onLogout: _onLogout,
                  cartItems: _cart,
                  onRemoveFromCart: _removeFromCart,
                  onIncreaseQuantity: _increaseQuantity,
                  onDecreaseQuantity: _decreaseQuantity,
                  onClearCart: _clearCart,
                  onReloadCart: _forceRefreshAfterPurchase,
                )
              : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }

  /// Pantalla de splash mientras se verifica la sesión
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 80,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
            const SizedBox(height: 20),
            Text(
              'Carrito de Compras',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
