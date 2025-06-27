import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  Future<void> saveWorkoutLog({
    required String type,
    required int durationMinutes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final workoutData = {
      'type': type,
      'duration': durationMinutes,
      'timestamp': DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .add(workoutData);
  }

  void _handleSave() async {
    final type = _typeController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (type.isEmpty || duration == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter valid data")));
      return;
    }

    await saveWorkoutLog(type: type, durationMinutes: duration);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Workout saved!")));

    Navigator.pop(context); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: "Workout Type (e.g. Running)",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: "Duration (minutes)",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),
              child: const Text("Save Workout"),
            ),
          ],
        ),
      ),
    );
  }
}
