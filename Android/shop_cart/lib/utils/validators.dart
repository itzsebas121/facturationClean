/// Clase de validaciones reutilizable para formularios
class Validators {
  // Expresiones regulares
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp _cedulaRegex = RegExp(
    r'^[0-9]{10}$',
  );
  
  static final RegExp _phoneRegex = RegExp(
    r'^(09|02|03|04|05|06|07)[0-9]{8}$',
  );
  
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ\s]+$',
  );
  
  static final RegExp _numbersOnlyRegex = RegExp(
    r'^[0-9]+$',
  );

  /// Validador para campos obligatorios
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    return null;
  }

  /// Validador para email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    
    final cleanValue = value.trim();
    
    if (!_emailRegex.hasMatch(cleanValue)) {
      return 'Ingrese un correo electrónico válido';
    }
    
    if (cleanValue.length > 100) {
      return 'El correo electrónico no puede exceder 100 caracteres';
    }
    
    return null;
  }

  /// Validador para contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    if (value.length > 50) {
      return 'La contraseña no puede exceder 50 caracteres';
    }
    
    
    return null;
  }

  /// Validador para cédula ecuatoriana
  static String? cedula(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La cédula es obligatoria';
    }
    
    final cleanValue = value.trim();
    
    if (!_cedulaRegex.hasMatch(cleanValue)) {
      return 'La cédula debe tener exactamente 10 dígitos';
    }
    
    // Validar algoritmo de cédula ecuatoriana
    if (!_isValidEcuadorianCedula(cleanValue)) {
      return 'La cédula ingresada no es válida';
    }
    
    return null;
  }

  /// Validador para nombres
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    
    final cleanValue = value.trim();
    
    if (cleanValue.length < 2) {
      return '${fieldName ?? 'Este campo'} debe tener al menos 2 caracteres';
    }
    
    if (cleanValue.length > 50) {
      return '${fieldName ?? 'Este campo'} no puede exceder 50 caracteres';
    }
    
    if (!_nameRegex.hasMatch(cleanValue)) {
      return '${fieldName ?? 'Este campo'} solo puede contener letras y espacios';
    }
    
    return null;
  }

  /// Validador para teléfono
  static String? phone(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.trim().isEmpty)) {
      return null; // Campo opcional
    }
    
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'El teléfono es obligatorio';
    }
    
    final cleanValue = value!.trim();
    
    // Validar formato ecuatoriano exacto (como cédula)
    if (!_phoneRegex.hasMatch(cleanValue)) {
      return 'Ingrese un número de teléfono válido para Ecuador (10 dígitos)';
    }
    
    return null;
  }

  /// Validador para dirección
  static String? address(String? value, {bool isRequired = false}) {
    if (!isRequired && (value == null || value.trim().isEmpty)) {
      return null; // Campo opcional
    }
    
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'La dirección es obligatoria';
    }
    
    final cleanValue = value!.trim();
    
    if (cleanValue.length < 5) {
      return 'La dirección debe tener al menos 5 caracteres';
    }
    
    if (cleanValue.length > 200) {
      return 'La dirección no puede exceder 200 caracteres';
    }
    
    return null;
  }

  /// Validador para números enteros
  static String? integer(String? value, {String? fieldName, int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    
    final cleanValue = value.trim();
    
    if (!_numbersOnlyRegex.hasMatch(cleanValue)) {
      return '${fieldName ?? 'Este campo'} solo puede contener números';
    }
    
    final intValue = int.tryParse(cleanValue);
    if (intValue == null) {
      return 'Ingrese un número válido';
    }
    
    if (min != null && intValue < min) {
      return '${fieldName ?? 'Este campo'} debe ser mayor o igual a $min';
    }
    
    if (max != null && intValue > max) {
      return '${fieldName ?? 'Este campo'} debe ser menor o igual a $max';
    }
    
    return null;
  }

  /// Validador para longitud mínima
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es obligatorio';
    }
    
    if (value.trim().length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }
    
    return null;
  }

  /// Validador para longitud máxima
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null) return null;
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede exceder $maxLength caracteres';
    }
    
    return null;
  }

  /// Combinar múltiples validadores
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  /// Validar algoritmo de cédula ecuatoriana
  static bool _isValidEcuadorianCedula(String cedula) {
    if (cedula.length != 10) return false;
    
    final digits = cedula.split('').map((e) => int.parse(e)).toList();
    
    // Los primeros dos dígitos deben corresponder a una provincia válida (01-24)
    final province = int.parse(cedula.substring(0, 2));
    if (province < 1 || province > 24) return false;
    
    // El tercer dígito debe ser menor a 6 para personas naturales
    if (digits[2] >= 6) return false;
    
    // Algoritmo de validación
    final coefficients = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    int sum = 0;
    
    for (int i = 0; i < 9; i++) {
      int value = digits[i] * coefficients[i];
      if (value >= 10) value = value - 9;
      sum += value;
    }
    
    final verifier = sum % 10 == 0 ? 0 : 10 - (sum % 10);
    return verifier == digits[9];
  }
}
