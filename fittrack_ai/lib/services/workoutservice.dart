// lib/services/workout_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutService {
  static Future<void> saveWorkoutLog({
    required String type,
    required int durationMinutes,
    DateTime? workoutDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final workoutData = {
      'type': type,
      'duration': durationMinutes,
      'timestamp': workoutDate ?? DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .add(workoutData);
  }
}
