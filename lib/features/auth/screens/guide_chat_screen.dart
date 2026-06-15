import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class GuideChatScreen extends StatefulWidget {
  const GuideChatScreen({super.key});

  @override
  State<GuideChatScreen> createState() => _GuideChatScreenState();
}

class _GuideChatScreenState extends State<GuideChatScreen> {
  bool _showTracking = false;
  int _selectedTab = 0;
  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};

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
    {
      'name': 'Group A (5 members)',
      'location': 'Tour Bus Stop',
      'status': 'Together',
      'lastSeen': '20 min ago',
      'isOnline': true,
      'lat': 21.4200,
      'lng': 39.8280,
      'image': AppAssets.profilePhoto,
    },
    {
      'name': 'Family Trip (8 members)',
      'location': 'Museum Entrance',
      'status': 'Together',
      'lastSeen': '25 min ago',
      'isOnline': true,
      'lat': 21.4150,
      'lng': 39.8240,
      'image': AppAssets.profilePhoto,
    },
  ];

  // Local message storage for static chats
  static final Map<String, List<Map<String, dynamic>>> _localMessages = {
    'chat_1': [
      {
        '_id': 'msg_1',
        'isMe': false,
        'type': 'text',
        'message': 'When is the next tour starting?',
        'sender': 'Ahmed Mohamed',
        'time': '10:30 AM',
        'edited': false,
      },
    ],
    'chat_2': [
      {
        '_id': 'msg_2',
        'isMe': false,
        'type': 'text',
        'message': 'Thank you for the guidance!',
        'sender': 'Sarah Johnson',
        'time': '9:15 AM',
        'edited': false,
      },
    ],
    'chat_3': [
      {
        '_id': 'msg_3',
        'isMe': false,
        'type': 'text',
        'message': 'Meeting point confirmed',
        'sender': 'Group A Travelers',
        'time': '8:00 AM',
        'edited': false,
      },
    ],
    'chat_4': [
      {
        '_id': 'msg_4',
        'isMe': false,
        'type': 'text',
        'message': 'Can you recommend a restaurant?',
        'sender': 'Omar Hassan',
        'time': 'Yesterday',
        'edited': false,
      },
    ],
    'chat_5': [
      {
        '_id': 'msg_5',
        'isMe': false,
        'type': 'text',
        'message': 'We\'re ready for tomorrow\'s tour',
        'sender': 'Family Trip Group',
        'time': 'Yesterday',
        'edited': false,
      },
    ],
  };

  // Sample chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'chatId': 'chat_1',
      'name': 'Ahmed Mohamed',
      'message': 'When is the next tour starting?',
      'time': '2 min ago',
      'unread': 2,
      'isGroup': false,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_2',
      'name': 'Sarah Johnson',
      'message': 'Thank you for the guidance!',
      'time': '15 min ago',
      'unread': 0,
      'isGroup': false,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_3',
      'groupId': 'group_1',
      'name': 'Group A Travelers',
      'message': 'Meeting point confirmed',
      'time': '1 hour ago',
      'unread': 5,
      'isGroup': true,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_4',
      'name': 'Omar Hassan',
      'message': 'Can you recommend a restaurant?',
      'time': '3 hours ago',
      'unread': 0,
      'isGroup': false,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_5',
      'groupId': 'group_2',
      'name': 'Family Trip Group',
      'message': 'We\'re ready for tomorrow\'s tour',
      'time': '5 hours ago',
      'unread': 1,
      'isGroup': true,
      'image': '',
      'avatarUrl': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    // Listen to ChatProvider for message updates in local chats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().addListener(_onChatProviderUpdate);
    });
  }

  @override
  void dispose() {
    context.read<ChatProvider>().removeListener(_onChatProviderUpdate);
    super.dispose();
  }

  void _onChatProviderUpdate() {
    // Sync messages back to local storage when they change
    final chatProvider = context.read<ChatProvider>();
    final activeChatId = chatProvider.activeChatId;
    if (activeChatId != null && _localMessages.containsKey(activeChatId)) {
      _localMessages[activeChatId] = List.from(chatProvider.messages);
    }
  }

  /// Load markers for all travelers
  Future<void> _loadMarkers() async {
    for (int i = 0; i < _travelers.length; i++) {
      final traveler = _travelers[i];
      final markerIcon = await _createCustomMarker(
        traveler['name'],
        traveler['image'],
        traveler['isOnline'] ? Colors.green : Colors.grey,
      );

      setState(() {
        _markers.add(
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
      });
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
            20.h.verticalSpace,
            _buildHeader(),
            16.h.verticalSpace,
            _buildModeToggle(),
            16.h.verticalSpace,
            if (!_showTracking) _buildTabs(),
            if (!_showTracking) 16.h.verticalSpace,
            Expanded(
              child: _showTracking ? _buildTrackingView() : _buildChatView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          24.w.horizontalSpace,
          AppText(
            textAlign: TextAlign.center,
            text: _showTracking ? "Tracking" : "Chat",
            style: textStyle16SemiBold.copyWith(
              fontSize: 26.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Icon(
            _showTracking ? Icons.map_outlined : Icons.search,
            size: 24.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(130.r),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showTracking = false;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: !_showTracking
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Center(
                    child: AppText(
                      text: "Chat",
                      style: textStyle14Medium.copyWith(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: !_showTracking
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showTracking = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: _showTracking
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Center(
                    child: AppText(
                      text: "Track Travelers",
                      style: textStyle14Medium.copyWith(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: _showTracking
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 27.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(130.r),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _tabItem("All", 0),
          _tabItem("Groups", 1),
          _tabItem("Direct", 2),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final bool isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: AppText(
              text: label,
              style: textStyle14Medium.copyWith(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: _chats.length,
      separatorBuilder: (context, index) => 20.h.verticalSpace,
      itemBuilder: (context, index) {
        return _buildChatItem(
          chatId: _chats[index]['chatId'],
          groupId: _chats[index]['groupId'],
          name: _chats[index]['name'],
          message: _chats[index]['message'],
          time: _chats[index]['time'],
          unread: _chats[index]['unread'],
          isGroup: _chats[index]['isGroup'],
          image: _chats[index]['image'],
          avatarUrl: _chats[index]['avatarUrl'],
        );
      },
    );
  }

  Widget _buildTrackingView() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AppText(
            text: "Traveler Locations",
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        16.h.verticalSpace,
        Expanded(
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(21.4225, 39.8262), // Mecca coordinates
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
        ),
      ],
    );
  }

  void _openChat({
    required String chatId,
    String? groupId,
    required String name,
    required String image,
    String? avatarUrl,
    required bool isGroup,
  }) {
    final chatProvider = context.read<ChatProvider>();

    // Initialize local messages if not exists
    if (!_localMessages.containsKey(chatId)) {
      _localMessages[chatId] = [];
    }

    // Load local messages into ChatProvider
    chatProvider.loadLocalMessages(chatId, _localMessages[chatId]!);

    final extra = <String, dynamic>{
      'chatId': chatId,
      'groupId': groupId,
      'name': name,
      'image': image,
      'avatarUrl': avatarUrl,
      'isGroup': isGroup,
      'isLocalChat': true, // Flag to indicate this is a local/static chat
    };
    chatProvider.primeChatOpen(chatId);
    context.pushNamed(UserAppRoutes.chatDetailScreen.name, extra: extra);
  }

  Widget _buildChatItem({
    required String chatId,
    String? groupId,
    required String name,
    required String message,
    required String time,
    required int unread,
    required bool isGroup,
    required String image,
    String? avatarUrl,
  }) {
    final hasUnread = unread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openChat(
            chatId: chatId,
            groupId: groupId,
            name: name,
            image: image,
            avatarUrl: avatarUrl,
            isGroup: isGroup,
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              child: Icon(
                isGroup ? Icons.group : Icons.person,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24.sp,
              ),
            ),
            15.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: name,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle18Bold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      AppText(
                        text: time,
                        style: textStyle14Regular.copyWith(
                          color: hasUnread
                              ? AppColors.blueColor
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  2.h.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: message,
                          style: textStyle14Regular.copyWith(
                            color: hasUnread
                                ? Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.75)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 22.w,
                            minHeight: 22.w,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: unread > 9 ? 7.w : 6.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            text: unread > 99 ? '99+' : '$unread',
                            style: textStyle18Bold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
