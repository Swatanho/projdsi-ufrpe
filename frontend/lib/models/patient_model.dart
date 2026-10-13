class PatientModel {
  const PatientModel({
    this.id,
    this.doctorId,
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

  final String? id;
  final String? doctorId;
  final String name;
  final int age;
  final String gender;
  final double bmi;
  final bool highBp;
  final bool highChol;
  final bool smoker;
  final bool physActivity;
  final bool stroke;
  final DateTime createdAt;

  factory PatientModel.fromMap(
    Map<String, dynamic> data, {
    String? id,
    String? doctorId,
  }) {
    final createdAt = data['createdAt'];
    return PatientModel(
      id: id,
      doctorId: doctorId,
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender'] as String? ?? '',
      bmi: (data['bmi'] as num?)?.toDouble() ?? 0,
      highBp: data['highBp'] as bool? ?? false,
      highChol: data['highChol'] as bool? ?? false,
      smoker: data['smoker'] as bool? ?? false,
      physActivity: data['physActivity'] as bool? ?? false,
      stroke: data['stroke'] as bool? ?? false,
      createdAt: createdAt is DateTime
          ? createdAt
          : DateTime.tryParse(createdAt as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Cria uma cópia do modelo alterando apenas os campos informados.
  ///
  /// Usado na edição de pacientes, preservando `id`, `doctorId` e os demais
  /// campos que não fazem parte do formulário de edição.
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

  Map<String, dynamic> toMap() => {
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
