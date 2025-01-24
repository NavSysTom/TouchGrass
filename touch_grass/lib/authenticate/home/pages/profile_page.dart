import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/home/pages/edit_profile_page.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/authenticate/profile_state.dart';
import 'package:touch_grass/components/bio_box.dart';
import 'package:touch_grass/services/app_user.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthCubit authCubit;
  late final ProfileCubit profileCubit;
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    profileCubit = context.read<ProfileCubit>();
    currentUser = authCubit.currentUser;

    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoaded) {
        final user = state.profileUser;

        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
            centerTitle: true,
            backgroundColor: const Color(0xFFbfd37a),

            actions: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(user: user,))), 
              icon: const Icon(Icons.settings)),
            ]
          ),
          
          body: 
          Column(
            children: [
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),

              const SizedBox(height: 15.0),

                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                     decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                   ),
                  ),
                ),
            ),

              const SizedBox(height: 15.0),

              const Text("Bio"),
              const SizedBox(height: 30),
              BioBox(text: user.bio),

              //posts
              const Padding(padding:
                 EdgeInsets.all(20.0),
                child: Column(
                  children: [
                     Text('Posts', style: TextStyle(fontSize: 20.0)),
                     SizedBox(height: 20),
                     Text('No posts yet..', style: TextStyle(fontSize: 16.0)),
                  ],
                ), 
              )
            ],

            
          ),
        );
      } else if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else {
        return const Scaffold(
          body: Center(
            child: Text('Error loading profile, No profile found'),
          ),
        );
      }
    });
  }
}