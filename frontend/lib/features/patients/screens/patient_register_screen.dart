import 'package:flutter/material.dart';

import '../../../models/patient_model.dart';
import '../../../services/patient_service.dart';

class PatientRegisterScreen extends StatefulWidget {
  final String doctorId; // ID do médico autenticado

  const PatientRegisterScreen({super.key, required this.doctorId});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  static const _primary = Color(0xFF0D8279);
  static const _background = Color(0xFFF4F8F7);
  static const _heading = Color(0xFF173A3A);
  static const _muted = Color(0xFF718383);
  static const _border = Color(0xFFD8E5E3);

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newPatient = PatientModel(
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
          const SnackBar(
            content: Text('Paciente cadastrado com sucesso!'),
            backgroundColor: _primary,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
            backgroundColor: const Color(0xFFB83F46),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted, fontSize: 13),
      prefixIcon: Icon(icon, color: _muted, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB83F46)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB83F46), width: 1.5),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _heading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _heading,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              valueLabel,
              style: const TextStyle(
                color: _primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _primary,
            inactiveTrackColor: const Color(0xFFD9EAE7),
            thumbColor: _primary,
            overlayColor: _primary.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title, style: const TextStyle(color: _heading, fontSize: 13)),
      value: value,
      activeTrackColor: _primary,
      inactiveTrackColor: const Color(0xFFD7E7E5),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Voltar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: _muted,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Novo paciente',
                        style: TextStyle(
                          color: _heading,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        title: 'Dados do paciente',
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _inputDecoration(
                                'Nome completo',
                                Icons.person_outline,
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Informe o nome do paciente'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: _inputDecoration(
                                'Sexo',
                                Icons.wc_outlined,
                              ),
                              items: ['Masculino', 'Feminino', 'Outro']
                                  .map(
                                    (gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedGender = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionCard(
                        title: 'Medidas corporais',
                        child: Column(
                          children: [
                            _buildSlider(
                              label: 'Idade',
                              valueLabel: '${_age.toInt()} anos',
                              value: _age,
                              min: 0,
                              max: 120,
                              divisions: 120,
                              onChanged: (value) =>
                                  setState(() => _age = value),
                            ),
                            const SizedBox(height: 10),
                            _buildSlider(
                              label: 'IMC',
                              valueLabel: _bmi.toStringAsFixed(1),
                              value: _bmi,
                              min: 10,
                              max: 50,
                              divisions: 400,
                              onChanged: (value) =>
                                  setState(() => _bmi = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionCard(
                        title: 'Histórico de saúde',
                        child: Column(
                          children: [
                            _buildHealthToggle(
                              title: 'Pressão alta',
                              value: _highBp,
                              onChanged: (value) =>
                                  setState(() => _highBp = value),
                            ),
                            _buildHealthToggle(
                              title: 'Colesterol alto',
                              value: _highChol,
                              onChanged: (value) =>
                                  setState(() => _highChol = value),
                            ),
                            _buildHealthToggle(
                              title: 'Fumante',
                              value: _smoker,
                              onChanged: (value) =>
                                  setState(() => _smoker = value),
                            ),
                            _buildHealthToggle(
                              title: 'Pratica atividade física',
                              value: _physActivity,
                              onChanged: (value) =>
                                  setState(() => _physActivity = value),
                            ),
                            _buildHealthToggle(
                              title: 'Histórico de derrame',
                              value: _stroke,
                              onChanged: (value) =>
                                  setState(() => _stroke = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitForm,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.person_add_alt_1, size: 18),
                          label: Text(
                            _isLoading ? 'Salvando...' : 'Salvar paciente',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
