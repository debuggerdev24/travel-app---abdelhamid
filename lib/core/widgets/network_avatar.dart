import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_image_with_shimmer.dart';

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

    final Widget content = (url != null && url.isNotEmpty)
        ? NetworkImageWithShimmer(
            imageUrl: url,
            size: size,
            fit: BoxFit.cover,
            shape: BoxShape.circle,
            errorWidget: _fallbackContent(size),
          )
        : _fallbackContent(size);

    return ClipOval(
      child: SizedBox(width: size, height: size, child: content),
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

