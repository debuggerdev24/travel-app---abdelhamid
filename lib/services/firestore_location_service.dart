import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';

class FirestoreLocationService {
  FirestoreLocationService._internal();
  static final FirestoreLocationService instance = FirestoreLocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStream;

  /// Start tracking and periodically updating location to Firestore
  Future<void> startTracking({
    required String chatId,
    required String userId,
    required String name,
    required String image,
  }) async {
    try {
      // 1. Request permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        LogHelper.instance.debug('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          LogHelper.instance.debug('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        LogHelper.instance.debug('Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      // 2. Start listening to location updates
      _positionStream?.cancel();
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _updateLocationInFirestore(
          chatId: chatId,
          userId: userId,
          name: name,
          image: image,
          lat: position.latitude,
          lng: position.longitude,
        );
      });
      
      // Also get initial position immediately
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocationInFirestore(
        chatId: chatId,
        userId: userId,
        name: name,
        image: image,
        lat: initialPosition.latitude,
        lng: initialPosition.longitude,
      );
      
    } catch (e) {
      LogHelper.instance.debug('Error starting location tracking: $e');
    }
  }

  void _updateLocationInFirestore({
    required String chatId,
    required String userId,
    required String name,
    required String image,
    required double lat,
    required double lng,
  }) {
    _firestore
        .collection('chat_locations')
        .doc(chatId)
        .collection('users')
        .doc(userId)
        .set({
      'name': name,
      'image': image,
      'lat': lat,
      'lng': lng,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).catchError((e) {
      LogHelper.instance.debug('Failed to update location: $e');
    });
  }

  /// Stop tracking and clean up
  Future<void> stopTracking(String chatId, String userId) async {
    await _positionStream?.cancel();
    _positionStream = null;
    
    try {
      await _firestore
          .collection('chat_locations')
          .doc(chatId)
          .collection('users')
          .doc(userId)
          .update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LogHelper.instance.debug('Failed to stop location tracking: $e');
    }
  }

  /// Stream travelers in a chat for the UI
  Stream<List<Map<String, dynamic>>> streamTravelers(String chatId) {
    return _firestore
        .collection('chat_locations')
        .doc(chatId)
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['userId'] = doc.id;
        return data;
      }).toList();
    });
  }
}
