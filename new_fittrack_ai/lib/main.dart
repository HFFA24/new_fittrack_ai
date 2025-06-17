// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'calorie predictor.dart'; // ← import predictor
import 'homepage.dart';
import 'login_page.dart';
import 'firebase_options.dart';

/*────────────────────────────────────────────
  1. Global instances (notifications)
────────────────────────────────────────────*/
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/*────────────────────────────────────────────
  2. FCM background handler
────────────────────────────────────────────*/
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 BG message ID: ${message.messageId}');
}

/*────────────────────────────────────────────
  3. main()
────────────────────────────────────────────*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CaloriePredictor.init(); // ✅ load model once

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initLocalNotifications();

  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('🪪 FCM Token: $token');

  runApp(const MyApp());
}

/*────────────────────────────────────────────
  4. Local notifications
────────────────────────────────────────────*/
Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const androidChannel = AndroidNotificationChannel(
    'fcm_default',
    'FCM Messages',
    description: 'Notifications from Firebase Cloud Messaging',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(androidChannel);

  tz.initializeTimeZones();
}

/*────────────────────────────────────────────
  5. Root widget
────────────────────────────────────────────*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/*────────────────────────────────────────────
  6. AuthGate
────────────────────────────────────────────*/
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.hasData ? const HomePage() : const LoginPage();
      },
    );
  }
}
