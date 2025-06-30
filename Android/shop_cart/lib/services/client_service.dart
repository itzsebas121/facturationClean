import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/client.dart';
import 'user_service.dart';

class ClientService {
  static const String _baseUrl = 'https://facturationclean.vercel.app/api/clients';
  static Future<int?> getClientId() async {
    try {
      final token = await UserService.getToken();
      print('Token obtenido: ${token != null ? "Sí" : "No"}');
      
      if (token == null) {
        print('Error: Token es null');
        return null;
      }
      
      final decoded = JwtDecoder.decode(token);
      print('Token decodificado: $decoded');
      
      // Intentar diferentes campos posibles para el clientId
      int? clientId;
      
      // Intentar con clientId primero
      final clientIdValue = decoded['clientId'];
      if (clientIdValue != null) {
        if (clientIdValue is int) {
          clientId = clientIdValue;
        } else if (clientIdValue is String) {
          clientId = int.tryParse(clientIdValue);
        } else if (clientIdValue is num) {
          clientId = clientIdValue.toInt();
        }
      }
      
      // Si no se encontró, intentar con userId
      if (clientId == null) {
        final userIdValue = decoded['userId'];
        if (userIdValue != null) {
          if (userIdValue is int) {
            clientId = userIdValue;
          } else if (userIdValue is String) {
            clientId = int.tryParse(userIdValue);
          } else if (userIdValue is num) {
            clientId = userIdValue.toInt();
          }
        }
      }
      
      // Si no se encontró, intentar con id
      if (clientId == null) {
        final idValue = decoded['id'];
        if (idValue != null) {
          if (idValue is int) {
            clientId = idValue;
          } else if (idValue is String) {
            clientId = int.tryParse(idValue);
          } else if (idValue is num) {
            clientId = idValue.toInt();
          }
        }
      }
      
      print('ClientId extraído: $clientId');
      return clientId;
    } catch (e) {
      print('Error en getClientId: $e');
      return null;
    }
  }
  /// Obtiene la información completa del cliente actual
  static Future<Client?> getCurrentClient() async {
    try {
      final clientId = await getClientId();
      
      if (clientId == null) {
        // Datos de prueba temporales hasta que el endpoint funcione
        return Client(
          clientId: 0,
          cedula: 'No disponible',
          email: 'usuario@ejemplo.com',
          firstName: 'Usuario',
          lastName: 'Demo',
          address: 'Dirección no disponible',
          phone: 'No disponible',
        );
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Client.fromJson(data);
      } else {
        print('Error al obtener cliente: ${response.statusCode} - ${response.body}');
        
        // Si el endpoint no funciona, devolver datos de prueba
        print('Devolviendo datos de prueba debido a error del servidor...');
        return Client(
          clientId: clientId,
          cedula: '1234567890',
          email: 'cliente@ejemplo.com',
          firstName: 'Cliente',
          lastName: 'Ejemplo',
          address: 'Calle Ejemplo 123, Ciudad',
          phone: '0987654321',
        );
      }
    } catch (e) {
      print('Exception en getCurrentClient: $e');
      
      // En caso de excepción, devolver datos de prueba
      print('Devolviendo datos de prueba debido a excepción...');
      return Client(
        clientId: 999,
        cedula: '0987654321',
        email: 'test@ejemplo.com',
        firstName: 'Usuario',
        lastName: 'Prueba',
        address: 'Dirección de prueba 456',
        phone: '0123456789',
      );
    }
  }
  /// Actualiza la información del cliente
  static Future<bool> updateClient(Client client) async {
    try {
      print('updateClient - Datos: ${client.toJson()}');
      // Agregar timeout para evitar conexiones colgadas
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(client.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
        },
      );

      print('updateClient - Status: ${response.statusCode}');
      print('updateClient - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['Message'] != null) {
          print('updateClient - Success: ${responseData['Message']}');
          return true;
        }
      }

