import 'package:flutter/material.dart';

import '../../../../models/patient_model.dart';
import '../../../../models/risk_assessment_model.dart';
import '../../../../services/prediction_service.dart';
import '../../../../services/risk_assessment_service.dart';
import 'prediction_result_screen.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key, required this.patient});

  final PatientModel patient;

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

enum _InputKind { binary, bmi, age, sex, health, days, education, income }

class _FeatureDefinition {
  const _FeatureDefinition(this.key, this.label, this.kind);

  final String key;
  final String label;
  final _InputKind kind;
}

class _PredictionScreenState extends State<PredictionScreen> {
  static const _primary = Color(0xFF0D8279);
  static const _definitions = [
    _FeatureDefinition('HighBP', 'Pressão alta', _InputKind.binary),
    _FeatureDefinition('HighChol', 'Colesterol alto', _InputKind.binary),
    _FeatureDefinition('CholCheck', 'Verificação de colesterol', _InputKind.binary),
    _FeatureDefinition('BMI', 'IMC (kg/m²)', _InputKind.bmi),
    _FeatureDefinition('Smoker', 'Fumante', _InputKind.binary),
    _FeatureDefinition('Stroke', 'Histórico de AVC', _InputKind.binary),
    _FeatureDefinition('PhysActivity', 'Atividade física', _InputKind.binary),
    _FeatureDefinition('Fruits', 'Consome frutas regularmente', _InputKind.binary),
    _FeatureDefinition('Veggies', 'Consome vegetais regularmente', _InputKind.binary),
    _FeatureDefinition('HvyAlcoholConsump', 'Consumo elevado de álcool', _InputKind.binary),
    _FeatureDefinition('AnyHealthcare', 'Possui cobertura de saúde', _InputKind.binary),
    _FeatureDefinition('NoDocbcCost', 'Deixou de consultar por custo', _InputKind.binary),
    _FeatureDefinition('GenHlth', 'Saúde geral', _InputKind.health),
    _FeatureDefinition('MentHlth', 'Dias com saúde mental ruim', _InputKind.days),
    _FeatureDefinition('PhysHlth', 'Dias com saúde física ruim', _InputKind.days),
    _FeatureDefinition('DiffWalk', 'Dificuldade para caminhar', _InputKind.binary),
    _FeatureDefinition('Sex', 'Sexo usado pelo modelo', _InputKind.sex),
    _FeatureDefinition('Age', 'Faixa etária', _InputKind.age),
    _FeatureDefinition('Education', 'Escolaridade (nível 1 a 6)', _InputKind.education),
    _FeatureDefinition('Income', 'Faixa de renda (nível 1 a 8)', _InputKind.income),
  ];

  final _predictionService = PredictionService();
  final _riskAssessmentService = RiskAssessmentService();
  final _formKey = GlobalKey<FormState>();
  final _bmiController = TextEditingController();
  late final Future<List<PredictionAlgorithm>> _modelsFuture;
  late final Map<String, int> _features;

