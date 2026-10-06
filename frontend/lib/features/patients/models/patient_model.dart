class PatientModel {
  final String? id;
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

  Map<String, dynamic> toMap() {
    return {
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