import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';

/// Cached network image with a shimmer placeholder.
/// Pass [size] to use the same value for width and height, or set them separately.
class NetworkImageWithShimmer extends StatelessWidget {
  const NetworkImageWithShimmer({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.errorWidget,
    this.errorIcon = Icons.broken_image,
  });

  final String imageUrl;
  final double? width;
  final double? height;

  /// Sets both width and height when they should match.
  final double? size;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Widget? errorWidget;
  final IconData errorIcon;

  double? get _width => size ?? width;
  double? get _height => size ?? height;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    final w = _width;
    final h = _height;

    final Widget image = url.isEmpty
        ? (errorWidget ?? _errorBox(context, w, h))
        : CachedNetworkImage(
            imageUrl: url,
            width: w,
            height: h,
            fit: fit,
            placeholder: (_, __) => _shimmer(w, h),
            errorWidget: (_, __, ___) =>
                errorWidget ?? _errorBox(context, w, h),
          );

    if (shape == BoxShape.circle) {
      return ClipOval(
        child: SizedBox(width: w, height: h, child: image),
      );
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _shimmer(double? w, double? h) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: w,
        height: h ?? 120,
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
          shape: shape,
          borderRadius: shape == BoxShape.circle
              ? null
              : (borderRadius ?? BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _errorBox(BuildContext context, double? w, double? h) {
    return Container(
      width: w,
      height: h ?? 120,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        errorIcon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
