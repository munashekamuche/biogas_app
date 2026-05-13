import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Utility script to create an admin account
/// 
/// Usage:
/// 1. First create the user in Firebase Authentication manually, OR
/// 2. Run this function after Firebase Auth user is created
/// 
/// Example:
/// ```dart
/// await createAdminAccount(
///   email: 'admin@example.com',
///   fullName: 'Admin',
///   surname: 'User',
///   nationalId: '123456789',
///   phoneNumber: '+1234567890',
/// );
/// ```

Future<void> createAdminAccount({
  required String email,
  required String fullName,
  required String surname,
  required String nationalId,
  required String phoneNumber,
  String? userId, // If user already exists in Firebase Auth, provide the UID
}) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    String uid;
    
    if (userId != null) {
      uid = userId;
    } else {
      // Check if user exists in Firestore by email
      try {
        final userQuery = await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        
        if (userQuery.docs.isNotEmpty) {
          uid = userQuery.docs.first.id;
        } else {
          // Check if email is registered in Firebase Auth
          final signInMethods = await auth.fetchSignInMethodsForEmail(email);
          if (signInMethods.isNotEmpty) {
            // Email exists in Auth but not in Firestore
            // We need the UID - try to get current user or require userId
            if (auth.currentUser != null && auth.currentUser!.email == email) {
              uid = auth.currentUser!.uid;
            } else {
              throw Exception(
                'User exists in Firebase Authentication but UID is required. '
                'Please provide the userId parameter, or use createAdminAccountWithAuth() to create both Auth and Firestore records.'
              );
            }
          } else {
            throw Exception(
              'User does not exist in Firebase Authentication. '
              'Please create the user in Firebase Console first, or use createAdminAccountWithAuth() to create both Auth and Firestore records.'
            );
          }
        }
      } catch (e) {
        if (e is Exception) {
          rethrow;
        }
        throw Exception(
          'Error checking user existence: $e. '
          'Please provide the userId parameter, or use createAdminAccountWithAuth() to create both Auth and Firestore records.'
        );
      }
    }

    // Create or update user document in Firestore
    await firestore.collection('users').doc(uid).set({
      'id': uid,
      'fullName': fullName,
      'surname': surname,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': 'admin',
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));

    print('Admin account created successfully!');
    print('Email: $email');
    print('UID: $uid');
  } catch (e) {
    print('Error creating admin account: $e');
    rethrow;
  }
}

/// Helper function to create admin via Firebase Auth and Firestore
/// This requires Firebase Auth to be initialized
Future<void> createAdminAccountWithAuth({
  required String email,
  required String password,
  required String fullName,
  required String surname,
  required String nationalId,
  required String phoneNumber,
}) async {
  try {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    print('Creating Firebase Auth user...');
    
    UserCredential? userCredential;
    String? uid;
    
    // Create user in Firebase Auth with timeout and error handling
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Account creation timed out. Please check your internet connection and try again.'
          );
        },
      );
      uid = userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already registered. Please use a different email or try logging in.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is invalid. Please check and try again.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak. Please use a stronger password (at least 6 characters).');
      } else {
        // Android type cast bug workaround - check if user was created despite error
        print('Firebase Auth error during admin creation: ${e.code} - ${e.message}');
        final currentUser = auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          uid = currentUser.uid;
          print('User was created despite error. Proceeding with UID: $uid');
        } else {
          // Re-throw if it's a real error
          rethrow;
        }
      }
    } catch (e) {
      // Check if it's the Android type cast error
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>')) {
        print('Android type cast error detected. Checking if user was created...');
        final currentUser = auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          uid = currentUser.uid;
          print('User was created despite type cast error. Proceeding with UID: $uid');
        } else {
          throw Exception(
            'Account creation failed due to a system error. Please try again or check your internet connection.'
          );
        }
      } else {
        rethrow;
      }
    }

    if (uid == null) {
      throw Exception('Failed to create user: Could not obtain user ID');
    }

    print('Firebase Auth user created with UID: $uid');

    print('Creating Firestore document...');
    
    // Create user document in Firestore with timeout
    await firestore.collection('users').doc(uid).set({
      'id': uid,
      'fullName': fullName,
      'surname': surname,
      'nationalId': nationalId,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': 'admin',
      'createdAt': Timestamp.now(),
    }).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        // Even if Firestore times out, the Auth user is created
        // So we should still report partial success
        throw Exception(
          'User created in Firebase Auth, but Firestore update timed out. '
          'The user can still login, but you may need to update their role manually in Firestore.'
        );
      },
    );

    print('Admin account created successfully!');
    print('Email: $email');
    print('UID: $uid');
    print('Password: $password (save this securely!)');
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'This email is already registered. Please use a different email or try logging in.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is invalid. Please check and try again.';
        break;
      case 'weak-password':
        errorMessage = 'The password is too weak. Please use a stronger password (at least 6 characters).';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your internet connection and try again.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password accounts are not enabled. Please contact support.';
        break;
      default:
        errorMessage = 'Firebase Auth error: ${e.message ?? e.code}';
    }
    print('Error creating admin account: $errorMessage');
    throw Exception(errorMessage);
  } catch (e) {
    print('Error creating admin account: $e');
    if (e.toString().contains('timeout') || e.toString().contains('timed out')) {
      rethrow; // Re-throw timeout errors as-is
    }
    throw Exception('Failed to create admin account: ${e.toString()}');
  }
}

