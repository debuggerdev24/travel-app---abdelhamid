class AppConstants {
  static const String baseUrl = 'http://192.168.1.34:3000/api/user';
  // Base URL for loading public assets like `/uploads/<file>`
  static const String imageBaseUrl = 'http://192.168.1.34:3000';

  /// CMS routes live under `/api` (not `/api/user`). Use with paths like `/faq/get-faqs`.
  static String get apiPublicRoot => '$imageBaseUrl/api';
}
