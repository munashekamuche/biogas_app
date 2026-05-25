import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  final UserService _userService = UserService();
  
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<String?> login({
    required String email,
    required String password,
    String? role,
  }) async {
    _isLoading = true;
    notifyListeners();

    UserCredential? userCredential;
    String? userId;

    try {
      userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      userId = userCredential?.user?.uid;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          _isLoading = false;
          notifyListeners();
          return 'No account found with this email address.';
        case 'wrong-password':
          _isLoading = false;
          notifyListeners();
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          _isLoading = false;
          notifyListeners();
          return 'The email address is invalid. Please check and try again.';
        case 'user-disabled':
          _isLoading = false;
          notifyListeners();
          return 'This account has been disabled. Please contact support.';
        case 'too-many-requests':
          _isLoading = false;
          notifyListeners();
          return 'Too many failed login attempts. Please try again later.';
        case 'operation-not-allowed':
          _isLoading = false;
          notifyListeners();
          return 'Email/password accounts are not enabled. Please contact support.';
        default:
          // Android type cast bug workaround - check if user was signed in despite error
          debugPrint('Firebase Auth error during login: ${e.code} - ${e.message}');
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.email == email) {
            userId = currentUser.uid;
            debugPrint('User was signed in despite error. Proceeding with UID: $userId');
          } else {
            _isLoading = false;
            notifyListeners();
            return 'Login failed: ${e.message ?? 'Unknown error'}';
          }
      }
    } catch (e) {
      // Handle type cast errors (known Android Firebase issue)
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>')) {
        debugPrint('Caught type cast error during login (known Android issue). Checking if user was signed in...');
        // Check if user was actually signed in despite the error
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          userId = currentUser.uid;
          debugPrint('User was signed in despite type cast error. Proceeding with UID: $userId');
        } else {
          _isLoading = false;
          notifyListeners();
          return 'Login failed due to a technical issue. Please try again.';
        }
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Login failed: ${e.toString()}';
      }
    }

    // If we have a userId, proceed with loading user data
    if (userId != null) {
      try {
        // Try to load from local database first (offline support, mobile only)
        try {
          final localUser = kIsWeb
              ? null
              : await _syncService.getUserFromLocal(userId);
          if (localUser != null) {
            debugPrint('Loaded user from local database');
            _currentUser = localUser;
            
            // Verify role if specified
            if (role != null && _currentUser!.role != role) {
              _currentUser = null;
              _isLoading = false;
              notifyListeners();
              return 'Access denied. This account does not have the required permissions.';
            }
            
            _isLoading = false;
            notifyListeners();
            
            // Try to sync from Firestore in background (non-blocking)
            _syncUserFromFirestoreInBackground(userId, role);
            
            return null; // null means success
          }
        } catch (localError) {
          debugPrint('Could not load from local database: $localError');
          // Continue to try Firestore
        }

        // Try to fetch from Firestore with timeout and retry logic
        DocumentSnapshot? userDoc;
        int retries = 0;
        const maxRetries = 1; // Only 1 retry (2 attempts total)
        
        while (retries <= maxRetries && userDoc == null) {
          try {
            userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get()
                .timeout(
                  const Duration(seconds: 3), // Reduced timeout to 3 seconds
                  onTimeout: () {
                    throw Exception('Request timed out. Please check your internet connection.');
                  },
                );
            break; // Success, exit retry loop
          } catch (e) {
            retries++;
            if (retries > maxRetries) {
              // All retries exhausted - proceed with fallback
              debugPrint('Firestore fetch failed after $retries attempts: $e');
              break; // Exit loop to use fallback
            }
            // Wait before retrying (shorter delay)
            await Future.delayed(const Duration(milliseconds: 300));
            debugPrint('Retrying Firestore fetch (attempt $retries/${maxRetries + 1})...');
          }
        }

        if (userDoc != null && userDoc.exists) {
          _currentUser = UserModel.fromFirestore(userDoc);
          
          // Verify role if specified
          if (role != null && _currentUser!.role != role) {
            _currentUser = null;
            _isLoading = false;
            notifyListeners();
            return 'Access denied. This account does not have the required permissions.';
          }
          
          // Sync user data to local database
          try {
            await _syncService.syncUserToLocal(_currentUser!);
          } catch (syncError) {
            debugPrint('Warning: Failed to sync user to local database: $syncError');
            // Continue with login even if local sync fails
          }
          
          _isLoading = false;
          notifyListeners();
          return null; // null means success
        } else {
          debugPrint('User document not found in Firestore for UID: $userId');
          _isLoading = false;
          notifyListeners();
          return 'User profile not found. Please contact support or register again.';
        }
      } on FirebaseException catch (firestoreError) {
        debugPrint('Firestore error during login: ${firestoreError.code} - ${firestoreError.message}');
        
        // Check if we have cached user data
        if (userId != null) {
          try {
            final localUser = await _syncService.getUserFromLocal(userId);
            if (localUser != null) {
              debugPrint('Using cached user data due to Firestore unavailability');
              _currentUser = localUser;
              
              if (role != null && _currentUser!.role != role) {
                _currentUser = null;
                _isLoading = false;
                notifyListeners();
                return 'Access denied. This account does not have the required permissions.';
              }
              
              _isLoading = false;
              notifyListeners();
              
              // Try to sync from Firestore in background
              _syncUserFromFirestoreInBackground(userId, role);
              
              // Success with cached data (user can still use the app)
              return null;
            }
          } catch (e) {
            debugPrint('Could not load cached user: $e');
          }
        }
        
        // If no cached data but credentials are correct, proceed with selected role
        // This allows users to login even when Firestore is temporarily unavailable
        if (userId != null && role != null) {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null && firebaseUser.email == email) {
            debugPrint('Firestore unavailable, proceeding with selected role: $role');
            // Create minimal user object with available data
            _currentUser = UserModel(
              id: userId,
              fullName: firebaseUser.displayName?.split(' ').first ?? 'User',
              surname: (firebaseUser.displayName?.split(' ').length ?? 0) > 1 
                  ? firebaseUser.displayName!.split(' ').skip(1).join(' ')
                  : '',
              nationalId: '',
              phoneNumber: firebaseUser.phoneNumber ?? '',
              email: email,
              role: role,
              station: null,
              officeId: null,
              createdAt: DateTime.now(),
            );
            
            _isLoading = false;
            notifyListeners();
            
            // Try to fetch full user data from Firestore in background
            _syncUserFromFirestoreInBackground(userId, role);
            
            return null; // Success - proceed to dashboard
          }
        }
        
        _isLoading = false;
        notifyListeners();
        
        // Provide specific error messages
        if (firestoreError.code == 'unavailable') {
          return 'Service temporarily unavailable. Please check your internet connection and try again.';
        } else if (firestoreError.code == 'deadline-exceeded') {
          return 'Request timed out. Please check your internet connection.';
        } else {
          return 'Failed to load user data: ${firestoreError.message ?? firestoreError.code}. Please try again.';
        }
      } catch (e) {
        debugPrint('Error fetching user from Firestore: $e');
        
        // Last resort: try cached data
        if (userId != null) {
          try {
            final localUser = await _syncService.getUserFromLocal(userId);
            if (localUser != null) {
              debugPrint('Using cached user data as fallback');
              _currentUser = localUser;
              
              if (role != null && _currentUser!.role != role) {
                _currentUser = null;
                _isLoading = false;
                notifyListeners();
                return 'Access denied. This account does not have the required permissions.';
              }
              
              _isLoading = false;
              notifyListeners();
              return null; // Success with cached data
            }
          } catch (localError) {
            debugPrint('Could not load cached user: $localError');
          }
        }
        
        // If no cached data but credentials are correct, proceed with selected role
        if (userId != null && role != null) {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null && firebaseUser.email == email) {
            debugPrint('Firestore error, proceeding with selected role: $role');
            // Create minimal user object with available data
            _currentUser = UserModel(
              id: userId,
              fullName: firebaseUser.displayName?.split(' ').first ?? 'User',
              surname: (firebaseUser.displayName?.split(' ').length ?? 0) > 1 
                  ? firebaseUser.displayName!.split(' ').skip(1).join(' ')
                  : '',
              nationalId: '',
              phoneNumber: firebaseUser.phoneNumber ?? '',
              email: email,
              role: role,
              station: null,
              officeId: null,
              createdAt: DateTime.now(),
            );
            
            _isLoading = false;
            notifyListeners();
            
            // Try to fetch full user data from Firestore in background
            _syncUserFromFirestoreInBackground(userId, role);
            
            return null; // Success - proceed to dashboard
          }
        }
        
        _isLoading = false;
        notifyListeners();
        
        if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
          return 'Request timed out. Please check your internet connection and try again.';
        }
        return 'Failed to load user data. Please check your internet connection and try again.';
      }
    }
    
    _isLoading = false;
    notifyListeners();
    return 'Login failed. Please try again.';
  }

  // Background sync method (non-blocking)
  void _syncUserFromFirestoreInBackground(String userId, String? role) {
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 5));
        
        if (userDoc.exists) {
          final updatedUser = UserModel.fromFirestore(userDoc);
          
          // Only update if role matches (if specified)
          if (role == null || updatedUser.role == role) {
            _currentUser = updatedUser;
            await _syncService.syncUserToLocal(updatedUser);
            notifyListeners();
            debugPrint('User data synced from Firestore in background');
          }
        }
      } catch (e) {
        debugPrint('Background sync failed: $e');
        // Silent fail - user can still use the app with cached data
      }
    });
  }

  Future<String?> register({
    required String fullName,
    required String surname,
    required String nationalId,
    required String phoneNumber,
    required String email,
    required String password,
    required String role,
    String? officeId,
  }) async {
    _isLoading = true;
    notifyListeners();

    UserCredential? userCredential;
    String? userId;

    try {
      userCredential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      userId = userCredential?.user?.uid;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'email-already-in-use':
          _isLoading = false;
          notifyListeners();
          return 'This email address is already registered. Please use a different email or try logging in.';
        case 'invalid-email':
          _isLoading = false;
          notifyListeners();
          return 'The email address is invalid. Please check and try again.';
        case 'weak-password':
          _isLoading = false;
          notifyListeners();
          return 'The password is too weak. Please use a stronger password.';
        case 'operation-not-allowed':
          _isLoading = false;
          notifyListeners();
          return 'Email/password accounts are not enabled. Please contact support.';
        default:
          // Check if user was created despite the error (Android type cast issue workaround)
          debugPrint('Firebase Auth error during registration: ${e.code} - ${e.message}');
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.email == email) {
            userId = currentUser.uid;
            debugPrint('User was created despite error. Proceeding with UID: $userId');
          } else {
            _isLoading = false;
            notifyListeners();
            return 'Registration failed: ${e.message ?? 'Unknown error'}';
          }
      }
    } catch (e) {
      // Handle type cast errors (known Android Firebase issue)
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>')) {
        debugPrint('Caught type cast error (known Android issue). Checking if user was created...');
        // Check if user was actually created despite the error
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email == email) {
          userId = currentUser.uid;
          debugPrint('User was created despite type cast error. Proceeding with UID: $userId');
        } else {
          _isLoading = false;
          notifyListeners();
          return 'Registration failed due to a technical issue. Please try again.';
        }
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Registration failed: ${e.toString()}';
      }
    }

    // Proceed with creating Firestore document if we have a user ID
    if (userId != null) {
      try {
        final user = UserModel(
          id: userId,
          fullName: fullName,
          surname: surname,
          nationalId: nationalId,
          phoneNumber: phoneNumber,
          email: email,
          role: role,
          officeId: officeId,
          createdAt: DateTime.now(),
        );

        // Create Firestore document with timeout
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set(user.toFirestore())
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  throw Exception('Registration timed out. Please check your internet connection.');
                },
              );
        } catch (e) {
          // If Firestore write fails, still proceed with local user
          debugPrint('Warning: Failed to create Firestore document: $e');
          // Continue anyway - user can sync later
        }

        _currentUser = user;
        
        // Sync user data to local database (non-blocking, don't fail if this errors)
        _syncService.syncUserToLocal(user).catchError((error) {
          debugPrint('Warning: Failed to sync user to local database: $error');
        });
        
        _isLoading = false;
        notifyListeners();
        return null; // null means success
      } catch (firestoreError) {
        debugPrint('Error creating Firestore user document: $firestoreError');
        _isLoading = false;
        notifyListeners();
        return 'Registration partially completed. Please contact support.';
      }
    }
    
    _isLoading = false;
    notifyListeners();
    return 'Registration failed. Please try again.';
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          _currentUser = UserModel.fromFirestore(userDoc);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      // If Firebase fails, try loading from local database
      try {
        await _loadUserFromLocal();
      } catch (localError) {
        debugPrint('Error loading user from local: $localError');
      }
    }
  }

  Future<void> _loadUserFromLocal() async {
    // Try to load user from Isar database
    // Note: This is a fallback if Firebase fails
    // For now, we'll skip local loading to avoid query issues
    // The app will work fine without this - user can just login again
    debugPrint('Skipping local user load - Firebase should handle authentication');
  }

  // Update user profile
  Future<String?> updateProfile({
    required String fullName,
    required String surname,
    required String phoneNumber,
    String? nationalId,
  }) async {
    if (_currentUser == null) {
      return 'User not authenticated';
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUserProfile(
        userId: _currentUser!.id,
        fullName: fullName,
        surname: surname,
        phoneNumber: phoneNumber,
        nationalId: nationalId,
      );

      // Update local user model
      _currentUser = UserModel(
        id: _currentUser!.id,
        fullName: fullName,
        surname: surname,
        nationalId: nationalId ?? _currentUser!.nationalId,
        phoneNumber: phoneNumber,
        email: _currentUser!.email,
        role: _currentUser!.role,
        station: _currentUser!.station,
        officeId: _currentUser!.officeId,
        createdAt: _currentUser!.createdAt,
      );

      // Sync to local database
      await _syncService.syncUserToLocal(_currentUser!);

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to update profile: ${e.toString()}';
    }
  }

  // Change password
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'wrong-password':
          return 'Current password is incorrect.';
        case 'weak-password':
          return 'New password is too weak. Please use a stronger password.';
        default:
          return 'Failed to change password: ${e.message}';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to change password: ${e.toString()}';
    }
  }

  // Send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email address.';
        case 'invalid-email':
          return 'The email address is invalid.';
        default:
          return 'Failed to send reset email: ${e.message}';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to send reset email: ${e.toString()}';
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.id)
          .get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
        await _syncService.syncUserToLocal(_currentUser!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }
}

