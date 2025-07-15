// add_workout_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:tflite_flutter/tflite_flutter.dart'; // ← unused but kept
import 'package:new_fittrack_ai/calorie predictor.dart';

class AddWorkoutPage extends StatefulWidget {
  const AddWorkoutPage({super.key});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  /*────────────────────────────────────────────
    Save to Firestore
  ────────────────────────────────────────────*/
  Future<void> saveWorkoutLog({
    required String type,
    required int durationMinutes,
    required int calories,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .add({
          'type': type,
          'duration': durationMinutes,
          'calories': calories,
          'timestamp': DateTime.now(),
        });
  }

  /*────────────────────────────────────────────
    Handle Save Button
  ────────────────────────────────────────────*/
  Future<void> _handleSave() async {
    final type = _typeController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());

    if (type.isEmpty || duration == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter valid data")));
      return;
    }

    /*--- 1. Build feature vector (must match model training order) ---*/
    const double userWeight = 70.0; // TODO: fetch real weight
    final running = type.toLowerCase() == 'running' ? 1.0 : 0.0;
    final cycling = type.toLowerCase() == 'cycling' ? 1.0 : 0.0;
    final walking = type.toLowerCase() == 'walking' ? 1.0 : 0.0;

    final featureVector = [
      duration.toDouble(),
      userWeight,
      running,
      cycling,
      walking,
    ];

    /*--- 2. Predict calories with TFLite model ---*/
    final calories = CaloriePredictor.predict(featureVector).round();

    /*--- 3. Save workout with calories ---*/
    await saveWorkoutLog(
      type: type,
      durationMinutes: duration,
      calories: calories,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Workout saved! ~$calories kcal")));
    Navigator.pop(context);
  }

  /*────────────────────────────────────────────
    UI
  ────────────────────────────────────────────*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Workout"),
        backgroundColor: const Color.fromARGB(255, 147, 108, 216),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: "Workout Type "),
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
                backgroundColor: const Color.fromARGB(255, 178, 146, 232),
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
