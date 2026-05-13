import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../models/report_model.dart';
import '../services/application_service.dart';
import '../services/report_service.dart';

class AppProvider extends ChangeNotifier {
  final ApplicationService _applicationService = ApplicationService();
  final ReportService _reportService = ReportService();

  List<ApplicationModel> _applications = [];
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  StreamSubscription<QuerySnapshot>? _applicationsSubscription;
  StreamSubscription<QuerySnapshot>? _reportsSubscription;

  String? _lastApplicationsUserId;
  String? _lastApplicationsOfficeId;

  List<ApplicationModel> get applications => _applications;
  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadApplications({String? userId, String? officeId}) async {
    _lastApplicationsUserId = userId;
    _lastApplicationsOfficeId = officeId;
    _isLoading = true;
    notifyListeners();

    try {
      _applications = await _applicationService.getApplications(
        userId: userId,
        officeId: officeId,
      );
    } catch (e) {
      debugPrint('Error loading applications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void listenToApplications({String? userId, String? officeId}) {
    _lastApplicationsUserId = userId;
    _lastApplicationsOfficeId = officeId;
    _applicationsSubscription?.cancel();

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('applications');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    } else if (officeId != null && officeId.isNotEmpty) {
      query = query.where('officeId', isEqualTo: officeId);
    }

    _applicationsSubscription = query
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      var list = snapshot.docs
          .map((doc) => ApplicationModel.fromFirestore(doc))
          .toList();
      if (userId != null && officeId != null && officeId.isNotEmpty) {
        list = list.where((a) => a.officeId == officeId).toList();
      }
      _applications = list;
      notifyListeners();
    });
  }

  Future<void> loadReports({String? userId, String? officeId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reports = await _reportService.getReports(
        userId: userId,
        officeId: officeId,
      );
    } catch (e) {
      debugPrint('Error loading reports: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void listenToReports({String? userId, String? officeId}) {
    _reportsSubscription?.cancel();

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('reports');

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    } else if (officeId != null && officeId.isNotEmpty) {
      query = query.where('officeId', isEqualTo: officeId);
    }

    _reportsSubscription = query
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      var list = snapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
      if (userId != null && officeId != null && officeId.isNotEmpty) {
        list = list.where((r) => r.officeId == officeId).toList();
      }
      _reports = list;
      notifyListeners();
    });
  }

  Future<bool> submitApplication(ApplicationModel application) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _applicationService.submitApplication(application);
      await loadApplications(userId: application.userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error in AppProvider.submitApplication: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitReport(ReportModel report) async {
    try {
      await _reportService.submitReport(report);
      await loadReports(userId: report.userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      await _applicationService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
        adminNotes: adminNotes,
      );
      await loadApplications(
        userId: _lastApplicationsUserId,
        officeId: _lastApplicationsOfficeId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
