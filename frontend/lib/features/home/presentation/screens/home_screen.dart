import 'package:flutter/material.dart';

import '../../../../core/services/health_service.dart';
import '../widgets/health_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HealthService _healthService = HealthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _highBPController = TextEditingController(text: '1');
  final TextEditingController _highCholController = TextEditingController(text: '1');
  final TextEditingController _cholCheckController = TextEditingController(text: '1');
  final TextEditingController _bmiController = TextEditingController(text: '26');
  final TextEditingController _smokerController = TextEditingController(text: '0');
  final TextEditingController _strokeController = TextEditingController(text: '0');
  final TextEditingController _physActivityController = TextEditingController(text: '1');
  final TextEditingController _fruitsController = TextEditingController(text: '1');
  final TextEditingController _veggiesController = TextEditingController(text: '1');
  final TextEditingController _hvyAlcoholConsumpController = TextEditingController(text: '0');
  final TextEditingController _anyHealthcareController = TextEditingController(text: '1');
  final TextEditingController _noDocbcCostController = TextEditingController(text: '0');
  final TextEditingController _genHlthController = TextEditingController(text: '2');
  final TextEditingController _mentHlthController = TextEditingController(text: '5');
  final TextEditingController _physHlthController = TextEditingController(text: '2');
  final TextEditingController _diffWalkController = TextEditingController(text: '0');
  final TextEditingController _sexController = TextEditingController(text: '1');
  final TextEditingController _ageController = TextEditingController(text: '52');
  final TextEditingController _educationController = TextEditingController(text: '5');
  final TextEditingController _incomeController = TextEditingController(text: '8');

  bool _loading = false;
  String _result = 'Ainda não avaliado';

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _healthService.predictHealth(
        highBP: int.parse(_highBPController.text),
        highChol: int.parse(_highCholController.text),
        cholCheck: int.parse(_cholCheckController.text),
        bmi: int.parse(_bmiController.text),
        smoker: int.parse(_smokerController.text),
        stroke: int.parse(_strokeController.text),
        physActivity: int.parse(_physActivityController.text),
        fruits: int.parse(_fruitsController.text),
        veggies: int.parse(_veggiesController.text),
        hvyAlcoholConsump: int.parse(_hvyAlcoholConsumpController.text),
        anyHealthcare: int.parse(_anyHealthcareController.text),
        noDocbcCost: int.parse(_noDocbcCostController.text),
        genHlth: int.parse(_genHlthController.text),
        mentHlth: int.parse(_mentHlthController.text),
        physHlth: int.parse(_physHlthController.text),
        diffWalk: int.parse(_diffWalkController.text),
        sex: int.parse(_sexController.text),
        age: int.parse(_ageController.text),
        education: int.parse(_educationController.text),
        income: int.parse(_incomeController.text),
      );

      setState(() {
        _result = response.message;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      setState(() {
        _result = 'Erro ao consultar a API';
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

  @override
  void dispose() {
    for (final controller in [
      _highBPController,
      _highCholController,
      _cholCheckController,
      _bmiController,
      _smokerController,
      _strokeController,
      _physActivityController,
      _fruitsController,
      _veggiesController,
      _hvyAlcoholConsumpController,
      _anyHealthcareController,
      _noDocbcCostController,
      _genHlthController,
      _mentHlthController,
      _physHlthController,
      _diffWalkController,
      _sexController,
      _ageController,
      _educationController,
      _incomeController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Health'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Avaliação de risco cardíaco',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildField('HighBP', _highBPController),
              _buildField('HighChol', _highCholController),
              _buildField('CholCheck', _cholCheckController),
              _buildField('BMI', _bmiController),
              _buildField('Smoker', _smokerController),
              _buildField('Stroke', _strokeController),
              _buildField('PhysActivity', _physActivityController),
              _buildField('Fruits', _fruitsController),
              _buildField('Veggies', _veggiesController),
              _buildField('HvyAlcoholConsump', _hvyAlcoholConsumpController),
              _buildField('AnyHealthcare', _anyHealthcareController),
              _buildField('NoDocbcCost', _noDocbcCostController),
              _buildField('GenHlth', _genHlthController),
              _buildField('MentHlth', _mentHlthController),
              _buildField('PhysHlth', _physHlthController),
              _buildField('DiffWalk', _diffWalkController),
              _buildField('Sex', _sexController),
              _buildField('Age', _ageController),
              _buildField('Education', _educationController),
              _buildField('Income', _incomeController),
              const SizedBox(height: 24),
              Center(
                child: HealthActionButton(
                  label: _loading ? 'Consultando...' : 'Enviar dados',
                  icon: Icons.send,
                  onPressed: _loading ? () {} : _sendData,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado da análise',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_result),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Informe $label';
          }
          return null;
        },
      ),
    );
  }
}
