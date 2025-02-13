import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
      });
    }
    if (kIsWeb) {
      webImage = imagePickedFile!.bytes;
    }
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedCategory = 'flowers'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'flowers'
                          ? Colors.green
                          : Colors.grey,
                    ),
                    child: const Text('Flowers'),
                  ),
                ),
                const SizedBox(width: 8), 
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => selectedCategory = 'bugs'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'bugs' ? Colors.green : Colors.grey,
                    ),
                    child: const Text('Bugs'),
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
                    child: const Text('Animals'),
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
                    child: const Text('Wildscape'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            if (imagePickedFile != null)
              kIsWeb
                  ? Image.memory(webImage!, height: 200)
                  : Image.file(File(imagePickedFile!.path!), height: 200),
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