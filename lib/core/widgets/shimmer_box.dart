import 'package:flutter/material.dart';

/// Tiny shimmer without dependencies (used for loading placeholders).
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        // Move highlight from left to right.
        final begin = Alignment(-1.0 - 0.6 + (t * 2.2), 0);
        final end = Alignment(1.0 - 0.6 + (t * 2.2), 0);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : (widget.borderRadius ?? BorderRadius.circular(12)),
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}

