import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/report_model.dart';
import 'sync_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncService _syncService = SyncService();

  Future<List<ReportModel>> getReports({
    String? userId,
    String? officeId,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return await _syncService.getLocalReports(
        userId: userId,
        officeId: officeId,
      );
    }

    Query<Map<String, dynamic>> query = _firestore.collection('reports');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    } else if (officeId != null && officeId.isNotEmpty) {
      query = query.where('officeId', isEqualTo: officeId);
    }

    final snapshot = await query.orderBy('submittedAt', descending: true).get();
    var reports =
        snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();

    if (userId != null && officeId != null && officeId.isNotEmpty) {
      reports = reports.where((r) => r.officeId == officeId).toList();
    }

    for (var report in reports) {
      await _syncService.syncReportToLocal(report);
    }

    return reports;
  }

  Future<void> submitReport(ReportModel report) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      await _syncService.saveReportOffline(report);
    } else {
      await _firestore
          .collection('reports')
          .doc(report.id)
          .set(report.toFirestore());
      await _syncService.syncReportToLocal(report);
    }
  }

  Future<void> syncPendingReports() async {
    await _syncService.syncPendingReports();
  }
}
