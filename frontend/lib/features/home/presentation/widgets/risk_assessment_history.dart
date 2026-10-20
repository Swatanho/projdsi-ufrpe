import 'package:flutter/material.dart';

import '../../../../models/risk_assessment_model.dart';
import '../../../../services/risk_assessment_service.dart';

class RiskAssessmentHistory extends StatefulWidget {
  const RiskAssessmentHistory({super.key, required this.patientId});

  final String patientId;

  @override
  State<RiskAssessmentHistory> createState() => _RiskAssessmentHistoryState();
}

class _RiskAssessmentHistoryState extends State<RiskAssessmentHistory> {
  late final RiskAssessmentService _service;
  late Stream<List<RiskAssessmentModel>> _assessmentsStream;

  @override
  void initState() {
    super.initState();
    _service = RiskAssessmentService();
    _assessmentsStream = _service.watchAssessments(widget.patientId);
  }

  @override
  void didUpdateWidget(covariant RiskAssessmentHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _assessmentsStream = _service.watchAssessments(widget.patientId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RiskAssessmentModel>>(
      stream: _assessmentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _HistoryMessage(
            icon: Icons.error_outline,
            message: 'Não foi possível carregar o histórico: ${snapshot.error}',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF0D8279)),
            ),
          );
        }

        final assessments = snapshot.data ?? const <RiskAssessmentModel>[];
        if (assessments.isEmpty) {
          return const _HistoryMessage(
            icon: Icons.history,
            message: 'Nenhuma avaliação de risco registrada.',
          );
        }

        return Column(
          children: [
            for (final assessment in assessments)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8E5E3)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: assessment.prediction == 1
                        ? const Color(0xFFFFE8E8)
                        : const Color(0xFFE2F3EF),
                    child: Icon(
                      assessment.prediction == 1
                          ? Icons.warning_amber_rounded
                          : Icons.favorite_outline,
                      color: assessment.prediction == 1
                          ? const Color(0xFFB83F46)
                          : const Color(0xFF0D8279),
                    ),
                  ),
                  title: Text(
                    '${assessment.riskPercentage.toStringAsFixed(1)}% de risco estimado',
                    style: const TextStyle(
                      color: Color(0xFF173A3A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${_modelLabel(assessment.modelName)} · ${assessment.message}\n${_formatDate(assessment.createdAt)}',
                    style: const TextStyle(
                      color: Color(0xFF718383),
                      fontSize: 12,
                    ),
                  ),
                  isThreeLine: true,
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '$day/$month/${localDate.year} às $hour:$minute';
  }

  String _modelLabel(String modelName) {
    return switch (modelName) {
      'xgboost' => 'XGBoost',
      _ => 'Regressão Logística',
    };
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF718383), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF718383), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
