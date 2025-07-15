import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_workout.dart'; // adjust if needed

class WorkoutTrackerPage extends StatefulWidget {
  const WorkoutTrackerPage({super.key});

  @override
  State<WorkoutTrackerPage> createState() => _WorkoutTrackerPageState();
}

class _WorkoutTrackerPageState extends State<WorkoutTrackerPage> {
  List<Map<String, dynamic>> workouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('workouts')
          .orderBy('timestamp', descending: true)
          .get();

      final fetched = snapshot.docs.map<Map<String, dynamic>>((doc) {
        final d = doc.data();
        return {
          'title': d['type'] ?? 'Workout',
          'duration': (d['duration'] ?? 0).toString(),
        };
      }).toList();

      setState(() {
        workouts = fetched;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      setState(() => isLoading = false);
    }
  }

  /// quick helper to add a fixed "Cardio / 08:00" workout
  Future<void> _addCardioWorkout() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .add({
          'type': 'Cardio',
          'time': '08:00',
          'timestamp': FieldValue.serverTimestamp(),
        });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Workout saved!')));
      fetchWorkouts(); // refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        backgroundColor: const Color.fromARGB(255, 172, 139, 228),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Workouts',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 173, 149, 214),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _addCardioWorkout,
                    child: const Text('Add Cardio Workout'),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: workouts.isEmpty
                        ? const Center(child: Text('No workouts found.'))
                        : ListView.builder(
                            itemCount: workouts.length,
                            itemBuilder: (context, index) {
                              final w = workouts[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: const Color.fromARGB(255, 151, 119, 200),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.deepPurple,
                                  ),
                                  title: Text(w['title'] as String),
                                  subtitle: Text(
                                    'Duration: ${w['duration']} mins',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 172, 145, 223),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddWorkoutPage()),
          );
          fetchWorkouts();
        },
      ),
    );
  }
}
