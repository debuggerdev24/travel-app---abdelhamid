import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/utils/payment_flow_log.dart';

/// Backend: `POST /api/payment/create-payment-intent` (Bearer auth).
class PaymentService {
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  static String get _createIntentUrl =>
      '${AppConstants.apiPublicRoot}/payment/create-payment-intent';

  /// [amount] is in major currency units (e.g. euros), matching the backend.
  Future<({String clientSecret, String? paymentId})> createPaymentIntent({
    required String bookingId,
    required double amount,
    String currency = 'eur',
    List<String>? paymentMethodTypes,
  }) async {
    final body = <String, dynamic>{
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
    };
    if (paymentMethodTypes != null && paymentMethodTypes.isNotEmpty) {
      body['paymentMethodTypes'] = paymentMethodTypes;
    }
    PaymentFlowLog.log('createPaymentIntent → POST', {
      'url': _createIntentUrl,
      'bookingId': bookingId,
      'amount': amount,
      'currency': currency,
      'paymentMethodTypes': paymentMethodTypes?.join(',') ?? '(default)',
    });
    final response = await BaseApiService.instance.post(
      _createIntentUrl,
      body: body,
      showErrorToast: true,
    );
    PaymentFlowLog.log('createPaymentIntent ← response', {
      'status': response['status'],
      'message': response['message']?.toString(),
      'hasData': response['data'] != null,
    });
    if (response['status'] != 1 || response['data'] == null) {
      PaymentFlowLog.log('createPaymentIntent FAILED (bad status or data)');
      throw Exception(response['message']?.toString() ?? 'Payment setup failed');
    }
    final data = Map<String, dynamic>.from(response['data'] as Map);
    final secret = data['clientSecret']?.toString();
    if (secret == null || secret.isEmpty) {
      PaymentFlowLog.log('createPaymentIntent FAILED (no clientSecret)');
      throw Exception('Missing payment client secret');
    }
    final paymentId = data['paymentId']?.toString();
    PaymentFlowLog.log('createPaymentIntent OK', {
      'paymentId': paymentId ?? '(null)',
      'clientSecret': PaymentFlowLog.maskClientSecret(secret),
    });
    return (
      clientSecret: secret,
      paymentId: paymentId,
    );
  }
}
