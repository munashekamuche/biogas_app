import 'dart:convert';
import 'package:isar/isar.dart';

part 'isar_models.g.dart';

@collection
class IsarUser {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String userId;

  String? officeId;

  late String fullName;
  late String surname;
  late String nationalId;
  late String phoneNumber;
  late String email;
  late String role;
  String? station;
  late DateTime createdAt;
}

@collection
class IsarApplication {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String applicationId;
  
  @Index()
  late String userId;

  String? officeId;

  late String serviceType;
  late String biogasType;
  late String formDataJson; // Store as JSON string instead of Map
  late String status;
  late DateTime submittedAt;
  DateTime? updatedAt;
  
  @Index()
  late bool needsSync;
  
  // Helper methods to convert between Map and JSON string
  @ignore
  Map<String, dynamic> getFormData() {
    try {
      return jsonDecode(formDataJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  @ignore
  void setFormData(Map<String, dynamic> data) {
    formDataJson = jsonEncode(data);
  }
}

@collection
class IsarReport {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String reportId;
  
  @Index()
  late String userId;

  String? officeId;

  late String staffName;
  late String station;
  late String content;
  late DateTime submittedAt;
  DateTime? updatedAt;
  
  @Index()
  late bool needsSync;
}

