class DoctorModel {
  const DoctorModel({
    required this.uid,
    required this.name,
    required this.crm,
    required this.email,
  });

  final String uid;
  final String name;
  final String crm;
  final String email;

  factory DoctorModel.fromMap(String uid, Map<String, dynamic> data) {
    return DoctorModel(
      uid: uid,
      name: data['name'] as String? ?? '',
      crm: data['crm'] as String? ?? '',
      email: data['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'crm': crm, 'email': email};
}

typedef DoctorProfile = DoctorModel;
