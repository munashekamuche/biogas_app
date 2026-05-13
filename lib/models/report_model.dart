import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String officeId;
  final String staffName;
  final String station;
  final String content;
  final DateTime submittedAt;
  final DateTime? updatedAt;

  ReportModel({
    required this.id,
    required this.userId,
    this.officeId = '',
    required this.staffName,
    required this.station,
    required this.content,
    required this.submittedAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'officeId': officeId,
      'staffName': staffName,
      'station': station,
      'content': content,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      officeId: data['officeId'] as String? ?? '',
      staffName: data['staffName'] ?? '',
      station: data['station'] ?? '',
      content: data['content'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

