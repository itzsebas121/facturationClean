import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  static const String baseUrl = 'https://facturationclean.vercel.app/api/user';
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('DEBUG: UserService.login iniciado con URL: $baseUrl');
      print('DEBUG: Email: $email');
      print('DEBUG: Password length: ${password.length}');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
        },
      );
      
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response headers: ${response.headers}');
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
      } else if (response.statusCode == 401) {
        print('DEBUG: Credenciales incorrectas');
        throw Exception('Email o contraseña incorrectos');
      } else if (response.statusCode == 404) {
        print('DEBUG: Endpoint no encontrado');
        throw Exception('Servicio no disponible. Contacta al administrador.');
      } else {
        print('DEBUG: Error response: ${response.statusCode}');
        print('DEBUG: Error body: ${response.body}');
        throw Exception('Error del servidor (${response.statusCode}). Intenta más tarde.');
      }
    } catch (e) {
      print('DEBUG: Exception en UserService.login: $e');
      print('DEBUG: Exception type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Verifica si el usuario tiene una sesión válida
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        return false;
      }
      
      // Verificar si el token no ha expirado
      if (JwtDecoder.isExpired(token)) {
        // Token expirado, limpiarlo
        await logout();
        return false;
      }
      
      return true;
    } catch (e) {
      // Si hay error verificando el token, considerarlo como no logueado
      await logout(); // Limpiar token corrupto
      return false;
    }
  }

  /// Limpia la sesión del usuario (mejorado)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    // Limpiar cualquier otro dato de sesión que pueda existir
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

  /// Verifica si el token sigue siendo válido durante el uso de la aplicación
  static Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      // Verificar si el token no ha expirado
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }
  
  /// Obtiene información del usuario desde el token
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      if (JwtDecoder.isExpired(token)) {
        await logout();
        return null;
      }
      
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

}
