import 'package:flutter/material.dart';

import '../../../../models/appointment_model.dart';
import '../../../../services/appointment_service.dart';
import '../../../../services/auth_service.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  DateTime _selectedDate = DateTime.now();

  Stream<List<AppointmentModel>> get _appointmentsStream {
    final doctorId = AuthService.instance.currentUserId;
    if (doctorId == null) return const Stream.empty();
    return _appointmentService.watchAppointmentsForDoctor(doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: SafeArea(
        child: StreamBuilder<List<AppointmentModel>>(
          stream: _appointmentsStream,
          builder: (context, snapshot) {
            final appointments = snapshot.data ?? const <AppointmentModel>[];
            final selectedDayAppointments = _appointmentsForDay(
              _selectedDate,
              appointments,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Agenda',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF173A3A),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD8E5E3)),
                    ),
                    child: CalendarDatePicker(
                      key: ValueKey(
                        'agenda-calendar-${DateTime.now().month}-${DateTime.now().year}',
                      ),
                      initialDate: _selectedDate,
                      firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
                      lastDate: DateTime(DateTime.now().year + 2, 12, 31),
                      currentDate: DateTime.now(),
                      onDateChanged: (date) {
                        setState(() => _selectedDate = date);
                        _openDayDialog(date, appointments);
                      },
                    ),
                  ),
                ),
                if (selectedDayAppointments.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF0D8279)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${selectedDayAppointments.length} consulta(s) em ${_formatDate(_selectedDate)}',
                            style: const TextStyle(
                              color: Color(0xFF173A3A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0EAE8))),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: SizedBox(
            width: 220,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              label: const Text('Voltar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF173A3A),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCEE3E0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<AppointmentModel> _appointmentsForDay(
    DateTime date,
    List<AppointmentModel> appointments,
  ) {
    final result = appointments
        .where((appointment) => _isSameDay(appointment.scheduledAt, date))
        .toList();
    result.sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
    return result;
  }

  void _openDayDialog(DateTime day, List<AppointmentModel> appointments) {
    final dayAppointments = _appointmentsForDay(day, appointments);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Consultas de ${_formatDate(day)}',
                          style: const TextStyle(
                            color: Color(0xFF173A3A),
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (dayAppointments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        'Nenhuma consulta agendada para este dia.',
                        style: TextStyle(color: Color(0xFF718383)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: dayAppointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final appointment = dayAppointments[index];
                          return Material(
                            color: const Color(0xFFF5FBFA),
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              title: Text(
                                appointment.patientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF173A3A),
                                ),
                              ),
                              subtitle: Text(
                                '${_formatTime(appointment.scheduledAt)} • ${appointment.description ?? 'Consulta agendada.'}',
                                style: const TextStyle(color: Color(0xFF718383)),
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF718383)),
                              onTap: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => _AppointmentDetailScreen(
                                      appointment: appointment,
                                      onDelete: () async {
                                        await _deleteAppointment(appointment.id ?? '');
                                        if (Navigator.canPop(context)) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      onEdit: () {
                                        Navigator.of(context).pop();
                                        _showAppointmentFormDialog(
                                          date: appointment.scheduledAt,
                                          editing: appointment,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAppointmentFormDialog(
                        date: day,
                        parentDialogContext: dialogContext,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Adicionar consulta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D8279),
                        foregroundColor: Colors.white,
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
      },
    );
  }

  Future<void> _showAppointmentFormDialog({
    required DateTime date,
    AppointmentModel? editing,
    BuildContext? parentDialogContext,
  }) async {
    final patientController = TextEditingController(
      text: editing?.patientName ?? '',
    );
    final timeController = TextEditingController(
      text: editing == null ? '' : _formatTime(editing.scheduledAt),
    );
    final descriptionController = TextEditingController(
      text: editing?.description ?? '',
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(editing == null ? 'Nova consulta' : 'Editar consulta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: Color(0xFF0D8279),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: patientController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do paciente',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  decoration: const InputDecoration(
                    labelText: 'Horário (HH:mm)',
                    hintText: '09:30',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final confirmed = await _confirmCancel();
                if (confirmed) {
                  Navigator.of(dialogContext).pop(false);
                  if (parentDialogContext != null && Navigator.of(parentDialogContext).canPop()) {
                    Navigator.of(parentDialogContext).pop();
                  }
                }
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final patientName = patientController.text.trim();
                final timeText = timeController.text.trim();
                final description = descriptionController.text.trim();

                if (patientName.isEmpty) {
                  _showSnack('Informe o nome do paciente.');
                  return;
                }

                final parsedTime = _parseTime(timeText);
                if (parsedTime == null) {
                  _showSnack('Use o horário em formato 24h, como 09:30.');
                  return;
                }

                final appointmentDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  parsedTime.hour,
                  parsedTime.minute,
                );

                final doctorId = AuthService.instance.currentUserId;
                if (doctorId == null) {
                  _showSnack('Sessão indisponível. Faça login novamente.');
                  return;
                }

                final model = AppointmentModel(
                  id: editing?.id,
                  doctorId: doctorId,
                  patientId: editing?.patientId ?? '',
                  patientName: patientName,
                  scheduledAt: appointmentDate,
                  description: description.isEmpty ? 'Consulta agendada.' : description,
                  notes: editing?.notes,
                );

                try {
                  if (editing == null) {
                    await _appointmentService.addAppointment(doctorId, model);
                  } else {
                    await _appointmentService.updateAppointment(model);
                  }

                  if (mounted) {
                    Navigator.of(dialogContext).pop(true);
                    if (parentDialogContext != null && Navigator.of(parentDialogContext).canPop()) {
                      Navigator.of(parentDialogContext).pop();
                    }
                  }
                } catch (error, stackTrace) {
                  FlutterError.reportError(
                    FlutterErrorDetails(
                      exception: error,
                      stack: stackTrace,
                      library: 'agenda_screen',
                      context: ErrorDescription(
                        'Erro ao salvar consulta na agenda do médico.',
                      ),
                    ),
                  );

                  debugPrint('Erro ao salvar consulta: $error');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Não foi possível salvar a consulta: $error',
                        ),
                        duration: const Duration(seconds: 6),
                      ),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteAppointment(String id) async {
    if (id.isEmpty) return;
    try {
      await _appointmentService.deleteAppointment(id);
    } catch (_) {
      _showSnack('Não foi possível excluir a consulta.');
    }
  }

  Future<bool> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar'),
        content: const Text('Deseja realmente cancelar esta operação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _formatTime(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? _parseTime(String timeText) {
    final sanitized = timeText.trim();
    if (sanitized.isEmpty) return null;
    final pieces = sanitized.split(':');
    if (pieces.length != 2) return null;

    final hour = int.tryParse(pieces[0]);
    final minute = int.tryParse(pieces[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _AppointmentDetailScreen extends StatelessWidget {
  const _AppointmentDetailScreen({
    required this.appointment,
    required this.onDelete,
    required this.onEdit,
  });

  final AppointmentModel appointment;
  final Future<void> Function() onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Consulta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF173A3A),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD8E5E3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paciente',
                      style: TextStyle(color: Color(0xFF718383), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        color: Color(0xFF173A3A),
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoRow(label: 'Data', value: _formatDate(appointment.scheduledAt)),
                    _InfoRow(label: 'Horário', value: _formatTime(appointment.scheduledAt)),
                    _InfoRow(
                      label: 'Descrição',
                      value: appointment.description ?? 'Consulta agendada.',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0EAE8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: onEdit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D8279),
              ),
              child: const Text('Editar'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Excluir consulta'),
                    content: const Text('Deseja realmente excluir esta consulta definitivamente?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await onDelete();
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Color(0xFFB42318))),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String _formatTime(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF718383), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF173A3A),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
