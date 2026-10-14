import 'package:flutter/material.dart';

import '../../../../models/patient_model.dart';
import 'prediction_screen.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key, required this.patient});

  final PatientModel patient;

  void _openPrediction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PredictionScreen(
          patientName: patient.name,
          patientAge: patient.age,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  _BackButton(onPressed: () => Navigator.of(context).pop()),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Detalhes do Paciente',
                        style: TextStyle(
                          color: Color(0xFF173A3A),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientSummary(context),
                    const SizedBox(height: 20),
                    const Text(
                      'Avaliações de risco',
                      style: TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD8E5E3)),
                      ),
                      child: const Text(
                        'Nenhuma avaliação de risco registrada.',
                        style: TextStyle(
                          color: Color(0xFF718383),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openPrediction(context),
                  icon: const Icon(Icons.auto_awesome, size: 19),
                  label: const Text('Avaliar risco com IA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D8279),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSummary(BuildContext context) {
    final nameParts = patient.name.trim().split(RegExp(r'\s+'));
    final initials = patient.name.trim().isEmpty
        ? '?'
        : nameParts.length > 1
        ? '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase()
        : patient.name.trim()[0].toUpperCase();
    final registeredAt = MaterialLocalizations.of(
      context,
    ).formatMediumDate(patient.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${patient.age} anos • ${patient.gender}',
                      style: const TextStyle(
                        color: Color(0xFF718383),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFDDF2EF),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF087A72),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Divider(height: 1, color: Color(0xFFE4ECEA)),
          ),
          Text(
            'Cadastrado em $registeredAt',
            style: const TextStyle(color: Color(0xFF718383), fontSize: 11),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              _PatientTag(label: 'IMC ${patient.bmi.toStringAsFixed(1)}'),
              _PatientTag(
                label: 'Pressão alta: ${patient.highBp ? 'Sim' : 'Não'}',
              ),
              _PatientTag(
                label: 'Colesterol alto: ${patient.highChol ? 'Sim' : 'Não'}',
              ),
              _PatientTag(label: 'Fumante: ${patient.smoker ? 'Sim' : 'Não'}'),
              _PatientTag(
                label:
                    'Atividade física: ${patient.physActivity ? 'Sim' : 'Não'}',
              ),
              _PatientTag(label: 'Derrame: ${patient.stroke ? 'Sim' : 'Não'}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        tooltip: 'Voltar',
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back, size: 19, color: Color(0xFF087A72)),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }
}

class _PatientTag extends StatelessWidget {
  const _PatientTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF087A72),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
