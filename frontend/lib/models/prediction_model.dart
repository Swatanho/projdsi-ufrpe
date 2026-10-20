class PredictionModel {
  const PredictionModel({
    required this.prediction,
    required this.riskPercentage,
    required this.modelName,
    required this.message,
  });

  final int prediction;
  final double riskPercentage;
  final String modelName;
  final String message;

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      prediction: (json['prediction'] as num).toInt(),
      riskPercentage: (json['risk_percentage'] as num).toDouble(),
      modelName: json['model_name'] as String,
      message: json['message'] as String,
    );
  }
}

class PredictionAlgorithm {
  const PredictionAlgorithm({
    required this.id,
    required this.label,
    required this.featureImportances,
  });

  final String id;
  final String label;
  final List<PredictionFeatureImportance> featureImportances;

  factory PredictionAlgorithm.fromJson(Map<String, dynamic> json) {
    return PredictionAlgorithm(
      id: json['id'] as String,
      label: json['label'] as String,
      featureImportances: (json['feature_importances'] as List<dynamic>)
          .map(
            (item) => PredictionFeatureImportance.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class PredictionFeatureImportance {
  const PredictionFeatureImportance({
    required this.feature,
    required this.importance,
  });

  final String feature;
  final double importance;

  factory PredictionFeatureImportance.fromJson(Map<String, dynamic> json) {
    return PredictionFeatureImportance(
      feature: json['feature'] as String,
      importance: (json['importance'] as num).toDouble(),
    );
  }
}

typedef HealthPredictionResponse = PredictionModel;
