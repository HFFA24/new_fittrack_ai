import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeeklyWorkoutChart extends StatefulWidget {
  const WeeklyWorkoutChart({super.key});

  @override
  State<WeeklyWorkoutChart> createState() => _WeeklyWorkoutChartState();
}

class _WeeklyWorkoutChartState extends State<WeeklyWorkoutChart> {
  /// Map weekday (Mon..Sun) ➜ total minutes
  Map<String, int> dailyDurations = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyData();
  }

  Future<void> _fetchWeeklyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    // Query workouts in the last 7 days
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
        )
        .get();

    // Initialise Mon‑Sun with 0
    dailyDurations = {};
    for (int i = 0; i < 7; i++) {
      final dayKey = DateFormat('EEE').format(now.subtract(Duration(days: i)));
      dailyDurations[dayKey] = 0;
    }

    // Sum minutes per day
    for (var doc in snap.docs) {
      final data = doc.data();
      final ts = data['timestamp'] as Timestamp;
      final date = ts.toDate();
      final dayKey = DateFormat('EEE').format(date); // Mon, Tue…
      final minutes = (data['duration'] ?? 0) as int;

      if (dailyDurations.containsKey(dayKey)) {
        dailyDurations[dayKey] = dailyDurations[dayKey]! + minutes;
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Convert map to fixed weekday order: Mon..Sun
    final orderedDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = (dailyDurations.values.fold(0, (a, b) => a > b ? a : b) + 10)
        .toDouble();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Weekly Workout (mins)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          return idx >= 0 && idx < 7
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(orderedDays[idx]),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    final day = orderedDays[index];
                    final minutes = dailyDurations[day] ?? 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: minutes.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.deepPurple,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
