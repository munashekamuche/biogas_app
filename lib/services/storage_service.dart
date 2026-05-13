import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Upload file to Firebase Storage
  Future<String> uploadFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      final String name = fileName ?? path.basename(file.path);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String finalName = '$timestamp-$name';
      
      final Reference ref = _storage.ref().child('$folder/$finalName');
      final UploadTask uploadTask = ref.putFile(file);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload application image
  Future<String> uploadApplicationImage(File image, String applicationId) async {
    return await uploadFile(
      file: image,
      folder: 'applications/$applicationId',
      fileName: 'image.jpg',
    );
  }

  // Upload document
  Future<String> uploadDocument(File document, String applicationId, String docType) async {
    return await uploadFile(
      file: document,
      folder: 'applications/$applicationId/documents',
      fileName: '$docType.pdf',
    );
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}

