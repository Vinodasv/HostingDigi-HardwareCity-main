import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestPermission();
    }
  }
}
