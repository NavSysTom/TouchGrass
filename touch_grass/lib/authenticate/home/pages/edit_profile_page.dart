import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/authenticate/profile_state.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/components/textfield.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  PlatformFile? imagePickedFile;
  Uint8List? webImage;

  final bioTextController = TextEditingController();

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
  
void updateProfile() async {
  final profileCubit = context.read<ProfileCubit>();
  final String uid = widget.user.uid;
  final String? imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
  final Uint8List? imageWebBytes = kIsWeb ? webImage : null;
  final String? newBio = bioTextController.text.isNotEmpty ? bioTextController.text : null;

  if (imagePickedFile != null || newBio != null) {
    profileCubit.updatedProfile(
      uid: uid,
      newBio: newBio,
      imageMobilePath: imageMobilePath,
      imageWebBytes: imageWebBytes,
    );
  } else {
    Navigator.pop(context);
  }
}

    @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
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
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: updateProfile,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child: (!kIsWeb && imagePickedFile != null)
                    ? Image.file(
                        File(imagePickedFile!.path!),
                        fit: BoxFit.cover,
                      )
                    : (kIsWeb && webImage != null)
                        ? Image.memory(
                            webImage!,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.user.profileImageUrl,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Image(image: imageProvider),
                          ),
              ),
            ),
            const SizedBox(height: 25.0),
            Center(
              child: MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: const Text('Pick Image'),
              ),
            ),
            const SizedBox(height: 25.0),
            const Text("Bio"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              child: MyTextfield(
                controller: bioTextController,
                hintText: 'Enter your bio',
                obscureText: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}