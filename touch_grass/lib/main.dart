import 'package:firebase_core/firebase_core.dart';
import 'package:touch_grass/app.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/notifications/firebase_api.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize notifications
    final firebaseApi = FirebaseApi();
    await firebaseApi.initNotifications();
  } catch (e) {
    print('Failed to initialize Firebase or notifications: $e');
  }

  runApp(MyApp());
}