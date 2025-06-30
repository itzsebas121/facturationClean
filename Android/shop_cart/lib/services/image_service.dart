import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'client_service.dart';
import 'user_service.dart';

class ImageService {
  static const String _baseUrl = 'https://facturationclean.vercel.app';

  /// Sube una imagen al servidor y devuelve la URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/upload');
      final request = http.MultipartRequest('POST', uri);

      // Añadir la imagen al request (campo "file" igual que multer)
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Enviar la petición
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        
        // Extraer la URL de la respuesta
        if (data['url'] != null) {
          return data['url'] as String;
        } else if (data['imageUrl'] != null) {
          return data['imageUrl'] as String;
        } else {
          // Si la respuesta no tiene estructura conocida, intentar usar toda la respuesta
          return responseBody;
        }
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Actualiza la foto de perfil del cliente
  static Future<void> updateProfilePicture(String imageUrl) async {
    try {
      final token = await UserService.getToken();
      final clientId = await ClientService.getClientId();
      
      if (token == null || clientId == null) {
        throw Exception('No se encontró información de autenticación');
      }

      final requestBody = {
        'clientId': clientId,
        'picture': imageUrl,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/api/clients/updatePicture'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Éxito
      } else {
        throw Exception('Error al actualizar foto de perfil: ${response.body}');
      }
      
    } catch (e) {
      throw Exception('Error al actualizar foto de perfil: $e');
    }
  }

