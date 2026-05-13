import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../models/report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportController = TextEditingController();

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final user = authProvider.currentUser!;

    final report = ReportModel(
      id: const Uuid().v4(),
      userId: user.id,
      officeId: user.officeId ?? '',
      staffName: user.fullNameWithSurname,
      station: user.station ?? '',
      content: _reportController.text,
      submittedAt: DateTime.now(),
    );

    final success = await appProvider.submitReport(report);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: 24.sp,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Write your field report',
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
            TextFormField(
              controller: _reportController,
              decoration: InputDecoration(
                labelText: 'Report Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                filled: true,
                hintText: 'Enter your report details...',
                alignLabelWithHint: true,
              ),
              style: TextStyle(fontSize: 16.sp),
              maxLines: 12,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter report content';
                }
                return null;
              },
            ),
            SizedBox(height: 32.h),
            Consumer<AppProvider>(
              builder: (context, appProvider, _) {
                return ElevatedButton(
                  onPressed: appProvider.isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: appProvider.isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Submit Report',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

