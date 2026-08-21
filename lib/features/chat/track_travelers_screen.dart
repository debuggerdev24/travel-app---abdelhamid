import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/services/firestore_location_service.dart';
import 'package:travel_app_abdelhamid/core/utils/jwt_user_id.dart';

class TrackTravelersState extends ChangeNotifier {
  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  void addMarker(Marker marker) {
    _markers.add(marker);
    notifyListeners();
  }
}

class TrackTravelersScreen extends StatelessWidget {
  final String chatId;
  final String? groupId;
  final String name;
  final bool isGroup;

  const TrackTravelersScreen({
    super.key,
    required this.chatId,
    this.groupId,
    required this.name,
    this.isGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackTravelersState(),
      child: _TrackTravelersView(
        chatId: chatId,
        groupId: groupId,
        name: name,
        isGroup: isGroup,
      ),
    );
  }
}

class _TrackTravelersView extends StatefulWidget {
  final String chatId;
  final String? groupId;
  final String name;
  final bool isGroup;

  const _TrackTravelersView({
    required this.chatId,
    this.groupId,
    required this.name,
    required this.isGroup,
  });

  @override
  State<_TrackTravelersView> createState() => _TrackTravelersViewState();
}

class _TrackTravelersViewState extends State<_TrackTravelersView> {
  final Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription<List<Map<String, dynamic>>>? _locationSub;
  final String _currentUserId = currentUserIdOrNull() ?? '';

  @override
  void initState() {
    super.initState();
    _startTracking();
    _listenToTravelers();
  }

  Future<void> _startTracking() async {
    if (_currentUserId.isEmpty) return;
    await FirestoreLocationService.instance.startTracking(
      chatId: widget.chatId,
      userId: _currentUserId,
      name: 'Me', // We could fetch actual current user name/image from profile, using placeholders for now
      image: AppAssets.profilePhoto,
    );
  }

  void _listenToTravelers() {
    _locationSub = FirestoreLocationService.instance
        .streamTravelers(widget.chatId)
        .listen((travelers) {
      _updateMarkers(travelers);
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    if (_currentUserId.isNotEmpty) {
      FirestoreLocationService.instance.stopTracking(widget.chatId, _currentUserId);
    }
    super.dispose();
  }

  Future<void> _updateMarkers(List<Map<String, dynamic>> travelers) async {
    final newMarkers = <Marker>{};

    for (int i = 0; i < travelers.length; i++) {
      final traveler = travelers[i];
      // Skip showing current user's marker if myLocationEnabled takes care of it,
      // but showing it as a custom marker is also fine.
      final markerIcon = await _createCustomMarker(
        traveler['name'] ?? 'Unknown',
        traveler['image'] ?? AppAssets.profilePhoto,
        (traveler['isOnline'] == true) ? Colors.green : Colors.grey,
      );

      if (!mounted) return;
      newMarkers.add(
        Marker(
          markerId: MarkerId(traveler['userId'] ?? 'traveler_$i'),
          position: LatLng(traveler['lat'], traveler['lng']),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: traveler['name'] ?? 'Unknown',
          ),
        ),
      );
    }
    
    if (!mounted) return;
    final state = context.read<TrackTravelersState>();
    state.markers.clear();
    for (var m in newMarkers) {
      state.addMarker(m);
    }
  }

  /// Create custom marker with traveler image and name
  Future<BitmapDescriptor> _createCustomMarker(
    String name,
    String imagePath,
    Color statusColor,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const markerSize = 120.0;
    const imageSize = 80.0;
    const radius = imageSize / 2;

    // Draw pin background
    final pinPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(markerSize / 2, markerSize);
    path.lineTo(markerSize / 2 - 30, markerSize - 40);
    path.quadraticBezierTo(
      markerSize / 2 - 30,
      markerSize / 2 - 20,
      markerSize / 2,
      markerSize / 2 - 20,
    );
    path.quadraticBezierTo(
      markerSize / 2 + 30,
      markerSize / 2 - 20,
      markerSize / 2 + 30,
      markerSize - 40,
    );
    path.close();
    canvas.drawPath(path, pinPaint);

    // Draw white circle for image
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(markerSize / 2, markerSize / 2 - 10),
      radius,
      circlePaint,
    );

    // Draw traveler image (using a placeholder circle for now)
    final imagePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(markerSize / 2, markerSize / 2 - 10),
      radius - 4,
      imagePaint,
    );

    // Draw person icon
    final iconPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    final iconPath = Path();
    // Simple person icon
    iconPath.addOval(
      Rect.fromCircle(
        center: Offset(markerSize / 2, markerSize / 2 - 25),
        radius: 12,
      ),
    );
    canvas.drawPath(iconPath, iconPaint);

    final bodyPath = Path();
    bodyPath.addOval(
      Rect.fromCircle(
        center: Offset(markerSize / 2, markerSize / 2 + 5),
        radius: 18,
      ),
    );
    canvas.drawPath(bodyPath, iconPaint);

    // Draw name text
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(maxWidth: markerSize - 20);
    textPainter.paint(
      canvas,
      Offset((markerSize - textPainter.width) / 2, markerSize - 35),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(markerSize.toInt(), markerSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  AppText(
                    text: "Track ${widget.name}",
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
                initialCameraPosition: const CameraPosition(
                  target: LatLng(21.4225, 39.8262), // Mecca coordinates
                  zoom: 14,
                ),
                markers: context.watch<TrackTravelersState>().markers,
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
