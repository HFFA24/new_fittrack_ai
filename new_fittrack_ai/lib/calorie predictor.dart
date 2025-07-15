import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart'; // for debugPrint

class CaloriePredictor {
  static late final Interpreter _interpreter;

  static Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/calorie_model.tflite',
    );
    debugPrint(' TFLite model loaded');
  }

  static double predict(List<double> features) {
    final output = List.filled(1, 0.0).reshape([1, 1]);
    _interpreter.run([features], output);
    return output[0][0];
  }

  static void dispose() => _interpreter.close();
}
