// dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_fittrack_ai/widgets/weekly_workoutcharts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Profile avatar & email ─────────────────────────────
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

          // ── Weekly progress bar chart ─────────────────────────
          const WeeklyWorkoutChart(),
          const SizedBox(height: 30),

          // ── Quick stats row (placeholder) ─────────────────────
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
        ],
      ),
    );
  }
}

/* ───────────────────────────────────────────── */
/*                 SMALL STAT CARD               */
/* ───────────────────────────────────────────── */

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