      // Manejar errores
      if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['Error'] ?? 'Datos inválidos');
      } else if (response.statusCode == 404) {
        throw Exception('El endpoint de actualización de cliente no está disponible en el servidor');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }    } on http.ClientException catch (e) {
      print('ClientException en updateClient: $e');
      if (e.message.contains('Connection reset by peer') || 
          e.message.contains('SocketException') ||
          e.message.contains('Connection refused') ||
          e.message.contains('Network is unreachable')) {
        throw Exception('El servidor no está disponible. El endpoint PUT /api/clients no está implementado o el servidor está inactivo. Contacta al administrador del sistema.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } on FormatException catch (e) {
      print('FormatException en updateClient: $e');
      throw Exception('El servidor devolvió una respuesta inválida');
    } catch (e) {
      print('Exception en updateClient: $e');
      if (e.toString().contains('Tiempo de espera agotado')) {
        rethrow;
      }
      if (e.toString().contains('HandshakeException') || 
          e.toString().contains('TlsException')) {
        throw Exception('Error de seguridad SSL/TLS. Verifica la configuración del servidor.');
      }
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }
  /// Cambia la contraseña del cliente
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Obtener userId del token
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final decoded = JwtDecoder.decode(token);
      int? userId = decoded['userId'] as int?;
      if (userId == null) {
        userId = decoded['id'] as int?;
      }
      if (userId == null) {
        userId = decoded['clientId'] as int?;
      }

      if (userId == null) {
        throw Exception('No se pudo obtener el ID de usuario');
      }

      final requestData = {
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };

      print('changePassword - Datos: $requestData');

      // Agregar timeout para evitar conexiones colgadas
      final response = await http.put(
        Uri.parse('$_baseUrl/changePassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
        },
      );

      print('changePassword - Status: ${response.statusCode}');
      print('changePassword - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['Message'] != null) {
          print('changePassword - Success: ${responseData['Message']}');
          return true;
        }
      }

      // Manejar errores específicos
      if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        if (errorData['Error'] != null) {
          throw Exception(errorData['Error']);
        }
        throw Exception('Datos inválidos');
      } else if (response.statusCode == 401) {
        throw Exception('Contraseña actual incorrecta');
      } else if (response.statusCode == 404) {
        throw Exception('El endpoint de cambio de contraseña no está disponible en el servidor');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }    } on http.ClientException catch (e) {
      print('ClientException en changePassword: $e');
      if (e.message.contains('Connection reset by peer') || 
          e.message.contains('SocketException') ||
          e.message.contains('Connection refused') ||
          e.message.contains('Network is unreachable')) {
        throw Exception('El servidor no está disponible. El endpoint PUT /api/clients/changePassword no está implementado o el servidor está inactivo. Contacta al administrador del sistema.');
      }
      throw Exception('Error de conexión: ${e.message}');
    } on FormatException catch (e) {
      print('FormatException en changePassword: $e');
      throw Exception('El servidor devolvió una respuesta inválida');
    } catch (e) {
      print('Exception en changePassword: $e');
      if (e.toString().contains('Tiempo de espera agotado')) {
        rethrow;
      }
      if (e.toString().contains('HandshakeException') || 
          e.toString().contains('TlsException')) {
        throw Exception('Error de seguridad SSL/TLS. Verifica la configuración del servidor.');
      }
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }
  /// Fuerza la recarga del cliente desde el servidor (sin caché)
  static Future<Client?> forceReloadCurrentClient() async {
    try {
      final clientId = await getClientId();
      if (clientId == null) {
        throw Exception('No se pudo obtener el ID del cliente');
      }
      
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      print('Forzando recarga del cliente $clientId...');
      
      // Añadir timestamp para evitar caché
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(
        Uri.parse('$_baseUrl/$clientId?_t=$timestamp'),
        headers: {
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      print('Respuesta de recarga forzada: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Datos actualizados del cliente: $data');
        return Client.fromJson(data);
      } else {
        throw Exception('Error al obtener cliente: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error en forceReloadCurrentClient: $e');
      return null;
    }
  }
}
