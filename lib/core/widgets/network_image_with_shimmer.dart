import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/widgets/shimmer_box.dart';

/// Network image with a [ShimmerBox] placeholder until the first frame loads.
class NetworkImageWithShimmer extends StatelessWidget {
  const NetworkImageWithShimmer({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.broken_image,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    if (url.isEmpty) {
      return _errorPlaceholder();
    }

    Widget image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _shimmerPlaceholder();
      },
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _shimmerPlaceholder() {
    final h = height ?? 120;
    if (width != null && width!.isFinite) {
      return ShimmerBox(
        width: width!,
        height: h,
        borderRadius: borderRadius,
      );
    }
    return SizedBox(
      height: h,
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : 300.0;
          return ShimmerBox(
            width: w,
            height: h,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      width: width,
      height: height ?? 120,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(errorIcon, color: Colors.grey.shade600),
    );
  }
}
