class PatientModel {
  final String? id;
  final String doctorId;   // UID do médico que cadastrou o paciente
  final String name;
  final int age;
  final String gender;
  final double bmi;
  final bool highBp;       // Hipertensão
  final bool highChol;     // Colesterol alto
  final bool smoker;       // Tabagismo
  final bool physActivity; // Atividade física
  final bool stroke;       // AVC / Derrame
  final DateTime createdAt;

  PatientModel({
    this.id,
    required this.doctorId,
    required this.name,
    required this.age,
    required this.gender,
    required this.bmi,
    required this.highBp,
    required this.highChol,
    required this.smoker,
    required this.physActivity,
    required this.stroke,
    required this.createdAt,
  });

  /// Constrói o modelo a partir de um documento do Firestore
  /// (coleção `patients/{patientId}`).
  factory PatientModel.fromMap(String id, Map<String, dynamic> map) {
    return PatientModel(
      id: id,
      doctorId: (map['doctorId'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: (map['gender'] as String?) ?? '',
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
      highBp: (map['highBp'] as bool?) ?? false,
      highChol: (map['highChol'] as bool?) ?? false,
      smoker: (map['smoker'] as bool?) ?? false,
      physActivity: (map['physActivity'] as bool?) ?? false,
      stroke: (map['stroke'] as bool?) ?? false,
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Cria uma cópia do modelo alterando apenas os campos informados.
  /// Usado na edição de pacientes.
  PatientModel copyWith({
    String? id,
    String? doctorId,
    String? name,
    int? age,
    String? gender,
    double? bmi,
    bool? highBp,
    bool? highChol,
    bool? smoker,
    bool? physActivity,
    bool? stroke,
    DateTime? createdAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bmi: bmi ?? this.bmi,
      highBp: highBp ?? this.highBp,
      highChol: highChol ?? this.highChol,
      smoker: smoker ?? this.smoker,
      physActivity: physActivity ?? this.physActivity,
      stroke: stroke ?? this.stroke,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'name': name,
      'age': age,
      'gender': gender,
      'bmi': bmi,
      'highBp': highBp,
      'highChol': highChol,
      'smoker': smoker,
      'physActivity': physActivity,
      'stroke': stroke,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}