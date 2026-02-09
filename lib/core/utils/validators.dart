class Validator {
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
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
