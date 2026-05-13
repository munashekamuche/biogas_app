import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String surname,
    required String phoneNumber,
    String? nationalId,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'fullName': fullName,
      'surname': surname,
      'phoneNumber': phoneNumber,
      if (nationalId != null) 'nationalId': nationalId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    await user.updatePassword(newPassword);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<UserModel>> getAllClients({String? officeId}) async {
    Query<Map<String, dynamic>> q =
        _firestore.collection('users').where('role', isEqualTo: 'client');
    if (officeId != null && officeId.isNotEmpty) {
      q = q.where('officeId', isEqualTo: officeId);
    }
    final snapshot = await q.get();
    return snapshot.docs.map(UserModel.fromFirestore).toList();
  }

  Future<List<UserModel>> getAllStaff({String? officeId}) async {
    Query<Map<String, dynamic>> q =
        _firestore.collection('users').where('role', isEqualTo: 'staff');
    if (officeId != null && officeId.isNotEmpty) {
      q = q.where('officeId', isEqualTo: officeId);
    }
    final snapshot = await q.get();
    return snapshot.docs.map(UserModel.fromFirestore).toList();
  }

  Future<String?> createStaffAccount({
    required String fullName,
    required String surname,
    required String nationalId,
    required String phoneNumber,
    required String email,
    required String password,
    required String station,
    String? officeId,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user!.uid;

      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'fullName': fullName,
        'surname': surname,
        'nationalId': nationalId,
        'phoneNumber': phoneNumber,
        'email': email,
        'role': 'staff',
        'station': station,
        'officeId': officeId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to create staff account';
    } catch (e) {
      return 'Failed to create staff account: ${e.toString()}';
    }
  }

  /// Regional office web portal user (sees only their `officeId`).
  Future<String?> createOfficePortalAccount({
    required String fullName,
    required String surname,
    required String nationalId,
    required String phoneNumber,
    required String email,
    required String password,
    required String officeId,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userId = userCredential.user!.uid;

      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'fullName': fullName,
        'surname': surname,
        'nationalId': nationalId,
        'phoneNumber': phoneNumber,
        'email': email,
        'role': 'office',
        'officeId': officeId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to create office account';
    } catch (e) {
      return 'Failed to create office account: ${e.toString()}';
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
