import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  LatLng currentLocation = const LatLng(47.6062, -122.3321);

  Set<Marker> markers = {};

  BitmapDescriptor? userIconRed;
  BitmapDescriptor? userIconGreen;

  @override
  void initState() {
    super.initState();
    loadMarkerImages();
  }

  /// 🔥 Create circular marker with border (like CircleAvatar)
  Future<BitmapDescriptor> createCircularMarker(
    String assetPath, {
    int size = 120,
    Color borderColor = Colors.white,
    double borderWidth = 8,
  }) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: size,
      targetHeight: size,
    );

    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final double radius = size / 2;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    /// Clip image in circle shape
    final Path clipPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(radius, radius), radius: radius));

    canvas.clipPath(clipPath);

    /// Draw user profile image
    canvas.drawImage(image, Offset(0, 0), Paint());

    /// Draw circle border
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    final ui.Image finalImage =
        await recorder.endRecording().toImage(size, size);

    final ByteData? pngBytes =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
  }

  /// 🔥 Load custom circular markers
  Future<void> loadMarkerImages() async {
    userIconRed = await createCircularMarker(
      AppAssets.profilephoto,
      size: 80,
      borderColor:AppColors.redColor,
      borderWidth: 4,
    );

    userIconGreen = await createCircularMarker(
      AppAssets.profilephoto,
      size: 80,
      borderColor: Colors.green,
      borderWidth: 4,
    );

    setState(() {
      markers.addAll([
        Marker(
          markerId: const MarkerId("user1"),
          position: const LatLng(47.4104, -122.3000),
          icon: userIconRed!,
        ),
        Marker(
          markerId: const MarkerId("user2"),
          position: const LatLng(47.3820, -122.2300),
          icon: userIconGreen!,
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.w),
                    ),
                  ),
                  AppText(
                    text: "Live Location",
                    style: textStyle32Bold.copyWith(
                      fontSize: 24.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation,
                  zoom: 10.5,
                ),
                markers: markers,
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),

            /// Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
              child: AppButton(
  title: "Share My Location",
  onTap: () {
    context.pop({
      "lat": currentLocation.latitude,
      "lng": currentLocation.longitude,
    });
  },
),

            ),
          ],
        ),
      ),
    );
  }
}
