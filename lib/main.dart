import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ungdungbaochay/push_notifications.dart';

import 'firebase_options.dart';

// function to lisen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.data.isNotEmpty) {
    String? imageUrl = message.data['imageUrl'];
    print("Data received: ${message.data}");
    if (imageUrl != null) {
      print("Image URL received: $imageUrl");
      // Điều hướng đến màn hình chứa hình ảnh
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => MyHomePage(imageUrl: imageUrl),
        ),
      );
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String? token = await PushNotifications.getFcmToken();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Đăng ký với topic "all_users"
  messaging.subscribeToTopic("all_users").then((_) {
    print("Đã đăng ký thành công với topic all_users");
  }).catchError((error) {
    print("Đăng ký topic thất bại: $error");
  });
  print(token);
  runApp(const MyApp());

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data.isNotEmpty) {
      String? imageUrl = message.data['imageUrl'];
      print("Data received: ${message.data}");
      if (imageUrl != null) {
        print("Image URL received: $imageUrl");
        // Điều hướng đến màn hình chứa hình ảnh
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => MyHomePage(imageUrl: imageUrl),
          ),
        );
      }
    }
  });

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Lắng nghe sự kiện thông báo khi ứng dụng đang ở chế độ foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    if (message.data.isNotEmpty) {
      String? imageUrl = message.data['imageUrl'];
      print("Data received: ${message.data}");
      PushNotifications.showSimpleNotification(
          title: message.notification!.title!, body: message.notification!.body!, payload: payloadData, imageUrl: imageUrl);
    }
  });

  PushNotifications.init();
  PushNotifications.localNotiInit();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Đảm bảo navigatorKey được truyền vào đây
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(imageUrl: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.imageUrl});
  final String imageUrl;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = 'Ứng dụng thông báo cháy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        automaticallyImplyLeading: false, // Ẩn nút Back
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.imageUrl.isNotEmpty
                  ? const Text(
                      'Hệ thống đã phát hiện ra cháy từ camera.',
                      style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
                    )
                  : const Text(
                      'Không có dữ liệu.',
                      style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
              const SizedBox(
                height: 8,
              ),
              widget.imageUrl.isNotEmpty
                  ? Image.network(widget.imageUrl) // Hiển thị hình ảnh cháy
                  : const Text('Không có hình ảnh'),
            ],
          ),
        ),
      ),
    );
  }
}
