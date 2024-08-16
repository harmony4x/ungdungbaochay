import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // request notification permission
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  static Future<String?> getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  // initalize local notifications
  static Future localNotiInit({String? imageUrl}) async {
    BigPictureStyleInformation? bigPictureStyleInformation;

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap, onDidReceiveBackgroundNotificationResponse: onNotificationTap);
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      Map<String, dynamic> data = jsonDecode(notificationResponse.payload!);

      String imageUrl = data['imageUrl'];

      // Điều hướng đến Trang Chủ với URL hình ảnh
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => MyHomePage(imageUrl: imageUrl),
        ),
      );
    }
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
    String? imageUrl, // Thêm tham số này để nhận URL hình ảnh
  }) async {
    BigPictureStyleInformation? bigPictureStyleInformation;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        contentTitle: title,
        summaryText: body,
      );
    }
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: bigPictureStyleInformation, // Sử dụng BigPictureStyleInformation để hiển thị hình ảnh
    );

    // iOS settings
    const DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true, // Hiển thị thông báo dưới dạng alert.
      presentBadge: true, // Hiển thị badge thông báo.
      presentSound: true, // Phát âm thanh thông báo.
      // Thêm bất kỳ cấu hình nào khác phù hợp với ứng dụng của bạn
    );

    // Tổng hợp cài đặt cho cả hai nền tảng
    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iOSNotificationDetails);
    print('Sending notification with image URL: $imageUrl'); // Log ra URL hình ảnh

    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: payload);
  }
}
