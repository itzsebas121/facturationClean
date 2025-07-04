import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'user_service.dart';
import 'client_service.dart';

class OrderService {
  static const String baseUrl = 'https://facturationclean.vercel.app/api/orders';

  static Future<void> createOrder(List<CartItem> cartItems) async {
    final token = await UserService.getToken();
    final clientId = await ClientService.getClientId();
    if (clientId == null) throw Exception('No se pudo obtener el ClientId');
    final orderItems = cartItems.map((item) => {
      'ProductId': item.product.productId,
      'Quantity': item.quantity,
      'UnitPrice': item.product.price,
      'SubTotal': item.product.price * item.quantity,
    }).toList();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ClientId': clientId,
        'items': orderItems,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al realizar la compra: ${response.body}');
    }
  }
}
