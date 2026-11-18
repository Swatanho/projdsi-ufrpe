import 'package:flutter/material.dart';

import '../../../../models/appointment_model.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/auth_service.dart';

// ============================================================================
// 1. TOKENS DE COR
// ============================================================================
abstract final class _AgendaColors {
  static const background = Color(0xFFF4F8F7);
  static const surface = Colors.white;
  static const primary = Color(0xFF0D8279);
  static const primarySoft = Color(0xFFEAF7F5);
  static const textPrimary = Color(0xFF173A3A);
  static const textSecondary = Color(0xFF718383);
  static const border = Color(0xFFD8E5E3);
  static const badgeNeutral = Color(0xFFE6EEEC);
  static const cardShadow = Color(0x0A173A3A);
  static const danger = Color(0xFFB42318);
  static const dangerSoft = Color(0xFFFEF3F2);
}

// ============================================================================
// 2. UTILITÁRIOS DE DATA E HORA (SRP: Formatação e comparação temporal)
// ============================================================================
abstract final class _AgendaDateUtils {
  static String formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatTimeOfDay(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

// ============================================================================
// 3. CONTROLADOR DA AGENDA (SRP: Comunicação com serviço e filtragem)
// ============================================================================
class _AgendaController {
  _AgendaController({AppointmentService? service})
      : _service = service ?? AppointmentService();

  final AppointmentService _service;

  String? get currentDoctorId => AuthService.instance.currentUserId;

  Stream<List<AppointmentModel>> watchAppointments() {
    final doctorId = currentDoctorId;
    if (doctorId == null || doctorId.isEmpty) return const Stream.empty();
    return _service.getAppointmentsByDoctor(doctorId);
  }

  List<AppointmentModel> filterByDay(
    DateTime date,
    List<AppointmentModel> allAppointments,
  ) {
    final filtered = allAppointments
        .where((item) => _AgendaDateUtils.isSameDay(item.scheduledAt, date))
        .toList();
    return AppointmentModel.sortByScheduledAt(filtered);
  }

  Future<void> saveAppointment({
    required DateTime date,
    required TimeOfDay time,
    required String patientName,
    required String description,
    AppointmentModel? existing,
  }) async {
    final doctorId = currentDoctorId;
    if (doctorId == null || doctorId.isEmpty) {
      throw StateError('Sessão indisponível. Faça login novamente.');
    }

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final model = AppointmentModel(
      id: existing?.id,
      doctorId: doctorId,
      patientId: existing?.patientId ?? '',
      patientName: patientName.trim(),
      scheduledAt: scheduledAt,
      description:
          description.trim().isEmpty ? 'Consulta agendada.' : description.trim(),
      notes: existing?.notes,
    );

    if (existing == null) {
      await _service.addAppointment(doctorId, model);
    } else {
      await _service.updateAppointment(model);
    }
  }

  Future<void> deleteAppointment(String? id) async {
    if (id == null || id.isEmpty) {
      throw ArgumentError('ID da consulta inválido.');
    }
    await _service.deleteAppointment(id);
  }
}

// ============================================================================
// 4. TELA PRINCIPAL DA AGENDA (SRP: Exibição e navegação)
// ============================================================================
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late final _AgendaController _controller = _AgendaController();
  DateTime _selectedDate = DateTime.now();

  void _selectToday() {
    setState(() => _selectedDate = DateTime.now());
  }

  Future<void> _openAppointmentForm({AppointmentModel? editing}) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppointmentFormDialog(
        date: editing?.scheduledAt ?? _selectedDate,
        controller: _controller,
        editing: editing,
      ),
    );

