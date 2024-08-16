import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ungdungbaochay/push_notifications.dart';

import 'firebase_options.dart';

// function to lisen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received");
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
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // Lắng nghe sự kiện thông báo khi ứng dụng đang ở chế độ foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    PushNotifications.showSimpleNotification(title: message.notification!.title!, body: message.notification!.body!, payload: payloadData);
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Center(
              child: widget.imageUrl.isNotEmpty
                  ? Image.network(widget.imageUrl) // Hiển thị hình ảnh cháy
                  : const Text('Không có hình ảnh'),
            ),
          ],
        ),
      ),
    );
  }
}
