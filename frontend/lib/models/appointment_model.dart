class AppointmentModel {
  const AppointmentModel({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.scheduledAt,
    this.status = 'scheduled',
    this.notes,
  });

  final String? id;
  final String doctorId;
  final String patientId;
  final DateTime scheduledAt;
  final String status;
  final String? notes;

  factory AppointmentModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final scheduledAt = data['scheduledAt'];
    return AppointmentModel(
      id: id,
      doctorId: data['doctorId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      scheduledAt: scheduledAt is DateTime
          ? scheduledAt
          : DateTime.tryParse(scheduledAt as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
      status: data['status'] as String? ?? 'scheduled',
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'patientId': patientId,
    'scheduledAt': scheduledAt.toIso8601String(),
    'status': status,
    if (notes != null) 'notes': notes,
  };
}
