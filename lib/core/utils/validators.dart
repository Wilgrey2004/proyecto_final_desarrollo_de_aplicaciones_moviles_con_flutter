class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  static String? validateAge(String? value) {
    final numericError = validateNumeric(value, 'La edad');
    if (numericError != null) return numericError;

    final age = int.tryParse(value!.trim());
    if (age == null) return 'Edad inválida';

    if (age < 18) {
      return 'Debes ser mayor de 18 años';
    }

    if (age > 100) {
      return 'Edad inválida';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    if (value.length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }

    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Solo se permiten letras y espacios';
    }

    return null;
  }

  // Cedula validation (Dominican Republic)
  static String? validateCedula(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es requerida';
    }

    // Remove hyphens and spaces
    final cleanValue = value.replaceAll(RegExp(r'[-\s]'), '');

    if (cleanValue.length != 11) {
      return 'La cédula debe tener 11 dígitos';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'La cédula solo debe contener números';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Remove spaces, hyphens, parentheses
    final cleanValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanValue.length < 10) {
      return 'El teléfono debe tener al menos 10 dígitos';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'El teléfono solo debe contener números';
    }

    return null;
  }

  static String? validateNumeric(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (double.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'Este campo'} debe ser un número válido';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(
    String? value,
    int minLength, [
    String? fieldName,
  ]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }

    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(
    String? value,
    int maxLength, [
    String? fieldName,
  ]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $maxLength caracteres';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final urlRegex = RegExp(
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Ingresa una URL válida';
    }

    return null;
  }

  static String? validateDescription(
    String? value, {
    int minLength = 10,
    int maxLength = 500,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es requerida';
    }

    if (value.trim().length < minLength) {
      return 'La descripción debe tener al menos $minLength caracteres';
    }

    if (value.length > maxLength) {
      return 'La descripción no puede exceder $maxLength caracteres';
    }

    return null;
  }

  // Custom validation that combines multiple validators
  static String? validateField(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  static String? validateCoordinates(String? value, String coordinateType) {
    if (value == null || value.trim().isEmpty) {
      return '$coordinateType es requerida';
    }

    final coord = double.tryParse(value.trim());
    if (coord == null) {
      return '$coordinateType debe ser un número válido';
    }

    if (coordinateType.toLowerCase().contains('latitud')) {
      if (coord < -90 || coord > 90) {
        return 'La latitud debe estar entre -90 y 90';
      }
    } else if (coordinateType.toLowerCase().contains('longitud')) {
      if (coord < -180 || coord > 180) {
        return 'La longitud debe estar entre -180 y 180';
      }
    }

    return null;
  }

  // Format cedula with hyphens
  static String formatCedula(String cedula) {
    final cleanCedula = cedula.replaceAll(RegExp(r'[-\s]'), '');
    if (cleanCedula.length == 11) {
      return '${cleanCedula.substring(0, 3)}-${cleanCedula.substring(3, 10)}-${cleanCedula.substring(10)}';
    }
    return cedula;
  }

  // Format phone number
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    }
    return phone;
  }

  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  static String cleanCedula(String cedula) {
    return cedula.replaceAll(RegExp(r'[^\d]'), '');
  }
}
