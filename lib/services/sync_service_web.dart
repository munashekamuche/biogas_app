import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/application_model.dart';
import '../models/report_model.dart';

/// Web: no Isar — all data lives in Firestore (shared with mobile apps).
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncUserToLocal(UserModel user) async {}

  Future<UserModel?> getUserFromLocal(String userId) async => null;

  Future<void> syncApplicationToLocal(ApplicationModel application) async {}

  Future<List<ApplicationModel>> getLocalApplications({
    String? userId,
    String? officeId,
  }) async =>
      [];

  Future<void> saveApplicationOffline(ApplicationModel application) async {
    await _firestore
        .collection('applications')
        .doc(application.id)
        .set(application.toFirestore(), SetOptions(merge: true));
  }

  Future<void> syncPendingApplications() async {}

  Future<void> syncReportToLocal(ReportModel report) async {}

  Future<List<ReportModel>> getLocalReports({
    String? userId,
    String? officeId,
  }) async =>
      [];

  Future<void> saveReportOffline(ReportModel report) async {
    await _firestore
        .collection('reports')
        .doc(report.id)
        .set(report.toFirestore(), SetOptions(merge: true));
  }

  Future<void> syncPendingReports() async {}
}
