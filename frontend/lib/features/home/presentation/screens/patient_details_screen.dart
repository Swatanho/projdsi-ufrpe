import 'package:flutter/material.dart';

import '../../../../models/patient_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/patient_service.dart';
import '../widgets/risk_assessment_history.dart';
import 'patient_register_screen.dart';
import 'prediction_screen.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key, required this.patient});

  final PatientModel patient;

  void _openPrediction(BuildContext context) {
    final patientId = patient.id;
    if (patientId == null || patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Salve o cadastro do paciente antes de avaliá-lo.'),
          backgroundColor: Color(0xFFB83F46),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PredictionScreen(
          patient: patient,
        ),
      ),
    );
  }

  /// Restrição de posse: apenas o médico dono do cadastro pode editá-lo.
  /// As regras do Firestore aplicam a mesma restrição no servidor; esta
  /// checagem apenas esconde a ação de quem não é o dono.
  bool get _isOwner =>
      patient.doctorId != null &&
      patient.doctorId == AuthService.instance.currentUserId;

  void _openPatientEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientRegisterScreen(
          doctorId: patient.doctorId!,
          patientToEdit: patient,
        ),
      ),
    );
  }

  /// A exclusão exige confirmação explícita; após remover, a tela volta
  /// para a lista, que reage ao stream do Firestore e atualiza sozinha.
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir paciente'),
        content: Text(
          'Deseja realmente excluir o cadastro de ${patient.name}? '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB83F46),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final id = patient.id;
    if (id == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir este paciente.'),
          backgroundColor: Color(0xFFB83F46),
        ),
      );
      return;
    }

    try {
      await PatientService().deletePatient(id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paciente excluído com sucesso.'),
          backgroundColor: Color(0xFF0D8279),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: const Color(0xFFB83F46),
        ),
      );
    }
  }

  // --- CÁLCULOS DE MÉTRICAS VISUAIS ---

  int get _riskFactorCount {
    int count = 0;
    if (patient.highBp) count++;
    if (patient.highChol) count++;
    if (patient.smoker) count++;
    if (!patient.physActivity) count++;
    if (patient.stroke) count++;
    if (patient.bmi >= 25) count++;
    return count;
  }

  Color get _riskColor {
    final count = _riskFactorCount;
    if (count <= 1) return const Color(0xFF0D8279); // Baixo
    if (count <= 3) return const Color(0xFFD97706); // Moderado
    return const Color(0xFFB83F46); // Elevado
  }

  String get _riskLabel {
    final count = _riskFactorCount;
    if (count <= 1) return 'Perfil de Baixo Risco';
    if (count <= 3) return 'Perfil de Risco Moderado';
    return 'Perfil de Risco Elevado';
  }

  Map<String, dynamic> _getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return {'label': 'Abaixo do peso', 'color': Colors.blue};
    } else if (bmi < 25.0) {
      return {'label': 'Peso adequado', 'color': const Color(0xFF0D8279)};
    } else if (bmi < 30.0) {
      return {'label': 'Sobrepeso', 'color': const Color(0xFFD97706)};
    } else {
      return {'label': 'Obesidade', 'color': const Color(0xFFB83F46)};
    }
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
                  _isOwner
                      ? _EditButton(onPressed: () => _openPatientEdit(context))
                      : const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context),
                    const SizedBox(height: 14),
                    _buildRiskSummaryBanner(),
                    const SizedBox(height: 14),
                    _buildMetricsGrid(),
                    const SizedBox(height: 20),
                    const Text(
                      'Histórico de Avaliações',
                      style: TextStyle(
                        color: Color(0xFF173A3A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (patient.id != null && patient.id!.isNotEmpty)
                      RiskAssessmentHistory(patientId: patient.id!)
                    else
                      const Text(
                        'Salve o cadastro do paciente para consultar o histórico.',
                        style: TextStyle(
                          color: Color(0xFF718383),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
            if (_isOwner)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 19),
                    label: const Text('Excluir paciente'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB83F46),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFD8E5E3)),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
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

  // --- WIDGETS DE VISUALIZAÇÃO ---

  Widget _buildHeaderCard(BuildContext context) {
    final nameParts = patient.name.trim().split(RegExp(r'\s+'));
    final initials = patient.name.trim().isEmpty
        ? '?'
        : nameParts.length > 1
            ? '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase()
            : patient.name.trim()[0].toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFDDF2EF),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF087A72),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    color: Color(0xFF173A3A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${patient.age} anos • Sexo: ${patient.gender}',
                  style: const TextStyle(
                    color: Color(0xFF718383),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSummaryBanner() {
    final color = _riskColor;
    final totalFactors = 6;
    final progress = (_riskFactorCount / totalFactors).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E5E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _riskLabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_riskFactorCount de $totalFactors Fatores',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE4ECEA),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final bmiInfo = _getBmiCategory(patient.bmi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card do IMC
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD8E5E3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Índice de Massa Corporal (IMC)',
                    style: TextStyle(
                      color: Color(0xFF718383),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (bmiInfo['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bmiInfo['label'] as String,
                      style: TextStyle(
                        color: bmiInfo['color'] as Color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                patient.bmi.toStringAsFixed(1),
                style: TextStyle(
                  color: bmiInfo['color'] as Color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid de Indicadores Clínicos & Estilo de Vida
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.favorite_outline,
                title: 'Pressão Alta',
                value: patient.highBp ? 'Presente' : 'Normal',
                isAlert: patient.highBp,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.water_drop_outlined,
                title: 'Colesterol Alto',
                value: patient.highChol ? 'Alterado' : 'Normal',
                isAlert: patient.highChol,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.smoking_rooms_outlined,
                title: 'Fagismo',
                value: patient.smoker ? 'Fumante' : 'Não fumante',
                isAlert: patient.smoker,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.fitness_center_outlined,
                title: 'Ativ. Física',
                value: patient.physActivity ? 'Ativo' : 'Sedentário',
                isAlert: !patient.physActivity,
              ),
            ),
          ],
        ),
        if (patient.stroke) ...[
          const SizedBox(height: 10),
          const _MetricTile(
            icon: Icons.warning_amber_rounded,
            title: 'Histórico de AVC / Derrame',
            value: 'Sim (Histórico positivo)',
            isAlert: true,
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isAlert,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final activeColor = isAlert ? const Color(0xFFB83F46) : const Color(0xFF0D8279);
    final bgColor = isAlert ? const Color(0xFFFDF2F2) : const Color(0xFFF0F9F8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activeColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: activeColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF718383),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: activeColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
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

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        tooltip: 'Editar paciente',
        onPressed: onPressed,
        icon: const Icon(
          Icons.edit_outlined,
          size: 19,
          color: Color(0xFF087A72),
        ),
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
