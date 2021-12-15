import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class LocalNotifyManager {
  var initSetting;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceiveNotification>();
  LocalNotifyManager() : super();
  LocalNotifyManager localNotifyManager = new LocalNotifyManager();
  LocalNotifyManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      requestIOSPermission();
    }
    initializePlatform();
  }

  requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(alert: true, badge: true, sound: true);
  }

  initializePlatform() {
    var initSettingAndroid =
        AndroidInitializationSettings('app_notification_icon');
    var initSettingIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          ReceiveNotification notification = ReceiveNotification(
              id: id,
              title: title.toString(),
              body: body.toString(),
              payload: payload.toString());
          didReceiveLocalNotificationSubject.add(notification);
        });
    initSetting = InitializationSettings(
        android: initSettingAndroid, iOS: initSettingIOS);
  }

  setOnNotificationReceive(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSetting);
  }

  Future<void> showNotification() async {
    var androidChannel = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME', 'CHANNEL_DESCRIPTION',
        importance: Importance.max, priority: Priority.high, playSound: true);
    var iosChannel = IOSNotificationDetails();
    var platformChannel =
        NotificationDetails(android: androidChannel, iOS: iosChannel);
    await flutterLocalNotificationsPlugin.show(
        0, 'Hey There', 'Your cart is waiting for you!', platformChannel,
        payload: 'new payload');
  }

  Future<void> showCartNotification() async {
    var time = DateTime.now().add(Duration(minutes: 5));
    var androidChannel = AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME', 'CHANNEL_DESCRIPTION',
        importance: Importance.max, priority: Priority.high, playSound: true);
    var iosChannel = IOSNotificationDetails();
    var platformChannel =
        NotificationDetails(android: androidChannel, iOS: iosChannel);
    await flutterLocalNotificationsPlugin.schedule(
        0, 'Hey There', 'Your cart is waiting for you!', time, platformChannel,
        payload: 'new payload');
  }
}

LocalNotifyManager localNotifyManager = LocalNotifyManager.init();

class ReceiveNotification {
  final int? id;
  final String? title;
  final String? body;
  final String? payload;

  ReceiveNotification(
      {@required this.id,
      @required this.title,
      @required this.body,
      @required this.payload});
}
