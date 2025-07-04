import 'package:flutter/material.dart';
import 'dart:async';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/user_service.dart';
import '../widgets/search_filters.dart';
import '../widgets/pagination_widget.dart';
import './cart_screen.dart';
import 'order_history_screen_new.dart';
import 'profile_screen.dart';

class ProductListScreenNew extends StatefulWidget {
  final Future<void> Function(Product) onAddToCart;
  final VoidCallback onLogout;
  final List<CartItem> cartItems;
  final void Function(Product) onRemoveFromCart;
  final Future<String?> Function(Product) onIncreaseQuantity;
  final Future<String?> Function(Product) onDecreaseQuantity;
  final VoidCallback onClearCart;
  final Future<void> Function() onReloadCart;

  const ProductListScreenNew({
    Key? key,
    required this.onAddToCart,
    required this.onLogout,
    required this.cartItems,
    required this.onRemoveFromCart,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onClearCart,
    required this.onReloadCart,
  }) : super(key: key);

  @override
  State<ProductListScreenNew> createState() => _ProductListScreenNewState();
}

class _ProductListScreenNewState extends State<ProductListScreenNew> {
  // Estado similar a la implementación web
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = true;
  bool _productsLoading = false;
  String _searchTerm = "";
  String _selectedCategory = "";
  int _currentPage = 1;
  int _totalProducts = 0;
  
  final int _pageSize = 50;
  int get _totalPages => (_totalProducts / _pageSize).ceil();

  // Controllers para los filtros
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Método principal para cargar datos iniciales (similar a loadInitialData en React)
  Future<void> _loadInitialData() async {
    setState(() {
      _loading = true;
    });

    await Future.wait([
      _fetchCategories(),
      _fetchProducts(1, _searchTerm, _selectedCategory),
    ]);

    setState(() {
      _loading = false;
    });
  }

  // Método para obtener productos (similar a fetchProducts en React)
  Future<void> _fetchProducts(int page, String filtro, String categoryId) async {
    setState(() {
      _productsLoading = true;
    });

    try {
      final result = await ProductService.fetchProducts(
        page: page,
        pageSize: _pageSize,
        filtro: filtro.isNotEmpty ? filtro : null,
        categoryId: categoryId.isNotEmpty ? categoryId : null,
      );

      setState(() {
        _products = result.products;
        _totalProducts = result.total;
        _currentPage = page;
        _productsLoading = false;
      });
    } catch (error) {
      print('Error fetching products: $error');
      setState(() {
        _products = [];
        _totalProducts = 0;
        _productsLoading = false;
      });
    }
  }

  // Método para obtener categorías (similar a fetchCategories en React)
  Future<void> _fetchCategories() async {
    try {
      final categories = await CategoryService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  // Manejo de cambios en la búsqueda con debounce
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final newSearchTerm = _searchController.text.trim();
      if (newSearchTerm != _searchTerm) {
        setState(() {
          _searchTerm = newSearchTerm;
        });
        _fetchProducts(1, _searchTerm, _selectedCategory);
      }
    });
  }

  // Manejo de cambio de página (similar a handlePageChange en React)
  void _handlePageChange(int page) {
    _fetchProducts(page, _searchTerm, _selectedCategory);
  }

  // Manejo de cambio de categoría (similar a handleCategoryChange en React)
  void _handleCategoryChange(String? categoryId) {
    setState(() {
      _selectedCategory = categoryId ?? '';
    });
    _fetchProducts(1, _searchTerm, _selectedCategory);
  }

  // Limpiar filtros
  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchTerm = "";
      _selectedCategory = "";
    });
    _fetchProducts(1, "", "");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Loading inicial
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Productos'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Cargando productos...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          // Botón del carrito
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: colorScheme.onPrimary,
                ),
                if (widget.cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${widget.cartItems.length}',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Ver carrito (${widget.cartItems.length} items)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cartItems: widget.cartItems,
                    onRemove: widget.onRemoveFromCart,
                    onIncrease: widget.onIncreaseQuantity,
                    onDecrease: widget.onDecreaseQuantity,
                    onClearCart: widget.onClearCart,
                    onReloadCart: widget.onReloadCart,
                  ),
                ),
              );
            },
          ),
          // Botón de historial
          IconButton(
            icon: Icon(
              Icons.history,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Historial de compras',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          // Botón de perfil
          IconButton(
            icon: Icon(
              Icons.person,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(onLogout: widget.onLogout),
                ),
              );
            },
          ),
          // Botón de logout
          IconButton(
            icon: Icon(
              Icons.logout,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await UserService.logout();
              widget.onLogout();
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Filtros de búsqueda (similar a SearchFilters en React)
          SearchFilters(
            categories: _categories,
            onSearch: (term) {
              _searchController.text = term;
            },
            onCategoryChange: _handleCategoryChange,
            searchTerm: _searchTerm,
            selectedCategory: _selectedCategory,
            searchController: _searchController,
            onClearFilters: _clearFilters,
          ),
          
          // Información de productos (similar a products-summary en React)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _productsLoading
                        ? "Buscando..."
                        : "$_totalProducts producto${_totalProducts != 1 ? "s" : ""} encontrado${_totalProducts != 1 ? "s" : ""}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (_totalPages > 1)
                  Text(
                    "Página $_currentPage de $_totalPages",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          
          // Lista de productos (similar a ProductGrid en React)
          Expanded(
            child: _productsLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron productos',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_searchTerm.isNotEmpty || _selectedCategory.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Limpiar filtros'),
                              ),
                            ],
                          ],
                        ),
                      )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product, colorScheme, theme);
                    },
                  ),
          ),
          
          // Paginación (similar a Pagination en React)
          if (_totalPages > 1)
            PaginationWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChange: _handlePageChange,
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                    product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Icon(
                      Icons.image,
                      color: colorScheme.onSurfaceVariant,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Información del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botón de agregar al carrito
              IconButton(
                icon: Icon(
                  Icons.add_shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await widget.onAddToCart(product);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} agregado al carrito'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
