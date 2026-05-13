import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String applicationId;
  final String userId;
  final String userName;
  final String userRole;
  final String comment;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.applicationId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'applicationId': applicationId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: data['id'] ?? doc.id,
      applicationId: data['applicationId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userRole: data['userRole'] ?? '',
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