    if (saved == true && mounted) {
      _showFeedback(
        editing == null
            ? 'Consulta agendada com sucesso.'
            : 'Consulta atualizada com sucesso.',
      );
    }
  }

  Future<void> _openAppointmentDetails(AppointmentModel appointment) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AppointmentDetailScreen(
          appointment: appointment,
          controller: _controller,
          onFeedback: _showFeedback,
        ),
      ),
    );
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? _AgendaColors.danger : _AgendaColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: _AgendaColors.background,
      appBar: AppBar(
        backgroundColor: _AgendaColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _AgendaColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Agenda Médica',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _AgendaColors.textPrimary,
            fontSize: 20,
          ),
        ),
        actions: [
          if (!_AgendaDateUtils.isSameDay(_selectedDate, now))
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: _selectToday,
                icon: const Icon(Icons.today_rounded, size: 18),
                label: const Text('Hoje'),
                style: TextButton.styleFrom(
                  foregroundColor: _AgendaColors.primary,
                  backgroundColor: _AgendaColors.primarySoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAppointmentForm(),
        backgroundColor: _AgendaColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nova consulta',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _controller.watchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _AgendaColors.primary),
            );
          }

          final allAppointments = snapshot.data ?? const <AppointmentModel>[];
          final dayAppointments =
              _controller.filterByDay(_selectedDate, allAppointments);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _CalendarCard(
                    selectedDate: _selectedDate,
                    onDateChanged: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: _DaySummaryHeader(
                    date: _selectedDate,
                    count: dayAppointments.length,
                  ),
                ),
              ),
              if (dayAppointments.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyDayState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  sliver: SliverList.separated(
                    itemCount: dayAppointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final appointment = dayAppointments[index];
                      return _AppointmentCard(
                        appointment: appointment,
                        onTap: () => _openAppointmentDetails(appointment),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// 5. COMPONENTES DE UI ISOLADOS
// ============================================================================
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.selectedDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: _AgendaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AgendaColors.border),
        boxShadow: const [
          BoxShadow(
            color: _AgendaColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: _AgendaColors.primary,
                onPrimary: Colors.white,
                onSurface: _AgendaColors.textPrimary,
              ),
        ),
        child: CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(now.year - 1, 1, 1),
          lastDate: DateTime(now.year + 2, 12, 31),
          currentDate: now,
          onDateChanged: onDateChanged,
        ),
      ),
    );
  }
}

class _DaySummaryHeader extends StatelessWidget {
  const _DaySummaryHeader({required this.date, required this.count});

