import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_fittrack_ai/widgets/weekly_workoutcharts.dart';
import 'package:new_fittrack_ai/chatbase_screen.dart';
import 'package:new_fittrack_ai/services/api_service.dart'; // ⬅️ Ensure this exists

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 172, 133, 237),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/avatar.png'),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              user?.email ?? 'No email',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          const WeeklyWorkoutChart(),
          const SizedBox(height: 30),
          const Text(
            "Quick Stats",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              StatCard(label: "Workouts", value: "5"),
              StatCard(label: "Calories", value: "1200"),
              StatCard(label: "Hours", value: "3h"),
            ],
          ),
          const SizedBox(height: 40),

          // ── Chat with AI Button ──
          Center(
            child: ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  final userHash = await ApiService.fetchUserHash(userId);
                  Navigator.pop(context); // Close the loading spinner

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatbaseScreen(userId: userId, userHash: userHash),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context); // Close loading spinner
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(' Failed to open chat: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: const Text("Chat with AI"),
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  const StatCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
