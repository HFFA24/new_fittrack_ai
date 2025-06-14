import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
// ignore: unused_import
import 'package:timezone/timezone.dart' as tz;

import 'homepage.dart';
import 'login_page.dart';
import 'firebase_options.dart'; // ✅ Added for Firebase platform config

/*────────────────────────────────────────────
  1. Global instances
────────────────────────────────────────────*/
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/*────────────────────────────────────────────
  2. FCM background handler (top‑level)
────────────────────────────────────────────*/
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 BG message ID: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase with options for all platforms
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Setup local notifications
  await _initLocalNotifications();

  // ✅ Optional: Print device token (copy from console to test FCM)
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint('🪪 FCM Token: $token');

  runApp(const MyApp());
}

/*────────────────────────────────────────────
  3. Local‑notification initialization
────────────────────────────────────────────*/
Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Create a high-importance notification channel (for FCM + local alerts)
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
  4. Root widget
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
  5. AuthGate decides Login vs Home
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
