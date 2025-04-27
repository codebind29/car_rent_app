// lib/data/models/user_model.dart
class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? licenseNumber;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.licenseNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      licenseNumber :data['licenseNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'licenseNumber':licenseNumber,
    };
  }
}