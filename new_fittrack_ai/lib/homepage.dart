import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'login_page.dart';
import 'dashboard.dart';
import 'workouts.dart';
import 'profile.dart';
import 'settingspage.dart';

/*────────────────────────────────────────────
  Local‑notification plugin
────────────────────────────────────────────*/
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  /* Bottom‑nav pages */
  static final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    const WorkoutTrackerPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _listenForForegroundMessages();
  }

  /* Ask user for permission (Android 13+ / iOS) */
  Future<void> _requestNotificationPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  /* Listen for foreground push messages */
  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(' New push message received!');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // Show banner via local notification
      const androidDetails = AndroidNotificationDetails(
        'fcm_default',
        'FCM Messages',
        importance: Importance.high,
        priority: Priority.high,
      );

      flutterLocalNotificationsPlugin.show(
        message.hashCode, // unique id
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(android: androidDetails),
      );
    });
  }

  /* Logout */
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  /* Bottom‑nav tap */
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('FitTrack AI'),
        backgroundColor: const Color.fromARGB(255, 154, 111, 228),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 168, 129, 237),
        onTap: _onItemTapped,
      ),
    );
  }
}
