import 'dart:typed_data';

abstract class StorageRepo {
  Future<String> uploadProfileImage(String path, String fileName);
  Future<String> uploadProfileImageWeb(Uint8List file, String fileName);
  Future<String> uploadPostImage(String path, String fileName);
  Future<String> uploadPostImageWeb(Uint8List file, String fileName);
}