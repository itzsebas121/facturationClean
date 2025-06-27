import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductPage {
  final List<Product> products;
  final int total;
  ProductPage({required this.products, required this.total});
}

class ProductService {
  static const String baseUrl = 'https://facturationclean.vercel.app/api/products';
  
  static Future<ProductPage> fetchProducts({
    int page = 1, 
    int pageSize = 50,  
    String? filtro,  // Cambiar de filtroGeneral a filtro para coincidir con web
    String? categoryId, // Cambiar a String para coincidir con web
    bool isAdmin = false,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sortBy,
    String? sortOrder,
  }) async {
    // Construir URL con parámetros de filtro exactos del backend
    final queryParams = <String, String>{
      'page': page.toString(), // Cambiar de Page a page (minúscula) para coincidir con web
      'pageSize': pageSize.toString(), // Cambiar de PageSize a pageSize para coincidir con web
    };
    
    // Agregar filtros opcionales solo si tienen valor
    if (filtro != null && filtro.isNotEmpty) {
      queryParams['filtro'] = filtro; // Cambiar de FiltroGeneral a filtro para coincidir con web
    }
    
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId; // Cambiar de CategoryId a categoryId para coincidir con web
    }
    
    if (isAdmin) {
      queryParams['isAdmin'] = 'true'; // Cambiar formato para coincidir con web
    }
    
    // Nuevos filtros (mantener formato web)
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice.toString();
    }
    
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice.toString();
    }
    
    if (inStock == true) {
      queryParams['inStock'] = 'true'; // Cambiar formato para coincidir con web
    }
    
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy; // Cambiar de OrdenarPor a sortBy para coincidir con web
    }
    
    if (sortOrder != null && sortOrder.isNotEmpty) {
      queryParams['sortOrder'] = sortOrder; // Cambiar de Orden a sortOrder para coincidir con web
    }
    
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      final List<dynamic> productsList = data['products'] ?? [];
      final int total = data['total'] ?? 0;
      
      return ProductPage(
        products: productsList.map((json) => Product.fromJson(json)).toList(),
        total: total,
      );
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode} - ${response.body}');
    }
  }
}