  final DateTime date;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Consultas • ${_AgendaDateUtils.formatDate(date)}',
          style: const TextStyle(
            color: _AgendaColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: count > 0
                ? _AgendaColors.primarySoft
                : _AgendaColors.badgeNeutral,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count ${count == 1 ? 'agendada' : 'agendadas'}',
            style: TextStyle(
              color:
                  count > 0 ? _AgendaColors.primary : _AgendaColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AgendaColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _AgendaColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _AgendaColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: _AgendaColors.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _AgendaDateUtils.formatTime(appointment.scheduledAt),
                      style: const TextStyle(
                        color: _AgendaColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _AgendaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.description ?? 'Consulta agendada.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AgendaColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _AgendaColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: _AgendaColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_available_rounded,
              size: 32,
              color: _AgendaColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dia livre',
            style: TextStyle(
              color: _AgendaColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nenhuma consulta agendada para esta data.\nToque em "Nova consulta" para adicionar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AgendaColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. FORMULÁRIO ISOLADO (SRP: Validação, ciclo de vida e submissão)
// ============================================================================
class _AppointmentFormDialog extends StatefulWidget {
  const _AppointmentFormDialog({
    required this.date,
    required this.controller,
    this.editing,
  });

  final DateTime date;
  final _AgendaController controller;
  final AppointmentModel? editing;

  @override
  State<_AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<_AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _patientController;
  late final TextEditingController _descriptionController;

  TimeOfDay? _selectedTime;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _patientController =
        TextEditingController(text: widget.editing?.patientName ?? '');
    _descriptionController =
        TextEditingController(text: widget.editing?.description ?? '');

    if (widget.editing != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.editing!.scheduledAt);
    }
  }

  @override
  void dispose() {
    _patientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _submit() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;
    if (!isValidForm) return;

    if (_selectedTime == null) {
      setState(() => _errorMessage = 'Selecione um horário para a consulta.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.controller.saveAppointment(
        date: widget.date,
        time: _selectedTime!,
        patientName: _patientController.text,
        description: _descriptionController.text,
        existing: widget.editing,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Erro ao salvar consulta: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;

    return AlertDialog(
      backgroundColor: _AgendaColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        isEditing ? 'Editar consulta' : 'Nova consulta',
        style: const TextStyle(
          color: _AgendaColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _AgendaColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: _AgendaColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _AgendaDateUtils.formatDate(widget.date),
                      style: const TextStyle(
                        color: _AgendaColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nome do paciente',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do paciente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _isSaving ? null : _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Horário',
                    prefixIcon: const Icon(Icons.access_time_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedTime == null
                        ? 'Toque para selecionar'
                        : _AgendaDateUtils.formatTimeOfDay(_selectedTime!),
                    style: TextStyle(
                      color: _selectedTime == null
                          ? _AgendaColors.textSecondary
                          : _AgendaColors.textPrimary,
                      fontWeight: _selectedTime == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Observações / Motivo',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: _AgendaColors.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: _AgendaColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

// ============================================================================
// 7. TELA DE DETALHES DA CONSULTA (SRP: Exibição e ações do item)
// ============================================================================
class _AppointmentDetailScreen extends StatelessWidget {
  const _AppointmentDetailScreen({
    required this.appointment,
    required this.controller,
    required this.onFeedback,
  });

  final AppointmentModel appointment;
  final _AgendaController controller;
  final void Function(String message, {bool isError}) onFeedback;

  Future<void> _handleEdit(BuildContext context) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppointmentFormDialog(
        date: appointment.scheduledAt,
        controller: controller,
        editing: appointment,
      ),
    );

    if (updated == true && context.mounted) {
      onFeedback('Consulta atualizada com sucesso.');
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir consulta'),
        content: const Text(
          'Deseja realmente excluir esta consulta definitivamente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: _AgendaColors.danger,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await controller.deleteAppointment(appointment.id);
      if (context.mounted) {
        onFeedback('Consulta excluída com sucesso.');
        Navigator.of(context).pop();
      }
    } catch (error) {
      onFeedback('Não foi possível excluir: $error', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AgendaColors.background,
      appBar: AppBar(
        backgroundColor: _AgendaColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _AgendaColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalhes da Consulta',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _AgendaColors.textPrimary,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _AgendaColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _AgendaColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _AgendaColors.primarySoft,
                    child: Text(
                      appointment.patientName.isNotEmpty
                          ? appointment.patientName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: _AgendaColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paciente',
                          style: TextStyle(
                            color: _AgendaColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          appointment.patientName,
                          style: const TextStyle(
                            color: _AgendaColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Divider(color: _AgendaColors.border, height: 1),
              ),
              _DetailInfoTile(
                icon: Icons.calendar_today_rounded,
                label: 'Data',
                value: _AgendaDateUtils.formatDate(appointment.scheduledAt),
              ),
              _DetailInfoTile(
                icon: Icons.access_time_rounded,
                label: 'Horário',
                value: _AgendaDateUtils.formatTime(appointment.scheduledAt),
              ),
              _DetailInfoTile(
                icon: Icons.notes_rounded,
                label: 'Descrição / Motivo',
                value: appointment.description ?? 'Consulta agendada.',
                isLast: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: const BoxDecoration(
          color: _AgendaColors.surface,
          border: Border(top: BorderSide(color: _AgendaColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: const Text('Excluir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _AgendaColors.danger,
                    backgroundColor: _AgendaColors.dangerSoft,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => _handleEdit(context),
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  label: const Text('Editar consulta'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _AgendaColors.primary,
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
}

class _DetailInfoTile extends StatelessWidget {
  const _DetailInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: _AgendaColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _AgendaColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: _AgendaColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}