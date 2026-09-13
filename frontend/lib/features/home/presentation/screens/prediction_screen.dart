import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../../../core/services/health_service.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final HealthService _healthService = HealthService();

  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  String _selectedPatient = 'Carlos Silva';
  int _age = 62;
  double _bmi = 31.5;
  bool _highBP = true;
  bool _highChol = true;
  bool _smoker = false;
  bool _physActivity = false;
  bool _stroke = true;
  

  int _cholCheck = 1;
  int _fruits = 1;
  int _veggies = 1;
  int _hvyAlcoholConsump = 0;
  int _anyHealthcare = 1;
  int _noDocbcCost = 0;
  int _genHlth = 2;
  int _mentHlth = 5;
  int _physHlth = 2;
  int _diffWalk = 0;
  int _sex = 1;
  int _education = 5;
  int _income = 8;

  bool _loading = false;
  double _riskPercentage = 0;
  bool _analyzed = false;

  // Informações sobre cada parâmetro
  final Map<String, String> _parameterInfo = {
    'HighBP': 'Pressão Alta\nConsiderada alta se Sistólica ≥ 140 mmHg ou Diastólica ≥ 90 mmHg',
    'HighChol': 'Colesterol Alto\nConsiderado alto se Total ≥ 200 mg/dL',
    'BMI': 'Índice de Massa Corporal\nPeso (kg) ÷ Altura² (m)\nNormal: 18.5-24.9 | Sobrepeso: 25-29.9 | Obeso: ≥ 30',
    'Smoker': 'Fumante\nIndica consumo de tabaco regular',
    'PhysActivity': 'Atividade Física\nPrática de ≥ 150 min de atividade moderada/semana',
    'Stroke': 'Histórico de Derrame\nJá sofreu ou foi diagnosticado com AVC',
    'GenHlth': 'Saúde Geral (1-5)\n1=Excelente | 5=Péssima',
    'MentHlth': 'Saúde Mental (dias)\nQuantos dias sentiu-se mentalmente não bem',
    'PhysHlth': 'Saúde Física (dias)\nQuantos dias teve problemas físicos',
    'DiffWalk': 'Dificuldade para Andar\nDificuldade ou limitação para andar',
    'Age': 'Idade\nEm anos completos',
  };

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _healthService.predictHealth(
        highBP: _highBP ? 1 : 0,
        highChol: _highChol ? 1 : 0,
        cholCheck: _cholCheck,
        bmi: _bmi.toInt(),
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

      setState(() {
        _analyzed = true;
        _riskPercentage = response.prediction == 1 ? 0.82 : 0.18;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      setState(() {
        _analyzed = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showParameterInfo(String paramName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(paramName),
        content: Text(_parameterInfo[paramName] ?? 'Sem informações'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 32),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AVALIAÇÃO DE RISCO CARDÍACO',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Indicador de Risco (Card com percentual)
              if (_analyzed)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: _riskPercentage > 0.5
                            ? [Colors.blue.shade400, Colors.blue.shade600]
                            : [Colors.green.shade300, Colors.green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Probabilidade de Ataque Cardíaco',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 10,
                          percent: _riskPercentage,
                          center: Text(
                            '${(_riskPercentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: Colors.white,
                          backgroundColor: Colors.white.withAlpha(100),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _riskPercentage > 0.5
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _riskPercentage > 0.5 ? 'ALTO RISCO' : 'BAIXO RISCO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Seleção de Paciente
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown Paciente
                    const Text(
                      'Selecione o Paciente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownSearch<String>(
                      items: const ['Carlos Silva', 'João Santos', 'Maria Silva'],
                      selectedItem: _selectedPatient,
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedPatient = value ?? 'Carlos Silva';
                          _analyzed = false;
                        });
                      },
                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem ?? 'Carlos Silva',
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Idade
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Idade',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$_age anos',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showParameterInfo('Age'),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.info,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _age.toDouble(),
                      min: 18,
                      max: 100,
                      onChanged: (value) {
                        setState(() {
                          _age = value.toInt();
                          _analyzed = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // IMC
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'IMC (Índice de Massa Corporal)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showParameterInfo('BMI'),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.info,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Faixa Etária Normal: +18 anos (Vendo) | Moderado: 25-0 (Laranja) | Alto: +0 (Vermelho)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _bmi,
                      min: 10,
                      max: 50,
                      onChanged: (value) {
                        setState(() {
                          _bmi = value;
                          _analyzed = false;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Toggle Switches
                    _buildToggleSwitch(
                      'Pressão Alta (HighBP)',
                      _highBP,
                      (value) => setState(() {
                        _highBP = value;
                        _analyzed = false;
                      }),
                      'HighBP',
                    ),
                    const SizedBox(height: 12),
                    _buildToggleSwitch(
                      'Colesterol Alto (HighChol)',
                      _highChol,
                      (value) => setState(() {
                        _highChol = value;
                        _analyzed = false;
                      }),
                      'HighChol',
                    ),
                    const SizedBox(height: 12),
                    _buildToggleSwitch(
                      'Fumante (Smoker)',
                      _smoker,
                      (value) => setState(() {
                        _smoker = value;
                        _analyzed = false;
                      }),
                      'Smoker',
                    ),
                    const SizedBox(height: 12),
                    _buildToggleSwitch(
                      'Atividade Física (PhysActivity)',
                      _physActivity,
                      (value) => setState(() {
                        _physActivity = value;
                        _analyzed = false;
                      }),
                      'PhysActivity',
                    ),
                    const SizedBox(height: 12),
                    _buildToggleSwitch(
                      'Histórico de Derrame (Stroke)',
                      _stroke,
                      (value) => setState(() {
                        _stroke = value;
                        _analyzed = false;
                      }),
                      'Stroke',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Botões de Ação
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? () {} : _sendData,
                  icon: Icon(_analyzed ? Icons.refresh : Icons.search),
                  label: Text(_loading ? 'Analisando...' : (_analyzed ? 'Reavaliar' : 'Analisar Risco com IA')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Agendar Consulta Preventiva (CRUD 4)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildToggleSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
    String paramKey,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showParameterInfo(paramKey),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: const Icon(
              Icons.info,
              size: 16,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.red,
        ),
      ],
    );
  }
}
