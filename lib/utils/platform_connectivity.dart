import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Web always uses Firestore (browser network + Firebase SDK).
/// Mobile uses Isar only when truly offline.
Future<bool> isDeviceOffline() async {
  if (kIsWeb) return false;
  final result = await Connectivity().checkConnectivity();
  return result == ConnectivityResult.none;
}

bool get usesLocalDatabase => !kIsWeb;
