import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/application_model.dart';
import '../../services/form_config_service.dart';
import '../../widgets/motor_table_widget.dart';
import 'package:intl/intl.dart';

class ApplicationFormScreen extends StatefulWidget {
  final String? serviceType;
  final String? biogasType;

  const ApplicationFormScreen({
    super.key,
    this.serviceType,
    this.biogasType,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final List<Map<String, dynamic>> _formFields = [];
  final List<Map<String, dynamic>> _formSections = [];
  final FormConfigService _formConfigService = FormConfigService();
  bool _isLoadingFields = true;
  bool _isLoading = false;
  bool _hasSections = false;
  List<Map<String, dynamic>> _motors = [];

  @override
  void initState() {
    super.initState();
    _loadFormFields();
  }

  Future<void> _loadFormFields() async {
    setState(() => _isLoadingFields = true);
    
    try {
      final result = await _formConfigService.loadFormFields(
        serviceType: widget.serviceType,
        biogasType: widget.biogasType,
      );
      
      setState(() {
        _hasSections = result['hasSections'] == true;
        
        if (_hasSections) {
          _formSections.clear();
          _formSections.addAll((result['sections'] as List).cast<Map<String, dynamic>>());
          
          // Initialize controllers from sections
          for (var section in _formSections) {
            final fields = section['fields'] as List<dynamic>? ?? [];
            for (var field in fields) {
              final key = field['key'] as String?;
              if (key != null && !_controllers.containsKey(key)) {
                _controllers[key] = TextEditingController();
              }
            }
          }
        } else {
          _formFields.clear();
          _formFields.addAll((result['fields'] as List).cast<Map<String, dynamic>>());
          
          // Initialize controllers
          for (var field in _formFields) {
            final key = field['key'] as String?;
            if (key != null) {
              _controllers[key] = TextEditingController();
            }
          }
        }
      });
    } catch (e) {
      // Fallback to default fields
      _formFields.addAll([
        {'label': 'Full Name', 'key': 'fullName', 'type': 'text', 'required': true},
        {'label': 'Address', 'key': 'address', 'type': 'text', 'required': true},
        {'label': 'Location', 'key': 'location', 'type': 'text', 'required': true},
        {'label': 'Additional Information', 'key': 'additionalInfo', 'type': 'textarea', 'required': false},
      ]);
      
      for (var field in _formFields) {
        _controllers[field['key']] = TextEditingController();
      }
    } finally {
      setState(() => _isLoadingFields = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final formData = <String, dynamic>{};
    for (var entry in _controllers.entries) {
      formData[entry.key] = entry.value.text;
    }
    
    // Add motors data if available
    if (_motors.isNotEmpty) {
      formData['motors'] = _motors;
    }

    final application = ApplicationModel(
      id: const Uuid().v4(),
      userId: authProvider.currentUser!.id,
      officeId: authProvider.currentUser!.officeId ?? '',
      serviceType: widget.serviceType ?? '',
      biogasType: widget.biogasType ?? '',
      formData: formData,
      status: 'pending',
      submittedAt: DateTime.now(),
    );

    try {
      setState(() => _isLoading = true);
      
      final success = await appProvider.submitApplication(application);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Application submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit application. Please check your connection and try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title;
    if (widget.serviceType == 'grid' || widget.serviceType == 'grid_solar') {
      title = 'Application for Electrification Form';
    } else if (widget.serviceType == 'solar' || widget.serviceType == 'biogas') {
      final connection =
          widget.biogasType == 'institutional' ? 'Institutional' : 'Homestead';
      title = '$connection Quotation Request - ${widget.serviceType?.toUpperCase() ?? ''}';
    } else {
      title = 'Application Form - ${widget.serviceType?.toUpperCase() ?? ''}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            if (widget.serviceType == 'grid' ||
                widget.serviceType == 'grid_solar')
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RURAL ELECTRIFICATION AGENCY',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'As I am desirous of electrifying the under-mentioned premises. I shall be glad if you will furnish me with a quotation. (The following information should be completed in block letters)',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 24.sp,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Please fill in all required fields',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 24.h),
            if (_isLoadingFields)
              const Center(child: CircularProgressIndicator())
            else if (_hasSections)
              ..._formSections.map((section) {
                return _buildSection(section);
              })
            else
              ..._formFields.map((field) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildFormField(field),
                );
              }),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: (_isLoading || _isLoadingFields) ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Submit Application',
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    final fieldType = field['type'] ?? 'text';
    final key = field['key'] as String;
    final label = field['label'] as String;
    final required = field['required'] == true;
    final placeholder = field['placeholder'] as String?;

    switch (fieldType) {
      case 'textarea':
        final multiline = field['multiline'] == true;
        return TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            hintText: placeholder,
            alignLabelWithHint: true,
            suffixText: required ? '*' : null,
            suffixStyle: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
            ),
          ),
          style: TextStyle(fontSize: 16.sp),
          maxLines: multiline ? 5 : 4,
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );

      case 'number':
        return TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            hintText: placeholder,
            suffixText: required ? '*' : null,
            suffixStyle: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
            ),
          ),
          style: TextStyle(fontSize: 16.sp),
          keyboardType: TextInputType.number,
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }
              : null,
        );

      case 'date':
        return TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            suffixIcon: const Icon(Icons.calendar_today),
            suffixText: required ? '*' : null,
            suffixStyle: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
            ),
          ),
          style: TextStyle(fontSize: 16.sp),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              _controllers[key]?.text = DateFormat('yyyy-MM-dd').format(date);
            }
          },
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );

      case 'dropdown':
        String? selectedValue;
        final options = field['options'] as List<dynamic>? ?? [];
        return StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                filled: true,
                suffixText: required ? '*' : null,
                suffixStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 14.sp,
                ),
              ),
              value: selectedValue,
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.toString(),
                  child: Text(option.toString(), style: TextStyle(fontSize: 16.sp)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                  _controllers[key]?.text = value ?? '';
                });
              },
              validator: required
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    }
                  : null,
            );
          },
        );

      default: // text
        final multiline = field['multiline'] == true;
        return TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            hintText: placeholder,
            suffixText: required ? '*' : null,
            suffixStyle: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
            ),
          ),
          style: TextStyle(fontSize: 16.sp),
          maxLines: multiline ? 3 : 1,
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );
    }
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final title = section['title'] as String? ?? '';
    final sectionType = section['type'] as String?;
    final fields = section['fields'] as List<dynamic>? ?? [];

    // Handle motor table section
    if (sectionType == 'motor_table') {
      return Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: MotorTableWidget(
          onMotorsChanged: (motors) {
            setState(() {
              _motors = motors;
            });
          },
          initialMotors: _motors.isEmpty ? null : _motors,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          ...fields.map((field) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildFormField(field as Map<String, dynamic>),
            );
          }),
        ],
      ),
    );
  }
}