  /// Selecciona una imagen de la galería o cámara con manejo robusto de errores
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      
      // Intentar obtener la imagen con timeout
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al acceder a ${source == ImageSource.camera ? 'la cámara' : 'la galería'}');
        },
      );
      
      if (pickedFile == null) return null;
      
      return File(pickedFile.path);
    } on PlatformException catch (e) {
      // Manejar errores específicos de la plataforma
      print('PlatformException en pickImage: ${e.code} - ${e.message}');
      
      if (e.code == 'camera_access_denied') {
        throw Exception('Acceso a la cámara denegado. Ve a Configuración > Aplicaciones > Shop Cart > Permisos y habilita la cámara.');
      } else if (e.code == 'photo_access_denied') {
        throw Exception('Acceso a la galería denegado. Ve a Configuración > Aplicaciones > Shop Cart > Permisos y habilita el almacenamiento.');
      } else if (e.code == 'invalid_source') {
        throw Exception('Fuente de imagen no válida. Intenta usar una fuente diferente.');
      } else if (e.message?.contains('channel') == true || 
                 e.message?.contains('connection') == true ||
                 e.message?.contains('implementation not found') == true) {
        throw Exception('Error de comunicación con el plugin. Intenta:\n1. Reiniciar la aplicación\n2. Usar una fuente de imagen diferente\n3. Verificar que los permisos estén habilitados');
      } else {
        throw Exception('Error de plataforma al acceder a ${source == ImageSource.camera ? 'la cámara' : 'la galería'}: ${e.message ?? 'Error desconocido'}');
      }
    } catch (e) {
      if (e.toString().contains('Error de comunicación') || 
          e.toString().contains('Tiempo de espera agotado')) {
        rethrow;
      }
      throw Exception('Error al seleccionar imagen: $e');
    }
  }

  /// Método de fallback alternativo para seleccionar imagen
  static Future<File?> pickImageWithFallback({ImageSource source = ImageSource.gallery}) async {
    try {
      // Primer intento con el método principal
      return await pickImage(source: source);
    } catch (e) {
      print('Error en método principal: $e');
      
      try {
        // Segundo intento con configuración más básica
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 70, // Calidad menor para reducir carga
        );
        
        if (pickedFile == null) return null;
        return File(pickedFile.path);
      } catch (e2) {
        print('Error en fallback: $e2');
        
        // Si es error de canal, lanzar mensaje específico
        if (e2.toString().contains('channel') || 
            e2.toString().contains('connection') ||
            e2.toString().contains('implementation not found')) {
          throw Exception('Plugin de imagen no disponible. Reinicia la aplicación e intenta nuevamente.');
        }
        rethrow;
      }
    }
  }

  /// Método alternativo que intenta diferentes enfoques para la selección de imagen
  static Future<File?> pickImageAlternative({ImageSource source = ImageSource.gallery}) async {
    // Método 1: Enfoque estándar
    try {
      print('Intentando método estándar...');
      return await pickImage(source: source);
    } catch (e1) {
      print('Método estándar falló: $e1');
    }

    // Método 2: Enfoque con fallback
    try {
      print('Intentando método con fallback...');
      return await pickImageWithFallback(source: source);
    } catch (e2) {
      print('Método con fallback falló: $e2');
    }

    // Método 3: Enfoque básico sin configuraciones extra
    try {
      print('Intentando método básico...');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e3) {
      print('Método básico falló: $e3');
    }

    // Si todos los métodos fallan
    throw Exception('No se pudo acceder a la selección de imágenes con ningún método disponible.\n\nPor favor:\n1. Reinicia la aplicación\n2. Verifica los permisos\n3. Reinicia el dispositivo si es necesario');
  }

  /// Intenta recuperar el canal de comunicación
  static Future<void> _resetImagePickerChannel() async {
    try {
      print('Intentando resetear el canal de image_picker...');
      // Crear una instancia temporal para forzar la inicialización
      ImagePicker();
      
      // Intentar una operación simple que no requiera UI
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('Canal de image_picker reseteado exitosamente');
    } catch (e) {
      print('Error al resetear canal: $e');
    }
  }

  /// Verifica si el plugin de image_picker está disponible
  static Future<bool> isImagePickerAvailable() async {
    try {
      ImagePicker();
      // Intentar una operación muy básica para verificar disponibilidad
      await Future.delayed(const Duration(milliseconds: 50));
      return true;
    } catch (e) {
      print('Plugin image_picker no disponible: $e');
      return false;
    }
  }

  /// Inicializa forzosamente el plugin de image_picker
  static Future<bool> initializeImagePicker() async {
    try {
      print('Inicializando plugin image_picker...');
      
      // Crear múltiples instancias para forzar la inicialización
      for (int i = 0; i < 3; i++) {
        ImagePicker();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Verificar que esté disponible
      final isAvailable = await isImagePickerAvailable();
      print('Plugin image_picker ${isAvailable ? 'inicializado correctamente' : 'no disponible'}');
      
      return isAvailable;
    } catch (e) {
      print('Error al inicializar image_picker: $e');
      return false;
    }
  }

  /// Proceso completo: seleccionar imagen, subirla y actualizar perfil
  static Future<String?> selectAndUploadProfilePicture({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // 0. Verificar e inicializar el plugin antes de usarlo
      print('Verificando disponibilidad del plugin image_picker...');
      bool isAvailable = await isImagePickerAvailable();
      
      if (!isAvailable) {
        print('Plugin no disponible, intentando inicializar...');
        isAvailable = await initializeImagePicker();
        
        if (!isAvailable) {
          throw Exception('El plugin de selección de imágenes no está disponible.\n\nSoluciones:\n1. Reinicia la aplicación completamente\n2. Reinicia el dispositivo\n3. Verifica que la app tenga permisos de cámara y almacenamiento');
        }
      }
      
      print('Plugin image_picker verificado y disponible');

      // 1. Seleccionar imagen con reintentos inteligentes
      File? imageFile;
      int attempts = 0;
      const maxAttempts = 3;
      Exception? lastError;        while (imageFile == null && attempts < maxAttempts) {
        try {
          print('Intento ${attempts + 1} de $maxAttempts para seleccionar imagen');
          
          // Usar el método alternativo que prueba múltiples enfoques
          imageFile = await pickImageAlternative(source: source);
          
          if (imageFile != null) {
            print('Imagen seleccionada exitosamente: ${imageFile.path}');
            break;
          } else {
            print('Usuario canceló la selección de imagen');
            return null; // Usuario canceló
          }
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          attempts++;
          
          // No reintentar en caso de errores específicos
          if (e.toString().contains('denegado') || 
              e.toString().contains('denied') ||
              e.toString().contains('Tiempo de espera agotado') ||
              e.toString().contains('Plugin de imagen no disponible')) {
            print('Error no recuperable: $e');
            throw lastError;
          }
          
          if (attempts < maxAttempts) {
            print('Error en intento $attempts: $e. Reintentando en 2 segundos...');
            
            // Intentar resetear el canal si es un error de comunicación
            if (e.toString().contains('channel') || e.toString().contains('connection')) {
              await _resetImagePickerChannel();
              // Reinicializar el plugin después del reset
              await initializeImagePicker();
            }
            
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }
      
      // Si no se pudo seleccionar después de todos los intentos
      if (imageFile == null && lastError != null) {
        throw lastError;
      } else if (imageFile == null) {
        return null; // Usuario canceló
      }

      // 2. Subir imagen al servidor
      print('Subiendo imagen al servidor...');
      final imageUrl = await uploadImage(imageFile);
      if (imageUrl == null) {
        throw Exception('No se pudo obtener la URL de la imagen');
      }
      print('Imagen subida exitosamente: $imageUrl');

      // 3. Actualizar foto de perfil
      print('Actualizando foto de perfil...');
      await updateProfilePicture(imageUrl);
      print('Foto de perfil actualizada exitosamente');

      return imageUrl;
    } on PlatformException catch (e) {
      print('PlatformException en selectAndUploadProfilePicture: ${e.code} - ${e.message}');
      
      // Errores específicos de la plataforma con mensajes más claros
      if (e.code == 'camera_access_denied') {
        throw Exception('Acceso a la cámara denegado. Ve a Configuración > Aplicaciones > Shop Cart > Permisos y habilita la cámara.');
      } else if (e.code == 'photo_access_denied') {
        throw Exception('Acceso a la galería denegado. Ve a Configuración > Aplicaciones > Shop Cart > Permisos y habilita el almacenamiento.');
      } else if (e.message?.contains('channel') == true || 
                 e.message?.contains('connection') == true ||
                 e.message?.contains('implementation not found') == true) {
        throw Exception('Error de comunicación con el plugin.\n\nPara solucionar:\n1. Reinicia la aplicación completamente\n2. Verifica que los permisos estén habilitados\n3. Si el problema persiste, usa una fuente diferente (cámara/galería)');
      } else {
        throw Exception('Error de plataforma: ${e.message ?? 'Error desconocido'}');
      }
    } catch (e) {
      print('Error general en selectAndUploadProfilePicture: $e');
      
      if (e.toString().contains('Error al seleccionar imagen') ||
          e.toString().contains('Error de comunicación') ||
          e.toString().contains('denegado')) {
        rethrow;
      }
      throw Exception('Error en el proceso: $e');
    }
  }
}
