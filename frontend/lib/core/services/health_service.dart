import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HealthPredictionResponse {
  final int prediction;
  final String message;

  HealthPredictionResponse({
    required this.prediction,
    required this.message,
  });

  factory HealthPredictionResponse.fromJson(Map<String, dynamic> json) {
    return HealthPredictionResponse(
      prediction: json['prediction'] as int,
      message: json['message'] as String,
    );
  }
}

class HealthService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  Future<HealthPredictionResponse> predictHealth({
    required int highBP,
    required int highChol,
    required int cholCheck,
    required int bmi,
    required int smoker,
    required int stroke,
    required int physActivity,
    required int fruits,
    required int veggies,
    required int hvyAlcoholConsump,
    required int anyHealthcare,
    required int noDocbcCost,
    required int genHlth,
    required int mentHlth,
    required int physHlth,
    required int diffWalk,
    required int sex,
    required int age,
    required int education,
    required int income,
  }) async {
    final uri = Uri.parse('$baseUrl/predict');

    final body = jsonEncode({
      'HighBP': highBP,
      'HighChol': highChol,
      'CholCheck': cholCheck,
      'BMI': bmi,
      'Smoker': smoker,
      'Stroke': stroke,
      'PhysActivity': physActivity,
      'Fruits': fruits,
      'Veggies': veggies,
      'HvyAlcoholConsump': hvyAlcoholConsump,
      'AnyHealthcare': anyHealthcare,
      'NoDocbcCost': noDocbcCost,
      'GenHlth': genHlth,
      'MentHlth': mentHlth,
      'PhysHlth': physHlth,
      'DiffWalk': diffWalk,
      'Sex': sex,
      'Age': age,
      'Education': education,
      'Income': income,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar API: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return HealthPredictionResponse.fromJson(data);
  }
}