  String _selectedModelId = 'logistic_regression';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    _features = {
      'HighBP': patient.highBp ? 1 : 0,
      'HighChol': patient.highChol ? 1 : 0,
      'CholCheck': 1,
      'BMI': patient.bmi.round().clamp(12, 98),
      'Smoker': patient.smoker ? 1 : 0,
      'Stroke': patient.stroke ? 1 : 0,
      'PhysActivity': patient.physActivity ? 1 : 0,
      'Fruits': 1,
      'Veggies': 1,
      'HvyAlcoholConsump': 0,
      'AnyHealthcare': 1,
      'NoDocbcCost': 0,
      'GenHlth': 2,
      'MentHlth': 0,
      'PhysHlth': 0,
      'DiffWalk': 0,
      'Sex': patient.gender == 'Masculino' ? 1 : 0,
      'Age': _ageGroup(patient.age),
      'Education': 5,
      'Income': 8,
    };
    _bmiController.text = _features['BMI'].toString();
    _modelsFuture = _predictionService.getModels();
  }

  @override
  void dispose() {
    _bmiController.dispose();
    _predictionService.close();
    super.dispose();
  }

  int _ageGroup(int age) {
    if (age < 25) return 1;
    if (age < 30) return 2;
    if (age < 35) return 3;
    if (age < 40) return 4;
    if (age < 45) return 5;
    if (age < 50) return 6;
    if (age < 55) return 7;
    if (age < 60) return 8;
    if (age < 65) return 9;
    if (age < 70) return 10;
    if (age < 75) return 11;
    if (age < 80) return 12;
    return 13;
  }

  Future<void> _sendData(PredictionAlgorithm algorithm) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await _predictionService.predictHealth(
        modelName: algorithm.id,
        features: Map<String, int>.from(_features),
      );
      final assessment = RiskAssessmentModel(
        prediction: response.prediction,
        riskPercentage: response.riskPercentage,
        modelName: response.modelName,
        message: response.message,
        createdAt: DateTime.now(),
      );

      String? saveError;
      try {
        await _riskAssessmentService.addAssessment(
          widget.patient.id!,
          assessment,
        );
      } catch (error) {
        saveError = error.toString();
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PredictionResultScreen(
            patientId: widget.patient.id!,
            patientName: widget.patient.name,
            modelLabel: algorithm.label,
            assessment: assessment,
            saveError: saveError,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao avaliar risco: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<List<PredictionAlgorithm>>(
                future: _modelsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildLoadError(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return _buildLoadError('A API não disponibilizou modelos.');
                  }

                  final algorithms = snapshot.data!;
                  final selectedAlgorithm = algorithms.firstWhere(
                    (algorithm) => algorithm.id == _selectedModelId,
                    orElse: () => algorithms.first,
                  );
                  if (_selectedModelId != selectedAlgorithm.id) {
                    _selectedModelId = selectedAlgorithm.id;
                  }
                  return _buildForm(selectedAlgorithm, algorithms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF1F2D2D),
          ),
          const Expanded(
            child: Text(
              'Predição de Risco',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2D2D),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoadError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Color(0xFFB83F46), size: 36),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar os modelos: $message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5A6B6B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    PredictionAlgorithm selectedAlgorithm,
    List<PredictionAlgorithm> algorithms,
  ) {
    final importance = {
      for (final item in selectedAlgorithm.featureImportances)
        item.feature: item.importance,
    };
    final sortedDefinitions = [..._definitions]
      ..sort(
        (first, second) => (importance[second.key] ?? 0).compareTo(
          importance[first.key] ?? 0,
        ),
      );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paciente: ${widget.patient.name}',
              style: const TextStyle(
                color: Color(0xFF718383),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'MODELO DE PREDIÇÃO',
              child: DropdownButtonFormField<String>(
                value: selectedAlgorithm.id,
                decoration: _inputDecoration('Selecione o modelo'),
                items: algorithms
                    .map(
                      (algorithm) => DropdownMenuItem(
                        value: algorithm.id,
                        child: Text(algorithm.label),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedModelId = value);
                        }
                      },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Os campos são ordenados pela importância global no modelo selecionado. Todos permanecem editáveis para fornecer a avaliação completa.',
              style: TextStyle(
                color: Color(0xFF718383),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < sortedDefinitions.length; index++)
              _buildFeatureCard(
                sortedDefinitions[index],
                importance[sortedDefinitions[index].key] ?? 0,
                index,
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _sendData(selectedAlgorithm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Avaliar risco',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    _FeatureDefinition definition,
    double importance,
    int rank,
  ) {
    final isTopFeature = rank < 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTopFeature ? const Color(0xFFF4FAF8) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopFeature ? const Color(0xFFB9DCD5) : const Color(0xFFE2E8E7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  definition.label,
                  style: const TextStyle(
                    color: Color(0xFF1F2D2D),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isTopFeature)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Mais importante',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Text(
                '${(importance * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildFeatureInput(definition),
        ],
      ),
    );
  }

  Widget _buildFeatureInput(_FeatureDefinition definition) {
    final value = _features[definition.key]!;
    switch (definition.kind) {
      case _InputKind.binary:
        return Row(
          children: [
            Expanded(
              child: Text(
                value == 1 ? 'Sim' : 'Não',
                style: const TextStyle(color: Color(0xFF718383), fontSize: 12),
              ),
            ),
            Switch(
              value: value == 1,
              activeTrackColor: _primary,
              onChanged: _loading
                  ? null
                  : (enabled) => setState(
                      () => _features[definition.key] = enabled ? 1 : 0,
                    ),
            ),
          ],
        );
      case _InputKind.bmi:
        return TextFormField(
          controller: _bmiController,
          enabled: !_loading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration('IMC do paciente (12 a 98)'),
          onChanged: (text) {
            final parsed = double.tryParse(text.replaceAll(',', '.'));
            if (parsed != null && parsed >= 12 && parsed <= 98) {
              _features['BMI'] = parsed.round();
            }
          },
          validator: (text) {
            final parsed = double.tryParse(
              (text ?? '').trim().replaceAll(',', '.'),
            );
            if (parsed == null || parsed < 12 || parsed > 98) {
              return 'Informe um IMC entre 12 e 98.';
            }
            return null;
          },
        );
      case _InputKind.age:
        return _dropdownInput(
          definition.key,
          value,
          List.generate(13, (index) {
            final ageGroup = index + 1;
            return DropdownMenuItem(
              value: ageGroup,
              child: Text('${_ageLabel(ageGroup)} anos'),
            );
          }),
        );
      case _InputKind.sex:
        return _dropdownInput(definition.key, value, const [
          DropdownMenuItem(value: 1, child: Text('Masculino')),
          DropdownMenuItem(value: 0, child: Text('Feminino')),
        ]);
      case _InputKind.health:
        return _dropdownInput(
          definition.key,
          value,
          const [
            'Excelente',
            'Muito boa',
            'Boa',
            'Regular',
            'Ruim',
          ].asMap().entries.map(
            (entry) => DropdownMenuItem(
              value: entry.key + 1,
              child: Text(entry.value),
            ),
          ).toList(),
        );
      case _InputKind.days:
        return Column(
          children: [
            Slider(
              value: value.toDouble(),
              min: 0,
              max: 30,
              divisions: 30,
              activeColor: _primary,
              label: '$value dias',
              onChanged: _loading
                  ? null
                  : (selected) => setState(
                      () => _features[definition.key] = selected.round(),
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$value de 30 dias',
                style: const TextStyle(
                  color: Color(0xFF718383),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        );
      case _InputKind.education:
        return _dropdownInput(
          definition.key,
          value,
          List.generate(
            6,
            (index) => DropdownMenuItem(
              value: index + 1,
              child: Text('Nível ${index + 1}'),
            ),
          ),
        );
      case _InputKind.income:
        return _dropdownInput(
          definition.key,
          value,
          List.generate(
            8,
            (index) => DropdownMenuItem(
              value: index + 1,
              child: Text('Faixa ${index + 1}'),
            ),
          ),
        );
    }
  }

  Widget _dropdownInput(
    String key,
    int value,
    List<DropdownMenuItem<int>> items,
  ) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: _inputDecoration('Selecione'),
      items: items,
      onChanged: _loading
          ? null
          : (selected) {
              if (selected != null) {
                setState(() => _features[key] = selected);
              }
            },
    );
  }

  String _ageLabel(int ageGroup) {
    if (ageGroup == 1) return '18–24';
    if (ageGroup == 13) return '80+';
    final lower = 25 + (ageGroup - 2) * 5;
    return '$lower–${lower + 4}';
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F4F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Color(0xFF5A6B6B),
        ),
      ),
    );
  }
}
