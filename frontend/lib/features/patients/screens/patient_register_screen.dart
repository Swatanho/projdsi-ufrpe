import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../../../core/services/patient_service.dart';

class PatientRegisterScreen extends StatefulWidget {
  final String doctorId; // ID do médico autenticado

  const PatientRegisterScreen({super.key, required this.doctorId});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedGender = 'Masculino';
  double _age = 30;
  double _bmi = 24.5;
  
  bool _highBp = false;
  bool _highChol = false;
  bool _smoker = false;
  bool _physActivity = true;
  bool _stroke = false;
  
  bool _isLoading = false;
  final PatientService _patientService = PatientService();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newPatient = PatientModel(
          doctorId: widget.doctorId,
          name: _nameController.text.trim(),
          age: _age.toInt(),
          gender: _selectedGender,
          bmi: double.parse(_bmi.toStringAsFixed(1)),
          highBp: _highBp,
          highChol: _highChol,
          smoker: _smoker,
          physActivity: _physActivity,
          stroke: _stroke,
          createdAt: DateTime.now(),
        );

        await _patientService.addPatient(widget.doctorId, newPatient);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente cadastrado com sucesso!'), backgroundColor: Color(0xFF0E5B53)),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Paciente'),
        backgroundColor: const Color(0xFF0E5B53),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Informe o nome do paciente' : null,
              ),
              const SizedBox(height: 16),

              // Género
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
                items: ['Masculino', 'Feminino', 'Outro'].map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const SizedBox(height: 20),

              // Slider Idade
              Text('Idade: ${_age.toInt()} anos', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _age,
                min: 0,
                max: 120,
                divisions: 120,
                activeColor: const Color(0xFF0E5B53),
                label: '${_age.toInt()} anos',
                onChanged: (value) => setState(() => _age = value),
              ),
              const SizedBox(height: 10),

              // Slider IMC
              Text('IMC (Índice de Massa Corporal): ${_bmi.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: _bmi,
                min: 10,
                max: 50,
                divisions: 400,
                activeColor: const Color(0xFF0E5B53),
                label: _bmi.toStringAsFixed(1),
                onChanged: (value) => setState(() => _bmi = value),
              ),
              const Divider(height: 30),

              // Switches de Saúde
              SwitchListTile(
                title: const Text('Pressão Alta (HighBP)'),
                value: _highBp,
                activeColor: const Color(0xFF0E5B53),
                onChanged: (value) => setState(() => _highBp = value),
              ),
              SwitchListTile(
                title: const Text('Colesterol Alto (HighChol)'),
                value: _highChol,
                activeColor: const Color(0xFF0E5B53),
                onChanged: (value) => setState(() => _highChol = value),
              ),
              SwitchListTile(
                title: const Text('Fumante (Smoker)'),
                value: _smoker,
                activeColor: const Color(0xFF0E5B53),
                onChanged: (value) => setState(() => _smoker = value),
              ),
              SwitchListTile(
                title: const Text('Atividade Física (PhysActivity)'),
                value: _physActivity,
                activeColor: const Color(0xFF0E5B53),
                onChanged: (value) => setState(() => _physActivity = value),
              ),
              SwitchListTile(
                title: const Text('Histórico de Derrame (Stroke)'),
                value: _stroke,
                activeColor: const Color(0xFF0E5B53),
                onChanged: (value) => setState(() => _stroke = value),
              ),
              const SizedBox(height: 30),

              // Botão Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0E5B53)),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Paciente', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}