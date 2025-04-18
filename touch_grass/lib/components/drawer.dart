import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/home/pages/home_page.dart';
import 'package:touch_grass/authenticate/home/pages/journey_page.dart';
import 'package:touch_grass/authenticate/home/pages/profile_page.dart';
import 'package:touch_grass/authenticate/home/pages/search_page.dart';
import 'package:touch_grass/components/drawer_tile.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/screens/register_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final profileCubit = context.read<ProfileCubit>();
    final currentUser = authCubit.currentUser;

    // Handle case where currentUser is null
    if (currentUser == null) {
      // Redirect to RegisterPage if user is not logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Register(togglePages: () {})),
        );
      });
      return const SizedBox(); 
    }

    return Drawer(
      backgroundColor: const Color(0xFFbfd37a),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              _buildProfileHeader(context, profileCubit, currentUser.uid),
              const SizedBox(height: 10),
              _buildDrawerTile(
                context,
                title: 'Home',
                icon: Icons.home,
                onTap: () {
                  Navigator.of(context).pop();
                  if (ModalRoute.of(context)?.settings.name != '/') {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  }
                },
              ),
              _buildDrawerTile(
                context,
                title: 'Profile',
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: currentUser.uid),
                    ),
                  );
                },
              ),
              _buildDrawerTile(
                context,
                title: 'Search',
                icon: Icons.search,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                ),
              ),
              _buildDrawerTile(
                context,
                title: 'Journey',
                icon: Icons.map,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JourneyPage()),
                ),
              ),
              const Spacer(),
              _buildDrawerTile(
                context,
                title: 'Logout',
                icon: Icons.logout,
                onTap: () {
                  // Sign out the user
                  context.read<AuthCubit>().signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileCubit profileCubit, String uid) {
    return FutureBuilder<ProfileUser?>(
      future: profileCubit.getuserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          final profileImageUrl = user.profileImageUrl;
          return Column(
            children: [
              ClipOval(
                child: profileImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profileImageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.emoji_emotions,
                        size: 50.0,
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                user.name,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          );
        } else {
          return const Icon(
            Icons.person,
            size: 100.0,
          );
        }
      },
    );
  }

  Widget _buildDrawerTile(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return MyDrawerTile(
      title: title,
      icon: icon,
      onTap: onTap,
    );
  }
}