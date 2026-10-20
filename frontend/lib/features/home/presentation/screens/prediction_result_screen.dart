import 'package:flutter/material.dart';

import '../../../../models/risk_assessment_model.dart';
import '../widgets/risk_assessment_history.dart';

class PredictionResultScreen extends StatelessWidget {
  const PredictionResultScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.modelLabel,
    required this.assessment,
    this.saveError,
  });

  final String patientId;
  final String patientName;
  final String modelLabel;
  final RiskAssessmentModel assessment;
  final String? saveError;

  @override
  Widget build(BuildContext context) {
    final hasDetectedRisk = assessment.prediction == 1;
    final resultColor = hasDetectedRisk
        ? const Color(0xFFB83F46)
        : const Color(0xFF0D8279);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF173A3A),
                  ),
                  const Expanded(
                    child: Text(
                      'Resultado da avaliação',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paciente: $patientName',
                      style: const TextStyle(
                        color: Color(0xFF718383),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFD8E5E3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            hasDetectedRisk
                                ? Icons.monitor_heart
                                : Icons.favorite,
                            color: resultColor,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${assessment.riskPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: resultColor,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'risco estimado pelo modelo',
                            style: TextStyle(
                              color: Color(0xFF718383),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: assessment.riskPercentage / 100,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFE8EFEE),
                              valueColor: AlwaysStoppedAnimation(resultColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            assessment.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF173A3A),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Modelo: $modelLabel',
                            style: const TextStyle(
                              color: Color(0xFF718383),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Esta estimativa é um apoio à avaliação clínica e não substitui o diagnóstico de um profissional de saúde.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF718383),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (saveError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8C79F)),
                        ),
                        child: Text(
                          'O resultado foi calculado, mas não foi salvo no histórico: $saveError',
                          style: const TextStyle(
                            color: Color(0xFF7A4B18),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'Histórico de avaliações',
                      style: TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RiskAssessmentHistory(patientId: patientId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
