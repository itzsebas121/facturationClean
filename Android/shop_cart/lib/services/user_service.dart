import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  static const String baseUrl = 'https://facturationclean.vercel.app/api/user';
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('DEBUG: UserService.login iniciado');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
        if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Parsed data: $data');
        print('DEBUG: Token exists: ${data['token'] != null}');
        
        if (data['token'] != null) {
          // Verificar si el token es realmente un string válido o un mensaje de error
          if (data['token'] is String) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', data['token']);
            print('DEBUG: Token guardado en SharedPreferences');
            
            // Decodificar el token y guardar el userId
            try {
              final decoded = JwtDecoder.decode(data['token']);
              print('DEBUG: Token decodificado: $decoded');
              
              if (decoded['userId'] != null) {
                // Verificar el tipo antes de guardar
                var userId = decoded['userId'];
                if (userId is String) {
                  final userIdInt = int.tryParse(userId);
                  if (userIdInt != null) {
                    await prefs.setInt('userId', userIdInt);
                    print('DEBUG: UserId (from String) guardado: $userIdInt');
                  }
                } else if (userId is int) {
                  await prefs.setInt('userId', userId);
                  print('DEBUG: UserId (int) guardado: $userId');
                } else if (userId is num) {
                  await prefs.setInt('userId', userId.toInt());
                  print('DEBUG: UserId (num) guardado: ${userId.toInt()}');
                }
              }
            } catch (jwtError) {
              print('DEBUG: Error decodificando JWT: $jwtError');
            }
          } else if (data['token'] is Map) {
            // El token es un objeto, probablemente un mensaje de error
            final tokenMap = data['token'] as Map<String, dynamic>;
            if (tokenMap.containsKey('Message')) {
              throw Exception(tokenMap['Message']);
            } else {
              throw Exception('Token inválido recibido del servidor');
            }
          } else {
            throw Exception('Formato de token no reconocido');
          }
        }
        return data;
      } else {
        print('DEBUG: Error response: ${response.statusCode}');
        throw Exception('Credenciales incorrectas o error de red');
      }
    } catch (e) {
      print('DEBUG: Exception en UserService.login: $e');
      print('DEBUG: Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String cedula,
    required String firstName,
    required String lastName,
    String? address,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('https://facturationclean.vercel.app/api/clients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cedula': cedula,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'address': address ?? '',
        'phone': phone ?? '',
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorMessage = response.statusCode == 400 
          ? 'Datos inválidos o usuario ya existe'
          : 'Error del servidor';
      throw Exception(errorMessage);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
