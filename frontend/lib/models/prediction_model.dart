class PredictionModel {
  const PredictionModel({required this.prediction, required this.message});

  final int prediction;
  final String message;

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      prediction: (json['prediction'] as num).toInt(),
      message: json['message'] as String,
    );
  }
}

typedef HealthPredictionResponse = PredictionModel;
