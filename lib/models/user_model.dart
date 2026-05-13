import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String fullName;
  final String surname;
  final String nationalId;
  final String phoneNumber;
  final String email;
  final String role; // 'client', 'staff', 'admin', 'office'
  final String? station; // For staff only
  /// Firestore `offices/{id}` — clients, staff, and office portal users belong to an office.
  final String? officeId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.surname,
    required this.nationalId,
    required this.phoneNumber,
    required this.email,
    required this.role,
    this.station,
    this.officeId,
    required this.createdAt,
  });

  String get fullNameWithSurname => '$fullName $surname';

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fullName': fullName,
      'surname': surname,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'station': station,
      'officeId': officeId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'] ?? doc.id,
      fullName: data['fullName'] ?? '',
      surname: data['surname'] ?? '',
      nationalId: data['nationalId'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'client',
      station: data['station'],
      officeId: data['officeId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

