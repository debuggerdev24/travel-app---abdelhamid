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

  // Sample traveler data with coordinates (Mecca area coordinates)
  final List<Map<String, dynamic>> _travelers = [
    {
      'name': 'Ahmed Mohamed',
      'location': 'Near Grand Mosque',
      'status': 'Active',
      'lastSeen': '2 min ago',
      'isOnline': true,
      'lat': 21.4225,
      'lng': 39.8262,
      'image': AppAssets.profilePhoto,
    },
    {
      'name': 'Sarah Johnson',
      'location': 'Hotel Lobby',
      'status': 'Active',
      'lastSeen': '5 min ago',
      'isOnline': true,
      'lat': 21.4250,
      'lng': 39.8300,
      'image': AppAssets.profilePhoto,
    },
    {
      'name': 'Omar Hassan',
      'location': 'Restaurant Area',
      'status': 'Active',
      'lastSeen': '10 min ago',
      'isOnline': true,
      'lat': 21.4180,
      'lng': 39.8220,
      'image': AppAssets.profilePhoto,
    },
    {
      'name': 'Fatima Ali',
      'location': 'Shopping District',
      'status': 'Active',
      'lastSeen': '15 min ago',
      'isOnline': false,
      'lat': 21.4280,
      'lng': 39.8350,
      'image': AppAssets.profilePhoto,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  List<Map<String, dynamic>> get _displayTravelers {
    if (widget.isGroup) {
      return _travelers;
    } else {
      // For a direct chat, show only one traveler (the one we are chatting with)
      return [
        {
          'name': widget.name,
          'location': 'Near Grand Mosque',
          'status': 'Active',
          'lastSeen': 'Just now',
          'isOnline': true,
          'lat': 21.4225,
          'lng': 39.8262,
          'image': AppAssets.profilePhoto,
        }
      ];
    }
  }

  /// Load markers for all travelers
  Future<void> _loadMarkers() async {
    final travelersToDisplay = _displayTravelers;
    for (int i = 0; i < travelersToDisplay.length; i++) {
      final traveler = travelersToDisplay[i];
      final markerIcon = await _createCustomMarker(
        traveler['name'],
        traveler['image'],
        traveler['isOnline'] ? Colors.green : Colors.grey,
      );

      if (!mounted) return;
      context.read<TrackTravelersState>().addMarker(
        Marker(
          markerId: MarkerId('traveler_$i'),
          position: LatLng(traveler['lat'], traveler['lng']),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: traveler['name'],
            snippet: traveler['location'],
          ),
        ),
      );
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
