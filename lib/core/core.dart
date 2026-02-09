/// Barrel file for core app-wide code.
/// Use for: constants, theme, enums. Widgets are imported directly to avoid circular deps.
library;

export 'constants/app_assets.dart';
export 'constants/app_colors.dart';
export 'constants/text_style.dart';
export 'extensions/routes_extensions.dart';
export 'enums/chat_enum.dart';
export 'enums/payment_option_enum.dart';
export 'theme/app_theme.dart';
export 'utils/validators.dart';
export 'utils/pref_helper.dart';
