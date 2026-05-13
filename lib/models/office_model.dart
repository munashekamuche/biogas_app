import 'package:cloud_firestore/cloud_firestore.dart';

class OfficeModel {
  final String id;
  final String name;
  final String? region;
  final bool active;
  final DateTime createdAt;

  OfficeModel({
    required this.id,
    required this.name,
    this.region,
    this.active = true,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OfficeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OfficeModel(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String? ?? doc.id,
      region: data['region'] as String?,
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
