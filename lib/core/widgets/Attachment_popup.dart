import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttachmentPopup extends StatelessWidget {
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;

  const AttachmentPopup({super.key, this.onImageTap, this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 180.w,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _item(
                  icon: Icons.image_outlined,
                  label: "Image/Video",
                  onTap: onImageTap,
                ),
                Divider(),
                _item(
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
                  onTap: onCameraTap,
                ),
              ],
            ),
          ),

          /// Arrow Pointer
          Positioned(
            bottom: -10,
            left: 60.w,
            child: CustomPaint(size: Size(20, 10), painter: _ArrowPainter()),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: Colors.black87),
            12.w.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Arrow painter
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 4, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
