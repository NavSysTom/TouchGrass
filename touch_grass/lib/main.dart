import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'screens/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'TouchGRASS',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'HelveticaNeueRoman',
            ),
          ),
        ),
        backgroundColor: Color(0xFFbfd37a),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            selectedImage != null
                ? Image.file(selectedImage!)
                : Text("Please select an image"),
            ElevatedButton.icon(
              onPressed: () {
                pickImageFromCamera();
              },
              icon: Icon(Icons.camera),
              label: Text('Pick Image from Camera'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                pickImageFromGallery();
              },
              icon: Icon(Icons.photo),
              label: Text('Pick Image from Gallery'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (context) => Signup()),
                );
              },
              icon: Icon(Icons.arrow_forward),
              label: Text('Go to Signup Page'),
            ),
          ],
        ),
      ),
    );
  }

  Future pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      setState(() {
        selectedImage = File(returnedImage.path);
      });
    }
  }

  Future pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage != null) {
      setState(() {
        selectedImage = File(returnedImage.path);
      });
    }
  }
}


