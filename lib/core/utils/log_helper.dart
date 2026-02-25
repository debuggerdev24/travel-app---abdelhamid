import 'package:flutter/foundation.dart';

class LogHelper {
  LogHelper._internal();

  static final LogHelper instance = LogHelper._internal();

  void debug(String message) {
    if (kDebugMode) {
      debugPrint("🔍 [DEBUG]: $message");
    }
  }

  void info(String message) {
    if (kDebugMode) {
      debugPrint("ℹ️ [INFO]: $message");
    }
  }

  void success(String message) {
    if (kDebugMode) {
      debugPrint("✅ [SUCCESS]: $message");
    }
  }

  void warning(String message) {
    if (kDebugMode) {
      debugPrint("⚠️ [WARNING]: $message");
    }
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint("❌ [ERROR]: $message");
      if (error != null) debugPrint("   Details: $error");
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}
