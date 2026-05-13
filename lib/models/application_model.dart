import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String userId;
  /// Links request to a regional office (`offices` collection).
  final String officeId;
  final String serviceType; // 'grid_solar' or 'biogas'
  final String biogasType; // 'homestead' or 'institutional' (if biogas)
  final Map<String, dynamic> formData;
  final String status; // 'pending', 'approved', 'rejected', 'in_progress'
  final DateTime submittedAt;
  final DateTime? updatedAt;

  ApplicationModel({
    required this.id,
    required this.userId,
    this.officeId = '',
    required this.serviceType,
    this.biogasType = '',
    required this.formData,
    this.status = 'pending',
    required this.submittedAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'officeId': officeId,
      'serviceType': serviceType,
      'biogasType': biogasType,
      'formData': formData,
      'status': status,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      officeId: data['officeId'] as String? ?? '',
      serviceType: data['serviceType'] ?? '',
      biogasType: data['biogasType'] ?? '',
      formData: Map<String, dynamic>.from(data['formData'] ?? {}),
      status: data['status'] ?? 'pending',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

