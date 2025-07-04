import 'dart:developer' as developer;

class ErrorService {
  /// Registra un error con detalles para diagnóstico
  static void logError({
    required String message,
    required String details,
    required String screen,
    Map<String, dynamic>? context,
  }) {
    // Crear el log estructurado
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'message': message,
      'details': details,
      'screen': screen,
      'context': context ?? {},
    };
    
    // Log para desarrollo
    developer.log(
      'ERROR: $message',
      name: 'ErrorService',
      error: details,
      time: DateTime.now(),
    );
    
    // Log estructurado para el desarrollador
    developer.log(
      'Error Details: ${logData.toString()}',
      name: 'ErrorService',
      time: DateTime.now(),
    );
    
    // Aquí se podría enviar a un servicio de logging externo
    // como Firebase Crashlytics, Sentry, etc.
    _sendToExternalLogging(logData);
  }
  
  /// Registra una advertencia
  static void logWarning({
    required String message,
    required String screen,
    Map<String, dynamic>? context,
  }) {
    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'message': message,
      'screen': screen,
      'context': context ?? {},
    };
    
    developer.log(
      'WARNING: $message',
      name: 'ErrorService',
      time: DateTime.now(),
    );
    
    developer.log(
      'Warning Details: ${logData.toString()}',
      name: 'ErrorService',
      time: DateTime.now(),
    );
  }
  
  /// Registra información general
  static void logInfo({
    required String message,
    required String screen,
    Map<String, dynamic>? context,
  }) {
    developer.log(
      'INFO: $message',
      name: 'ErrorService',
      time: DateTime.now(),
    );
  }
  
  /// Método privado para enviar logs a servicios externos
  /// En el futuro se puede implementar con Firebase Crashlytics, etc.
  static void _sendToExternalLogging(Map<String, dynamic> logData) {
    // Por ahora solo registramos localmente
    // En producción aquí se enviaría a un servicio externo
    
    // Ejemplo de implementación futura:
    // FirebaseCrashlytics.instance.recordError(
    //   logData['message'],
    //   StackTrace.current,
    //   fatal: false,
    //   information: logData,
    // );
  }
}
