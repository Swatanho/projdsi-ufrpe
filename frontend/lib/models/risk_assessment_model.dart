import 'package:cloud_firestore/cloud_firestore.dart';

class RiskAssessmentModel {
  const RiskAssessmentModel({
    this.id,
    required this.prediction,
    required this.riskPercentage,
    required this.modelName,
    required this.message,
    required this.createdAt,
  });

  final String? id;
  final int prediction;
  final double riskPercentage;
  final String modelName;
  final String message;
  final DateTime createdAt;

  factory RiskAssessmentModel.fromMap(
    Map<String, dynamic> data, {
    String? id,
  }) {
    final rawCreatedAt = data['createdAt'];
    final createdAt = switch (rawCreatedAt) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      String value => DateTime.tryParse(value),
      _ => null,
    };

    return RiskAssessmentModel(
      id: id,
      prediction: (data['prediction'] as num).toInt(),
      riskPercentage: (data['riskPercentage'] as num).toDouble(),
      modelName: data['modelName'] as String? ?? 'logistic_regression',
      message: data['message'] as String,
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() => {
    'prediction': prediction,
    'riskPercentage': riskPercentage,
    'modelName': modelName,
    'message': message,
  };
}
