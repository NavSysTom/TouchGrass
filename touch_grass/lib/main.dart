import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/screens/homeUI.dart';
import 'screens/signup.dart';
import 'package:touch_grass/services/auth.dart';
import 'package:touch_grass/models/myUser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<myUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);

   
    if (user == null) {
      return HomePage();
    } else {
      return HomeUI();
    }
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
        centerTitle: true,
        backgroundColor: Color(0xFFbfd37a),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Signup()),
              );
            },
            child: Text(
              'Log In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
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