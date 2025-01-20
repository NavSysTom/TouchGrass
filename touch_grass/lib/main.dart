import 'package:firebase_core/firebase_core.dart';
import 'package:touch_grass/app.dart';
import 'package:flutter/material.dart';



void main() async { 

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}
