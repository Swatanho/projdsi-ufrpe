import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/prediction_model.dart';

export '../models/prediction_model.dart'
    show
        PredictionModel,
        PredictionAlgorithm,
        PredictionFeatureImportance,
        HealthPredictionResponse;

class PredictionService {
  PredictionService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<List<PredictionAlgorithm>> getModels() async {
    final response = await _client.get(Uri.parse('$baseUrl/models'));
    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao carregar modelos: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['models'] as List<dynamic>)
        .map(
          (item) => PredictionAlgorithm.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<PredictionModel> predictHealth({
    required String modelName,
    required Map<String, int> features,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/predict',
    ).replace(queryParameters: {'model_name': modelName});
    final body = jsonEncode(features);

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao consultar API: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PredictionModel.fromJson(data);
  }
}

typedef HealthService = PredictionService;
