import 'package:flutter/material.dart';

import 'prediction_screen.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.registeredAt,
    required this.riskLabel,
    required this.isHighRisk,
  });

  final String patientName;
  final int patientAge;
  final String patientGender;
  final String registeredAt;
  final String riskLabel;
  final bool isHighRisk;

  void _openPrediction(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PredictionScreen(patientName: patientName, patientAge: patientAge),
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
                    _buildPatientSummary(),
                    const SizedBox(height: 20),
                    const Text(
                      'Histórico de Avaliações',
                      style: TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _AssessmentTile(
                      date: '18/10/2024',
                      risk: 'Risco Baixo',
                      score: '22%',
                      color: const Color(0xFF2CA27A),
                    ),
                    _AssessmentTile(
                      date: '04/07/2024',
                      risk: 'Médio Risco',
                      score: '45%',
                      color: const Color(0xFFE8A33A),
                    ),
                    _AssessmentTile(
                      date: '12/03/2024',
                      risk: riskLabel,
                      score: isHighRisk ? '78%' : '18%',
                      color: isHighRisk
                          ? const Color(0xFFD96B70)
                          : const Color(0xFF2CA27A),
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

  Widget _buildPatientSummary() {
    final nameParts = patientName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length > 1
        ? '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase()
        : patientName.substring(0, 1).toUpperCase();

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
                      patientName,
                      style: const TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$patientAge anos • $patientGender',
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
            'Cadastrada em $registeredAt',
            style: const TextStyle(color: Color(0xFF718383), fontSize: 11),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              _PatientTag(label: 'IMC 24.5'),
              _PatientTag(label: 'Hipertensa'),
              _PatientTag(label: 'Ativa'),
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

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({
    required this.date,
    required this.risk,
    required this.score,
    required this.color,
  });

  final String date;
  final String risk;
  final String score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avaliação em $date',
                  style: const TextStyle(
                    color: Color(0xFF718383),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  risk,
                  style: const TextStyle(
                    color: Color(0xFF173A3A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF718383), size: 19),
        ],
      ),
    );
  }
}
