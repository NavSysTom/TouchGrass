import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:touch_grass/models/myUser.dart';
import 'package:touch_grass/services/auth.dart';
import 'package:touch_grass/authenicate/authenticate.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:touch_grass/screens/profilePage.dart';

class HomeUI extends StatefulWidget {
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  final AuthService _auth = AuthService();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _caption;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      _caption = null;
      _captionController.clear();
    });
  }

  Future<void> _openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      _caption = null;
      _captionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'TouchGrass',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.grey,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Authenticate()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _image == null
                  ? const Text(
                      'Welcome, you are now logged in!',
                      style: TextStyle(fontSize: 24.0),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.file(
                              File(_image!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (_caption != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '$_caption\nPosted by: ${user?.uid ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 16.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          if (_image != null && _caption == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _caption = _captionController.text;
                      });
                    },
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _openCamera,
                ),
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: _openGallery,
                ),
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}