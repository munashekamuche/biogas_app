import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/office_model.dart';

class OfficeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OfficeModel>> watchAllOffices() {
    return _firestore.collection('offices').snapshots().map((s) {
      final list = s.docs.map(OfficeModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<OfficeModel>> watchActiveOffices() {
    return _firestore
        .collection('offices')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(OfficeModel.fromFirestore).toList());
  }

  Future<List<OfficeModel>> getAllOfficesOnce() async {
    final snap = await _firestore.collection('offices').get();
    final list = snap.docs.map(OfficeModel.fromFirestore).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<OfficeModel>> getActiveOfficesOnce() async {
    final snap = await _firestore
        .collection('offices')
        .where('active', isEqualTo: true)
        .get();
    return snap.docs.map(OfficeModel.fromFirestore).toList();
  }

  Future<String?> createOffice({
    required String name,
    String? region,
  }) async {
    try {
      final id = const Uuid().v4();
      final office = OfficeModel(
        id: id,
        name: name.trim(),
        region: region?.trim(),
        active: true,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('offices').doc(id).set(office.toFirestore());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateOfficeActive({
    required String officeId,
    required bool active,
  }) async {
    try {
      await _firestore.collection('offices').doc(officeId).update({'active': active});
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
