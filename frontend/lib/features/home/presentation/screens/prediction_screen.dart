import 'package:flutter/material.dart';

import '../../../../core/services/health_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final HealthService _healthService = HealthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _bmiController = TextEditingController(text: '24.5');

  final int _age = 62;
  double _bmi = 24.5;
  bool _highBP = true;
  bool _highChol = false;
  bool _smoker = false;
  bool _physActivity = true;
  bool _stroke = false;

  final int _cholCheck = 1;
  final int _fruits = 1;
  final int _veggies = 1;
  final int _hvyAlcoholConsump = 0;
  final int _anyHealthcare = 1;
  final int _noDocbcCost = 0;
  final int _genHlth = 2;
  int _mentHlth = 18;
  int _physHlth = 22;
  final int _diffWalk = 0;
  final int _sex = 1;
  final int _education = 5;
  final int _income = 8;

  bool _loading = false;

  @override
  void dispose() {
    _bmiController.dispose();
    super.dispose();
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _healthService.predictHealth(
        highBP: _highBP ? 1 : 0,
        highChol: _highChol ? 1 : 0,
        cholCheck: _cholCheck,
        bmi: _bmi.round(),
        smoker: _smoker ? 1 : 0,
        stroke: _stroke ? 1 : 0,
        physActivity: _physActivity ? 1 : 0,
        fruits: _fruits,
        veggies: _veggies,
        hvyAlcoholConsump: _hvyAlcoholConsump,
        anyHealthcare: _anyHealthcare,
        noDocbcCost: _noDocbcCost,
        genHlth: _genHlth,
        mentHlth: _mentHlth,
        physHlth: _physHlth,
        diffWalk: _diffWalk,
        sex: _sex,
        age: _age,
        education: _education,
        income: _income,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _updateBmiFromText(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return;
    setState(() => _bmi = parsed);
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

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2D2D),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF0D8279),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFD7E7E5),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderField(String label, int value, int min, int max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F2D2D),
              ),
            ),
            Text(
              '$value / $max',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF0D8279),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0D8279),
            inactiveTrackColor: const Color(0xFFD9EAE7),
            thumbColor: const Color(0xFF0D8279),
            overlayColor: const Color(0xFF0D8279).withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1F2D2D)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Predição de Risco',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2D2D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8E7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('DADOS BIOMÉTRICOS'),
                              const Text(
                                'IMC / BMI',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF5A6B6B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _bmiController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: _updateBmiFromText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF0F4F3),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  prefixIcon: const Icon(Icons.monitor_weight, color: Color(0xFF0D8279)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF0D8279), width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Informe o IMC';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8E7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('HISTÓRICO DE SAÚDE'),
                              _buildSwitchRow('Pressão Alta', _highBP, (value) => setState(() => _highBP = value)),
                              _buildSwitchRow('Colesterol Alto', _highChol, (value) => setState(() => _highChol = value)),
                              _buildSwitchRow('Fumante', _smoker, (value) => setState(() => _smoker = value)),
                              _buildSwitchRow('Atividade Física', _physActivity, (value) => setState(() => _physActivity = value)),
                              _buildSwitchRow('AVC / Derrame', _stroke, (value) => setState(() => _stroke = value)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8E7)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('SAÚDE GERAL'),
                              _buildSliderField('Saúde Física (1 a 30)', _physHlth, 1, 30, (value) {
                                setState(() => _physHlth = value.round());
                              }),
                              const SizedBox(height: 14),
                              _buildSliderField('Saúde Mental (1 a 30)', _mentHlth, 1, 30, (value) {
                                setState(() => _mentHlth = value.round());
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _sendData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D8279),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _loading ? 'Calculando...' : 'Calcular Risco',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
