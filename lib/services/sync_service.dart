import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_model.dart';
import '../models/application_model.dart';
import '../models/report_model.dart';
import '../models/isar_models.dart';
import '../database/isar_service.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User sync
  Future<void> syncUserToLocal(UserModel user) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final isarUser = IsarUser()
      ..userId = user.id
      ..officeId = user.officeId
      ..fullName = user.fullName
      ..surname = user.surname
      ..nationalId = user.nationalId
      ..phoneNumber = user.phoneNumber
      ..email = user.email
      ..role = user.role
      ..station = user.station
      ..createdAt = user.createdAt;

    await isar.writeTxn(() async {
      final existingUsers = await isar.isarUsers.where().filter().userIdEqualTo(user.id).findAll();
      await isar.isarUsers.deleteAll(existingUsers.map((u) => u.id).toList());
      await isar.isarUsers.put(isarUser);
    });
  }

  Future<UserModel?> getUserFromLocal(String userId) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return null;

    try {
      final isarUsers = await isar.isarUsers.where().filter().userIdEqualTo(userId).findAll();
      if (isarUsers.isEmpty) return null;

      final isarUser = isarUsers.first;
      return UserModel(
        id: isarUser.userId,
        fullName: isarUser.fullName,
        surname: isarUser.surname,
        nationalId: isarUser.nationalId,
        phoneNumber: isarUser.phoneNumber,
        email: isarUser.email,
        role: isarUser.role,
        station: isarUser.station,
        officeId: isarUser.officeId,
        createdAt: isarUser.createdAt,
      );
    } catch (e) {
      return null;
    }
  }

  // Application sync
  Future<void> syncApplicationToLocal(ApplicationModel application) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final isarApp = IsarApplication()
      ..applicationId = application.id
      ..userId = application.userId
      ..officeId = application.officeId.isEmpty ? null : application.officeId
      ..serviceType = application.serviceType
      ..biogasType = application.biogasType
      ..setFormData(application.formData)
      ..status = application.status
      ..submittedAt = application.submittedAt
      ..updatedAt = application.updatedAt
      ..needsSync = false;

    await isar.writeTxn(() async {
      final existingApps = await isar.isarApplications.where().filter().applicationIdEqualTo(application.id).findAll();
      await isar.isarApplications.deleteAll(existingApps.map((a) => a.id).toList());
      await isar.isarApplications.put(isarApp);
    });
  }

  Future<List<ApplicationModel>> getLocalApplications({
    String? userId,
    String? officeId,
  }) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return [];

    var isarApps = userId != null
        ? await isar.isarApplications.where().filter().userIdEqualTo(userId).findAll()
        : await isar.isarApplications.where().findAll();

    if (officeId != null && officeId.isNotEmpty) {
      isarApps = isarApps
          .where((a) => (a.officeId ?? '') == officeId)
          .toList();
    }

    return isarApps.map((isarApp) {
      return ApplicationModel(
        id: isarApp.applicationId,
        userId: isarApp.userId,
        officeId: isarApp.officeId ?? '',
        serviceType: isarApp.serviceType,
        biogasType: isarApp.biogasType,
        formData: isarApp.getFormData(),
        status: isarApp.status,
        submittedAt: isarApp.submittedAt,
        updatedAt: isarApp.updatedAt,
      );
    }).toList();
  }

  Future<void> saveApplicationOffline(ApplicationModel application) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final isarApp = IsarApplication()
      ..applicationId = application.id
      ..userId = application.userId
      ..officeId = application.officeId.isEmpty ? null : application.officeId
      ..serviceType = application.serviceType
      ..biogasType = application.biogasType
      ..setFormData(application.formData)
      ..status = application.status
      ..submittedAt = application.submittedAt
      ..updatedAt = application.updatedAt
      ..needsSync = true;

    await isar.writeTxn(() async {
      await isar.isarApplications.put(isarApp);
    });
  }

  Future<void> syncPendingApplications() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final pendingApps = await isar.isarApplications.where().filter().needsSyncEqualTo(true).findAll();

    for (var isarApp in pendingApps) {
      try {
        final application = ApplicationModel(
          id: isarApp.applicationId,
          userId: isarApp.userId,
          officeId: isarApp.officeId ?? '',
          serviceType: isarApp.serviceType,
          biogasType: isarApp.biogasType,
          formData: isarApp.getFormData(),
          status: isarApp.status,
          submittedAt: isarApp.submittedAt,
          updatedAt: isarApp.updatedAt,
        );

        await _firestore
            .collection('applications')
            .doc(application.id)
            .set(application.toFirestore());

        isarApp.needsSync = false;
        await isar.writeTxn(() async {
          await isar.isarApplications.put(isarApp);
        });
      } catch (e) {
        // keep needsSync = true
      }
    }
  }

  Future<void> syncReportToLocal(ReportModel report) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final isarReport = IsarReport()
      ..reportId = report.id
      ..userId = report.userId
      ..officeId = report.officeId.isEmpty ? null : report.officeId
      ..staffName = report.staffName
      ..station = report.station
      ..content = report.content
      ..submittedAt = report.submittedAt
      ..updatedAt = report.updatedAt
      ..needsSync = false;

    await isar.writeTxn(() async {
      final existingReports = await isar.isarReports.where().filter().reportIdEqualTo(report.id).findAll();
      await isar.isarReports.deleteAll(existingReports.map((r) => r.id).toList());
      await isar.isarReports.put(isarReport);
    });
  }

  Future<List<ReportModel>> getLocalReports({
    String? userId,
    String? officeId,
  }) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return [];

    var isarReports = userId != null
        ? await isar.isarReports.where().filter().userIdEqualTo(userId).findAll()
        : await isar.isarReports.where().findAll();

    if (officeId != null && officeId.isNotEmpty) {
      isarReports = isarReports
          .where((r) => (r.officeId ?? '') == officeId)
          .toList();
    }

    return isarReports.map((isarReport) {
      return ReportModel(
        id: isarReport.reportId,
        userId: isarReport.userId,
        officeId: isarReport.officeId ?? '',
        staffName: isarReport.staffName,
        station: isarReport.station,
        content: isarReport.content,
        submittedAt: isarReport.submittedAt,
        updatedAt: isarReport.updatedAt,
      );
    }).toList();
  }

  Future<void> saveReportOffline(ReportModel report) async {
    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final isarReport = IsarReport()
      ..reportId = report.id
      ..userId = report.userId
      ..officeId = report.officeId.isEmpty ? null : report.officeId
      ..staffName = report.staffName
      ..station = report.station
      ..content = report.content
      ..submittedAt = report.submittedAt
      ..updatedAt = report.updatedAt
      ..needsSync = true;

    await isar.writeTxn(() async {
      await isar.isarReports.put(isarReport);
    });
  }

  Future<void> syncPendingReports() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    final isar = IsarService.instance?.isar;
    if (isar == null) return;

    final pendingReports = await isar.isarReports.where().filter().needsSyncEqualTo(true).findAll();

    for (var isarReport in pendingReports) {
      try {
        final report = ReportModel(
          id: isarReport.reportId,
          userId: isarReport.userId,
          officeId: isarReport.officeId ?? '',
          staffName: isarReport.staffName,
          station: isarReport.station,
          content: isarReport.content,
          submittedAt: isarReport.submittedAt,
          updatedAt: isarReport.updatedAt,
        );

        await _firestore
            .collection('reports')
            .doc(report.id)
            .set(report.toFirestore());

        isarReport.needsSync = false;
        await isar.writeTxn(() async {
          await isar.isarReports.put(isarReport);
        });
      } catch (e) {
        // keep needsSync
      }
    }
  }
}
