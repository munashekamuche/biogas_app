import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _clients = [];
  List<UserModel> _staff = [];
  bool _isLoading = false;

  List<UserModel> get clients => _clients;
  List<UserModel> get staff => _staff;
  bool get isLoading => _isLoading;

  Future<void> loadClients({String? officeId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _clients = await _userService.getAllClients(officeId: officeId);
    } catch (e) {
      debugPrint('Error loading clients: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStaff({String? officeId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _staff = await _userService.getAllStaff(officeId: officeId);
    } catch (e) {
      debugPrint('Error loading staff: $e');
    }

    _isLoading = false;
    notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    try {
      final error = await _userService.createStaffAccount(
        fullName: fullName,
        surname: surname,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        station: station,
        officeId: officeId,
      );

      if (error == null) {
        await loadStaff();
      }

      _isLoading = false;
      notifyListeners();
      return error;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to create staff account: ${e.toString()}';
    }
  }

  Future<String?> createOfficePortalAccount({
    required String fullName,
    required String surname,
    required String nationalId,
    required String phoneNumber,
    required String email,
    required String password,
    required String officeId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final error = await _userService.createOfficePortalAccount(
        fullName: fullName,
        surname: surname,
        nationalId: nationalId,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        officeId: officeId,
      );

      _isLoading = false;
      notifyListeners();
      return error;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  Future<bool> deleteUser(
    String userId,
    String role, {
    String? officeId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userService.deleteUser(userId);

      if (success) {
        if (role == 'client') {
          await loadClients(officeId: officeId);
        } else if (role == 'staff') {
          await loadStaff(officeId: officeId);
        }
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
