import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/components/textfield.dart';
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

  final textController = TextEditingController();

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurerntUser();
  }

  void getCurerntUser() async {
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
    imageUrl: '', // This will be updated after the image is uploaded
    timestamp: DateTime.now(),
    comments: [],
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
        title: const Text('Create Post'),
        centerTitle: true,
        backgroundColor: const Color(0xFFbfd37a),
        actions: [
          IconButton(
            onPressed: uploadPost,
            icon: const Icon(Icons.upload),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            if (kIsWeb && webImage != null)
              SizedBox(
                height: 300,
                width: 300,
                child: Image.memory(webImage!, fit: BoxFit.cover),
              ),
            if (!kIsWeb && imagePickedFile != null)
              SizedBox(
                height: 300,
                width: 300,
                child: Image.file(
                  File(imagePickedFile!.path!),
                  fit: BoxFit.cover,
                ),
              ),
            MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text('Pick Image'),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: MyTextfield(
                controller: textController,
                hintText: "Caption",
                obscureText: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
