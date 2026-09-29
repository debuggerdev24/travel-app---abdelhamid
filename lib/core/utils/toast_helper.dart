import 'package:travel_app_abdelhamid/core/widgets/toast_service.dart';

class ToastHelper {
  ToastHelper._internal();

  static void showSuccess(String message) => ToastService.showSuccess(message);

  static void showError(String message) => ToastService.showError(message);

  static void showInfo(String message) => ToastService.showInfo(message);

  static void dismiss() => ToastService.dismiss();
}
