import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class FormConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load form fields from Firestore or local JSON
  /// Priority: Firestore > Local JSON > Default fields
  /// Returns sections if available, otherwise flat fields list
  Future<Map<String, dynamic>> loadFormFields({
    String? serviceType,
    String? biogasType,
  }) async {
    // For solar and biogas, always use code-defined defaults so we can
    // precisely control homestead vs institutional quotation fields.
    if (serviceType == 'solar' || serviceType == 'biogas') {
      final defaultData = _getDefaultFields(serviceType, biogasType);
      return {'fields': defaultData, 'hasSections': false};
    }

    try {
      // Map new logical service types to existing config keys where needed
      final lookupServiceType =
          serviceType == 'grid' ? 'grid_solar' : (serviceType ?? 'default');

      // Try to load from Firestore first
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        try {
          final doc = await _firestore
              .collection('form_configs')
              .doc(lookupServiceType)
              .get();

          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            // Check if it has sections
            if (data['sections'] != null) {
              return {'sections': data['sections'], 'hasSections': true};
            }
            // Or flat fields
            final fields = data['fields'] as List<dynamic>?;
            if (fields != null) {
              return {'fields': fields.cast<Map<String, dynamic>>(), 'hasSections': false};
            }
          }
        } catch (e) {
          // Fall through to local JSON
        }
      }

      // Try to load from local JSON
      try {
        final jsonString = await rootBundle.loadString('assets/config/form_fields.json');
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        final serviceFields =
            jsonData[lookupServiceType] as Map<String, dynamic>?;
        if (serviceFields != null) {
          // Check if it has sections
          if (serviceFields['sections'] != null) {
            return {'sections': serviceFields['sections'], 'hasSections': true};
          }
          // Or flat fields
          final fields = serviceFields['fields'] as List<dynamic>?;
          if (fields != null) {
            return {'fields': fields.cast<Map<String, dynamic>>(), 'hasSections': false};
          }
        }
      } catch (e) {
        // Fall through to default fields
      }

      // Return default fields
      final defaultData = _getDefaultFields(serviceType, biogasType);
      if (serviceType == 'grid_solar') {
        return {'sections': defaultData, 'hasSections': true};
      }
      return {'fields': defaultData, 'hasSections': false};
    } catch (e) {
      final defaultData = _getDefaultFields(serviceType, biogasType);
      if (serviceType == 'grid_solar') {
        return {'sections': defaultData, 'hasSections': true};
      }
      return {'fields': defaultData, 'hasSections': false};
    }
  }

  List<Map<String, dynamic>> _getDefaultFields(String? serviceType, String? biogasType) {
    if (serviceType == 'biogas' || serviceType == 'solar') {
      // Homestead / Institutional quotation forms for Solar & Biogas
      final List<Map<String, dynamic>> baseFields = [];

      if (biogasType == 'homestead') {
        baseFields.addAll([
          {
            'label': 'Full Name',
            'key': 'fullName',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter your full name',
          },
          {
            'label': 'Address',
            'key': 'address',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter your address',
          },
          {
            'label': 'District',
            'key': 'district',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter district',
          },
          {
            'label': 'Ward',
            'key': 'ward',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter ward',
          },
          {
            'label': 'Phone Number',
            'key': 'phoneNumber',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter your phone number',
          },
        ]);
      } else if (biogasType == 'institutional') {
        baseFields.addAll([
          {
            'label': 'Institution Name',
            'key': 'institutionName',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter institution name',
          },
          {
            'label': 'Address',
            'key': 'address',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter address',
          },
          {
            'label': 'District',
            'key': 'district',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter district',
          },
          {
            'label': 'Ward',
            'key': 'ward',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter ward',
          },
          {
            'label': 'Institution Phone Number',
            'key': 'institutionPhoneNumber',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter institution phone number',
          },
        ]);
      } else {
        // Fallback if connection type is missing
        baseFields.addAll([
          {
            'label': 'Full Name',
            'key': 'fullName',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter your full name',
          },
          {
            'label': 'Address',
            'key': 'address',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter your address',
          },
          {
            'label': 'District',
            'key': 'district',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter district',
          },
          {
            'label': 'Ward',
            'key': 'ward',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter ward',
          },
          {
            'label': 'Phone Number',
            'key': 'phoneNumber',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter phone number',
          },
        ]);
      }

      baseFields.addAll([
        {
          'label': 'Additional Information',
          'key': 'additionalInfo',
          'type': 'textarea',
          'required': false,
          'placeholder': 'Any additional information about your energy needs...',
        },
      ]);

      return baseFields;
    } else if (serviceType == 'biogas') {
      return [
        {
          'label': 'Full Name',
          'key': 'fullName',
          'type': 'text',
          'required': true,
          'placeholder': 'Enter your full name',
        },
        {
          'label': 'Address',
          'key': 'address',
          'type': 'text',
          'required': true,
          'placeholder': 'Enter your address',
        },
        {
          'label': 'Location',
          'key': 'location',
          'type': 'text',
          'required': true,
          'placeholder': 'Enter your location',
        },
        if (biogasType == 'homestead') ...[
          {
            'label': 'Number of Household Members',
            'key': 'householdMembers',
            'type': 'number',
            'required': true,
            'placeholder': 'Enter number of members',
          },
          {
            'label': 'Livestock Count',
            'key': 'livestockCount',
            'type': 'number',
            'required': false,
            'placeholder': 'Enter livestock count',
          },
        ] else if (biogasType == 'institutional') ...[
          {
            'label': 'Institution Name',
            'key': 'institutionName',
            'type': 'text',
            'required': true,
            'placeholder': 'Enter institution name',
          },
          {
            'label': 'Number of Users',
            'key': 'numberOfUsers',
            'type': 'number',
            'required': true,
            'placeholder': 'Enter number of users',
          },
        ],
        {
          'label': 'Additional Information',
          'key': 'additionalInfo',
          'type': 'textarea',
          'required': false,
          'placeholder': 'Any additional information...',
        },
      ];
    } else {
      // Grid/Solar default fields - return sections structure for grid_solar
      return [
        {
          'title': 'APPLICANT AND PREMISES DETAILS',
          'fields': [
            {
              'label': 'Full Name',
              'key': 'fullName',
              'type': 'text',
              'required': true,
              'placeholder': 'Enter your full name in block letters',
              'multiline': true,
            },
            {
              'label': 'Province',
              'key': 'province',
              'type': 'text',
              'required': true,
              'placeholder': 'Enter province',
            },
            {
              'label': 'District',
              'key': 'district',
              'type': 'text',
              'required': true,
              'placeholder': 'Enter district',
            },
            {
              'label': 'Project Name',
              'key': 'projectName',
              'type': 'text',
              'required': true,
              'placeholder': 'Enter project name',
              'multiline': true,
            },
          ],
        },
        {
          'title': 'ELECTRICAL CONSUMING DEVICES',
          'fields': [
            {
              'label': 'Lighting Points No.',
              'key': 'lightingPoints',
              'type': 'number',
              'required': true,
              'placeholder': 'Enter number of lighting points',
            },
            {
              'label': 'Plug Points No.',
              'key': 'plugPoints',
              'type': 'number',
              'required': true,
              'placeholder': 'Enter number of plug points',
            },
            {
              'label': 'Stove Rating (Watts)',
              'key': 'stoveRating',
              'type': 'number',
              'required': false,
              'placeholder': 'Enter stove rating in watts',
            },
            {
              'label': 'No. of Phases',
              'key': 'numberOfPhases',
              'type': 'number',
              'required': true,
              'placeholder': 'Enter number of phases',
            },
            {
              'label': 'Voltage',
              'key': 'voltage',
              'type': 'number',
              'required': true,
              'placeholder': 'Enter voltage',
            },
          ],
        },
        {
          'title': 'OTHER ELECTRICAL APPLIANCES',
          'fields': [
            {
              'label': 'Other Electrical Appliances',
              'key': 'otherAppliances',
              'type': 'textarea',
              'required': false,
              'placeholder': 'List any other electrical appliances',
              'multiline': true,
            },
          ],
        },
        {
          'title': 'SIGNATURE AND ADDRESS',
          'fields': [
            {
              'label': 'Date',
              'key': 'applicationDate',
              'type': 'date',
              'required': true,
            },
            {
              'label': 'Signature',
              'key': 'signature',
              'type': 'text',
              'required': true,
              'placeholder': 'Your signature',
            },
            {
              'label': 'Postal Address',
              'key': 'postalAddress',
              'type': 'textarea',
              'required': true,
              'placeholder': 'Enter your complete postal address',
              'multiline': true,
            },
          ],
        },
      ];
    }
  }

  /// Save form configuration to Firestore (Admin only)
  Future<void> saveFormConfig({
    required String serviceType,
    required List<Map<String, dynamic>> fields,
  }) async {
    await _firestore.collection('form_configs').doc(serviceType).set({
      'serviceType': serviceType,
      'fields': fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

