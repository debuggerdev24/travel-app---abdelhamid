import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/widgets/shimmer_box.dart';

enum AvatarFallbackKind {
  user,
  group,
}

class NetworkAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final AvatarFallbackKind fallbackKind;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.fallbackKind = AvatarFallbackKind.user,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final url = imageUrl?.trim();

    Widget content;
    if (url != null && url.isNotEmpty) {
      content = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ShimmerBox(
            width: size,
            height: size,
            shape: BoxShape.circle,
          );
        },
        errorBuilder: (_, __, ___) => _fallbackContent(size),
      );
    } else {
      content = _fallbackContent(size);
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: content,
      ),
    );
  }

  Widget _fallbackContent(double size) {
    if (fallbackKind == AvatarFallbackKind.group) {
      return ColoredBox(
        color: AppColors.lightblueColor,
        child: Center(
          child: Icon(
            Icons.groups_rounded,
            size: radius * 1.15,
            color: AppColors.primaryColor.setOpacity(0.65),
          ),
        ),
      );
    }
    return Image.asset(
      AppAssets.profilePhoto,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}
