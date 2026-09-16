import 'package:flutter/material.dart';

class PredictionRecordScreen extends StatefulWidget {
  const PredictionRecordScreen({super.key});

  @override
  State<PredictionRecordScreen> createState() => _PredictionRecordScreenState();
}

class _PredictionRecordScreenState extends State<PredictionRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _bmiController = TextEditingController();
  final _physHlthController = TextEditingController();
  final _mentHlthController = TextEditingController();

  bool _highBP = false;
  bool _highChol = false;
  bool _smoker = false;
  bool _physActivity = false;
  bool _stroke = false;

  @override
  void dispose() {
    _bmiController.dispose();
    _physHlthController.dispose();
    _mentHlthController.dispose();
    super.dispose();
  }

  void _calculateRisk() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avaliação de risco enviada para processamento!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F),
      appBar: AppBar(
        title: const Text('Registro de Avaliação (Prediction)', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.monitor_heart,
                      size: 56,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dados Biométricos & Hábitos',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                    ),
                    const SizedBox(height: 24),

                    // IMC (bmi)
                    TextFormField(
                      controller: _bmiController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'IMC (Índice de Massa Corporal)',
                        hintText: 'Ex: 24.5',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.scale),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Informe o IMC' : null,
                    ),
                    const SizedBox(height: 16),

                    // Dias de Saúde Física Ruim (physHlth)
                    TextFormField(
                      controller: _physHlthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dias de Saúde Física Ruim (0-30)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.fitness_center),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Informe os dias' : null,
                    ),
                    const SizedBox(height: 16),

                    // Dias de Saúde Mental Ruim (mentHlth)
                    TextFormField(
                      controller: _mentHlthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dias de Saúde Mental Ruim (0-30)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.psychology),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Informe os dias' : null,
                    ),
                    const SizedBox(height: 16),

                    const Divider(),
                    const Text('Indicadores de Saúde', style: TextStyle(fontWeight: FontWeight.bold)),
                    
                    SwitchListTile(
                      title: const Text('Pressão Alta (highBP)'),
                      value: _highBP,
                      activeColor: const Color(0xFFD32F2F),
                      onChanged: (val) => setState(() => _highBP = val),
                    ),
                    SwitchListTile(
                      title: const Text('Colesterol Alto (highChol)'),
                      value: _highChol,
                      activeColor: const Color(0xFFD32F2F),
                      onChanged: (val) => setState(() => _highChol = val),
                    ),
                    SwitchListTile(
                      title: const Text('Fumante (smoker)'),
                      value: _smoker,
                      activeColor: const Color(0xFFD32F2F),
                      onChanged: (val) => setState(() => _smoker = val),
                    ),
                    SwitchListTile(
                      title: const Text('Pratica Atividade Física (physActivity)'),
                      value: _physActivity,
                      activeColor: const Color(0xFFD32F2F),
                      onChanged: (val) => setState(() => _physActivity = val),
                    ),
                    SwitchListTile(
                      title: const Text('Histórico de AVC/Derrame (stroke)'),
                      value: _stroke,
                      activeColor: const Color(0xFFD32F2F),
                      onChanged: (val) => setState(() => _stroke = val),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _calculateRisk,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Calcular Risco (calculateRisk)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}