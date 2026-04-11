class AppConstants {
  // static const String baseUrl = 'http://192.168.1.63:3000/api/user';
  // // Base URL for loading public assets like `/uploads/<file>`
  // static const String imageBaseUrl = 'http://192.168.1.63:3000';

  static const String baseUrl = 'https://rebecca-phosphoreted-vanishingly.ngrok-free.dev/api/user'; 
  // Base URL for loading public assets like `/uploads/<file>`
  static const String imageBaseUrl = 'https://rebecca-phosphoreted-vanishingly.ngrok-free.dev';

  /// Socket.IO server for real-time chat (often LAN while REST uses ngrok).
  static const String chatSocketBaseUrl = 'ws://192.168.1.72:3000';

  /// CMS routes live under `/api` (not `/api/user`). Use with paths like `/faq/get-faqs`.
  static String get apiPublicRoot => '$imageBaseUrl/api';

  /// Stripe publishable key (`pk_test_...` / `pk_live_...`) from the Stripe Dashboard.
  /// Required for Trip tab payments. Must match the backend `STRIPE_SECRET_KEY` account.
  static const String stripePublishableKey = 'pk_test_51T8DpiFA4xtxQFB07XGPbbs3HbfHs50mq10QDYOxMLL5ArTZfDYjYOG4eNspJCOzUiqZv5utzBD9bZm12zLyiQBV009gcCCoSU';

  /// ISO country for Google Pay / Apple Pay (e.g. NL, FR, DE).
  static const String stripeMerchantCountryCode = 'NL';

  /// Apple Pay merchant ID from Apple Developer (e.g. `merchant.com.your.app`).
  /// Required on iOS for `PlatformPayButton` / Apple Pay; leave empty until configured.
  static const String stripeApplePayMerchantId = '';
}
