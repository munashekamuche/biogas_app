import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import 'sync_service.dart';
import 'notification_service.dart';

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SyncService _syncService = SyncService();
  final NotificationService _notificationService = NotificationService();

  Future<List<ApplicationModel>> getApplications({
    String? userId,
    String? officeId,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return await _syncService.getLocalApplications(
        userId: userId,
        officeId: officeId,
      );
    }

    Query<Map<String, dynamic>> query = _firestore.collection('applications');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    } else if (officeId != null && officeId.isNotEmpty) {
      query = query.where('officeId', isEqualTo: officeId);
    }

    final snapshot = await query.orderBy('submittedAt', descending: true).get();
    var applications =
        snapshot.docs.map((doc) => ApplicationModel.fromFirestore(doc)).toList();

    if (userId != null && officeId != null && officeId.isNotEmpty) {
      applications =
          applications.where((a) => a.officeId == officeId).toList();
    }

    for (var app in applications) {
      await _syncService.syncApplicationToLocal(app);
    }

    return applications;
  }

  Future<void> submitApplication(ApplicationModel application) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        await _syncService.saveApplicationOffline(application);
      } else {
        await _firestore
            .collection('applications')
            .doc(application.id)
            .set(application.toFirestore(), SetOptions(merge: false));
        await _syncService.syncApplicationToLocal(application);
      }
    } catch (e) {
      debugPrint('Error submitting application: $e');
      try {
        await _syncService.saveApplicationOffline(application);
      } catch (offlineError) {
        debugPrint('Error saving application offline: $offlineError');
        rethrow;
      }
      rethrow;
    }
  }

  Future<void> syncPendingApplications() async {
    await _syncService.syncPendingApplications();
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? adminNotes,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Cannot update application status while offline');
    }

    final currentDoc =
        await _firestore.collection('applications').doc(applicationId).get();
    final oldStatus = currentDoc.exists
        ? (currentDoc.data()?['status'] as String? ?? 'pending')
        : 'pending';
    final userId = currentDoc.exists
        ? (currentDoc.data()?['userId'] as String? ?? '')
        : '';

    await _firestore.collection('applications').doc(applicationId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
      if (adminNotes != null) 'adminNotes': adminNotes,
    });

    final doc =
        await _firestore.collection('applications').doc(applicationId).get();
    if (doc.exists) {
      final application = ApplicationModel.fromFirestore(doc);
      await _syncService.syncApplicationToLocal(application);
    }

    if (oldStatus != status && userId.isNotEmpty) {
      await _notificationService.notifyStatusUpdate(
        userId: userId,
        applicationId: applicationId,
        oldStatus: oldStatus,
        newStatus: status,
      );
    }
  }
}
