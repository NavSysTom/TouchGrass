import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:touch_grass/storage/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  Future<String> uploadProfileImage(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  @override
  Future<String> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileWeb(fileBytes, fileName, "profile_images");
  }


  @override
  Future<String> uploadPostImage(String path, String fileName) {
    return _uploadFile(path, fileName, "post_images");
  }

  @override
  Future<String> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileWeb(fileBytes, fileName, "post_images");
  }


  Future<String> _uploadFile(String path, String fileName, String folder) async {
    try {
      final file = File(path);
      final storageRef = _firebaseStorage.ref().child('$folder/$fileName');
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('File upload failed');
    }
  }

  Future<String> _uploadFileWeb(Uint8List fileBytes, String fileName, String folder) async {
    try {
      final storageRef = _firebaseStorage.ref().child('$folder/$fileName');
      final uploadTask = await storageRef.putData(fileBytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('File upload failed');
    }
  }
}