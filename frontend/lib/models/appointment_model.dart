import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  const AppointmentModel({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.scheduledAt,
    this.status = 'scheduled',
    this.notes,
    this.description,
  });

  final String? id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final DateTime scheduledAt;
  final String status;
  final String? notes;
  final String? description;

  factory AppointmentModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final scheduledAt = data['scheduledAt'];
    final parsedScheduledAt = scheduledAt is Timestamp
        ? scheduledAt.toDate()
        : scheduledAt is DateTime
        ? scheduledAt
        : DateTime.tryParse(scheduledAt as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);

    return AppointmentModel(
      id: id,
      doctorId: data['doctorId'] as String? ?? '',
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      scheduledAt: parsedScheduledAt,
      status: data['status'] as String? ?? 'scheduled',
      notes: data['notes'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'patientId': patientId,
    'patientName': patientName,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'status': status,
    if (notes != null) 'notes': notes,
    if (description != null && description!.isNotEmpty) 'description': description,
  };

  static List<AppointmentModel> sortByScheduledAt(
    List<AppointmentModel> appointments,
  ) {
    final sorted = List<AppointmentModel>.from(appointments);
    sorted.sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
    return sorted;
  }
}
