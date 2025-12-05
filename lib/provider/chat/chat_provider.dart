import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/enums/chat_enum.dart';
import 'package:trael_app_abdelhamid/model/chat/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  int selectedTabIndex = 0;
  List<ChatMessage> chatDetailList = [];

  void sendTextMessage(String text) {
    chatDetailList.add(
      ChatMessage(
        type: MessageType.text,
        text: text,
        time: "Now",
      ),
    );
    notifyListeners();
  }

  void sendLocationMessage({required double lat, required double lng}) {
    chatDetailList.add(
      ChatMessage(
        type: MessageType.location,
        location: LatLng(lat, lng),
        time: "Now",
      ),
    );
    notifyListeners();
  }
  void addLocationMessage({required double lat, required double lng}) {
  messages.add({
    "type": "location",
    "lat": lat,
    "lng": lng,
    "isMe": true,
    "time": "${DateTime.now().hour}:${DateTime.now().minute}",
  });

  notifyListeners();
}


  final List<ChatModel> _chatList = [
    ChatModel(
      name: 'Umrah Trip 2025',
      message: 'See you at hotel lobby at 5 PM',
      time: '10.20 AM',
      unread: 3,
      image: AppAssets.profilephoto,
      isGroup: true,
    ),
    ChatModel(
      name: 'Ahmed Khan - Guide',
      message: 'Your transport is ready',
      time: 'Yesterday',
      unread: 2,
      image: AppAssets.profilephoto,
      isGroup: false,
    ),
    ChatModel(
      name: 'Travel Agency Support',
      message: 'Invoice has been mailed',
      time: '22 Sep',
      unread: 0,
      image: AppAssets.profilephoto,
      isGroup: false,
    ),
    ChatModel(
      name: 'Ali Mohammed',
      message: 'Shall we meet after dinner?',
      time: '21 Sep',
      unread: 0,
      image: AppAssets.profilephoto,
      isGroup: false,
    ),
  ];

  List<ChatModel> get chatList {
    if (selectedTabIndex == 0) return _chatList;
    if (selectedTabIndex == 1) {
      return _chatList.where((c) => c.isGroup).toList();
    }
    return _chatList.where((c) => !c.isGroup).toList();
  }


  void changeTab(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }
   final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'message': 'Salam, what time is Ziyarat tomorrow?',
      'time': '10:22 AM',
      'sender': 'Noha Khan',
      'type': 'text',
    },
    {
      'isMe': false,
      'message': 'Wa Alaikum Salam, 9 AM sharp.',
      'time': '10:30 AM',
      'sender': 'Ahmed Khan-Guide',
      'type': 'text',
    },
    {
      'isMe': false,
      'message': 'Should we carry passport?',
      'time': '10:22 AM',
      'sender': 'Noha Khan',
      'type': 'text',
    },
    {
      'isMe': false,
      'message': 'Yes, always carry ID.',
      'time': '10:35 AM',
      'sender': 'Ahmed Khan-Guide',
      'type': 'text',
    },
    {
      'isMe': true,
      'message': '',
      'time': '10:35 AM',
      'sender': 'Me',
      'type': 'audio',
      'duration': '00:18',
    },
  ];

  bool _isRecording = false;
  bool _showAttachmentMenu = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isRecording => _isRecording;
  bool get showAttachmentMenu => _showAttachmentMenu;

  void toggleRecording() {
    _isRecording = !_isRecording;
    notifyListeners();
  }
  void startRecording() {
    _isRecording = true;
    _showAttachmentMenu = false;
    notifyListeners();
  }


  void stopRecording() {
    _isRecording = false;
    notifyListeners();
  }

  void toggleAttachmentMenu() {
    _showAttachmentMenu = !_showAttachmentMenu;
    notifyListeners();
  }

  void closeAttachmentMenu() {
    _showAttachmentMenu = false;
    notifyListeners();
  }

  void addMessage(Map<String, dynamic> msg) {
    _messages.add(msg);
    notifyListeners();
  }
}
