import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadImage(XFile image, String caption) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String filePath = 'images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _storage.ref(filePath).putFile(File(image.path));
      String downloadUrl = await _storage.ref(filePath).getDownloadURL();

      // Fetch user ID from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String userId = userDoc['userId'];

      await _firestore.collection('images').add({
        'url': downloadUrl,
        'caption': caption,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserImages(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('images')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}