import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_workout.dart'; // <-- adjust import path if needed

class WorkoutTrackerPage extends StatefulWidget {
  const WorkoutTrackerPage({super.key});

  @override
  State<WorkoutTrackerPage> createState() => _WorkoutTrackerPageState();
}

class _WorkoutTrackerPageState extends State<WorkoutTrackerPage> {
  /// Use `dynamic` for the values so you can store Strings **or** numbers
  List<Map<String, dynamic>> workouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  /// Fetch workouts belonging to the current user
  Future<void> fetchWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("User not logged in.");
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

      final fetchedWorkouts = snapshot.docs.map<Map<String, dynamic>>((doc) {
        final data = doc.data();
        return {
          'title': data['type'] ?? 'Workout',
          'duration': (data['duration'] ?? 0).toString(), // always a String
        };
      }).toList();

      setState(() {
        workouts = fetchedWorkouts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching workouts: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Workouts",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: workouts.isEmpty
                        ? const Center(child: Text("No workouts found."))
                        : ListView.builder(
                            itemCount: workouts.length,
                            itemBuilder: (context, index) {
                              final workout = workouts[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.deepPurple[50],
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.fitness_center,
                                    color: Colors.deepPurple,
                                  ),
                                  title: Text(workout['title'] as String),
                                  subtitle: Text(
                                    "Duration: ${workout['duration']} mins",
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () async {
          // Go to AddWorkoutPage, then refresh when the user returns.
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
