import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
      print("Payload data: $data");

      // Kiểm tra xem 'imageUrl' có tồn tại trong dữ liệu payload hay không
      if (data.containsKey('imageUrl')) {
        String imageUrl = data['imageUrl'];
        print('check image: $imageUrl');

        // Điều hướng đến Trang Chủ với URL hình ảnh
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MyHomePage(imageUrl: imageUrl),
          ),
        );
      } else {
        print("Không tìm thấy imageUrl trong payload");
      }
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

    // Kiểm tra nếu có imageUrl, tải ảnh từ URL về và lưu tạm trên thiết bị
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          // Lưu ảnh vào tệp tạm thời
          final Directory tempDir = await getTemporaryDirectory();
          final File file = File('${tempDir.path}/notification_image.jpg');
          await file.writeAsBytes(response.bodyBytes);

          // Sử dụng đường dẫn cục bộ để hiển thị trong thông báo
          bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(file.path), // Sử dụng tệp cục bộ
            contentTitle: title,
            summaryText: body,
          );
        }
      } catch (e) {
        print("Error downloading image: $e");
      }
    }

    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
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
    );

    // Tổng hợp cài đặt cho cả hai nền tảng
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    print('Sending notification with image URL: $imageUrl'); // Log ra URL hình ảnh
    print(payload);

    await _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails, payload: payload);
  }
}
