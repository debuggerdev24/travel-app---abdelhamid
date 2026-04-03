class Validator {
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');

  /// Validates email address
  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// First name / surname — letters, spaces, hyphens, apostrophes (Latin extended).
  static String? validatePersonName(String? value, String fieldName) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName is required';
    if (v.length < 2) return '$fieldName must be at least 2 characters';
    if (v.length > 60) return '$fieldName is too long';
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s'\-]+$").hasMatch(v)) {
      return 'Use only letters for $fieldName';
    }
    return null;
  }

  /// Free text (address, place, nationality) with sensible length bounds.
  static String? validateRequiredText(
    String? value,
    String fieldName, {
    int minLen = 2,
    int maxLen = 300,
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$fieldName is required';
    if (v.length < minLen) {
      return '$fieldName must be at least $minLen characters';
    }
    if (v.length > maxLen) return '$fieldName is too long';
    return null;
  }

  /// Expects YYYY-MM-DD (same as UI hint).
  static String? validateIsoDateOfBirth(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Date of birth is required';
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
      return 'Use format YYYY-MM-DD';
    }
    final parts = v.split('-');
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return 'Enter a valid date';
    final dt = DateTime(y, m, d);
    if (dt.year != y || dt.month != m || dt.day != d) {
      return 'Enter a valid date';
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (dt.isAfter(todayDate)) return 'Date cannot be in the future';
    if (today.year - y > 120) return 'Please check the year';
    return null;
  }

  /// Phone with spaces, dashes, or country code; 7–15 digits required.
  static String? validatePersonPhoneFlexible(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number (10–15 digits)';
    }
    return null;
  }

  /// Validates mobile number (10 digits)
  static String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (!_phonePattern.hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  /// Validate Email OR Mobile Number
  static String? validateEmailOrMobile(String? value) {
    // First check if empty
    final fieldName = 'Email or phone number';
    final emptyCheck = Validator.validateEmpty(value, fieldName);
    if (emptyCheck != null) return emptyCheck;

    final input = value!.trim();

    if (input.contains('@')) {
      return Validator.validateEmail(input);
    }

    final phoneCheck = Validator.validateMobile(input);
    if (phoneCheck != null) return phoneCheck;

    return null;
  }

  /// Validates username (alphanumeric, 3-20 characters)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validates password (min 6 characters, at least one letter and one number)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    // Optional: Add complexity requirement
    // final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    // if (!passwordRegex.hasMatch(value)) {
    //   return 'Password must contain at least one letter and one number';
    // }
    return null;
  }

  /// Validates if field is not empty
  static String? validateEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
