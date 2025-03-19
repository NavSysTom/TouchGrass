import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:touch_grass/posts/post_states.dart';
import 'package:touch_grass/services/app_user.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  String selectedCategory = 'all';

  final textController = TextEditingController();

  AppUser? currentUser;

@override
void initState() {
  super.initState();
  getCurrentUser();

  // Check if the user has posted recently
  hasPostedRecently().then((postedRecently) {
    if (!postedRecently) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Don’t forget to post to keep your streak alive!')),
      );
    }
  });
}

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage({bool fromCamera = false}) async {
    if (fromCamera) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          imagePickedFile = PlatformFile(
            path: pickedFile.path,
            name: pickedFile.name,
            size: File(pickedFile.path).lengthSync(),
          );
        });
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
      );

      if (result != null) {
        setState(() {
          imagePickedFile = result.files.first;
          if (kIsWeb) {
            webImage = imagePickedFile!.bytes;
          }
        });
      }
    }
  }
  Future<bool> hasPostedRecently() async {
  try {
    final userId = currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final lastPostTimestamp = userDoc.data()?['lastPostTime'] as Timestamp?;
      if (lastPostTimestamp != null) {
        final lastPostTime = lastPostTimestamp.toDate();
        final now = DateTime.now();

        // Check if the last post was within the last 4 hours
        final difference = now.difference(lastPostTime);
        return difference.inHours < 4;
      }
    }
  } catch (e) {
    print('Error checking last post time: $e');
  }
  return false;
}

void uploadPost() async {
  if (imagePickedFile == null || textController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an image and write a caption')));
    return;
  }

  final newPost = Post(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: currentUser!.uid,
    username: currentUser!.name,
    text: textController.text,
    imageUrl: '',
    timestamp: DateTime.now(),
    comments: [],
    category: selectedCategory,
  );

  final PostCubit postCubit = context.read<PostCubit>();

  if (kIsWeb) {
    postCubit.createPost(newPost, imageWebBytes: imagePickedFile?.bytes);
  } else {
    postCubit.createPost(newPost, imageMobilePath: imagePickedFile?.path);
  }

  // Update lastPostTime in Firebase
  try {
    final userId = currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    await userDoc.set({
      'lastPostTime': FieldValue.serverTimestamp(), // Update last post time
    }, SetOptions(merge: true));

    if (!mounted) return; // Ensure context is still valid
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post uploaded successfully!')),
    );

    // Clear the text field and image
    setState(() {
      textController.clear();
      imagePickedFile = null;
      webImage = null;
    });
  } catch (e) {
    if (!mounted) return; // Ensure context is still valid
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update last post time: $e')),
    );
  }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostsUploading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Uploading..."),
                ],
              ),
            ),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload successful!')),
          );
        } else if (state is PostsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
    );
  }

Widget buildUploadPage() {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Upload Post'),
      backgroundColor: const Color(0xFFbfd37a),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Write a caption...'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => pickImage(fromCamera: false),
                child: const Text('Pick Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: () => pickImage(fromCamera: true),
                child: const Text('Take Photo'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (imagePickedFile != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, // Background color for the container
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.memory(
                        webImage!,
                        fit: BoxFit.contain, // Ensures the full image is visible
                      )
                    : Image.file(
                        File(imagePickedFile!.path!),
                        fit: BoxFit.contain, // Ensures the full image is visible
                      ),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => selectedCategory = 'flowers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == 'flowers'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Flowers',
                    style: TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => selectedCategory = 'bugs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == 'bugs'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Bugs',
                    style: TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => selectedCategory = 'animals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == 'animals'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Animals',
                    style: TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => selectedCategory = 'wildscape'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCategory == 'wildscape'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: const Text(
                    'Wildscape',
                    style: TextStyle(fontSize: 8),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: uploadPost,
            child: const Text('Upload Post'),
          ),
        ],
      ),
    ),
  );
 }
}