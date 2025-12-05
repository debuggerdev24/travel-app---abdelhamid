import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MessageType { text, location }

class ChatMessage {
  final MessageType type;
  final String? text;
  final LatLng? location;
  final String time;

  ChatMessage({
    required this.type,
    this.text,
    this.location,
    required this.time,
  });
}