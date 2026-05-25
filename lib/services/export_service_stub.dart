import 'package:share_plus/share_plus.dart';
import '../models/application_model.dart';

class ExportService {
  Future<String> exportApplicationToText(ApplicationModel application) async {
    final buffer = StringBuffer();
    buffer.writeln('APPLICATION DETAILS');
    buffer.writeln('=' * 50);
    buffer.writeln();
    buffer.writeln('Application ID: ${application.id}');
    buffer.writeln(
        'Service Type: ${application.serviceType.toUpperCase().replaceAll('_', ' ')}');
    if (application.biogasType.isNotEmpty) {
      buffer.writeln('Biogas Type: ${application.biogasType.toUpperCase()}');
    }
    buffer.writeln('Status: ${application.status.toUpperCase()}');
    buffer.writeln('Submitted: ${_formatDate(application.submittedAt)}');
    if (application.updatedAt != null) {
      buffer.writeln('Last Updated: ${_formatDate(application.updatedAt!)}');
    }
    buffer.writeln();
    buffer.writeln('APPLICATION DATA');
    buffer.writeln('=' * 50);
    buffer.writeln();
    application.formData.forEach((key, value) {
      buffer.writeln(
          '${key.toString().replaceAll('_', ' ').toUpperCase()}: $value');
    });
    return buffer.toString();
  }

  Future<void> shareApplication(ApplicationModel application) async {
    final text = await exportApplicationToText(application);
    await Share.share(text, subject: 'Application Details - ${application.id}');
  }

  Future<void> saveApplicationToFile(ApplicationModel application) async {
    await shareApplication(application);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
