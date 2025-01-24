import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/home/pages/profile_page.dart';
import 'package:touch_grass/components/drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFbfd37a),
      child: SafeArea (
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              
              Icon(
                Icons.person,
                size: 100.0,
              ),
          
              //home tile
              MyDrawerTile(
                title: 'Home',
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),
          
              //profile tile
              MyDrawerTile(
                title: 'Profile',
                icon: Icons.person,
                onTap: () {
                Navigator.of(context).pop();

                final user = context.read<AuthCubit>().currentUser;
                String? uid = user!.uid;

                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: uid)
                    ),
                  );
                }
              ),
          
              //settings tile
              MyDrawerTile(
                title: 'Settings',
                icon: Icons.settings,
                onTap: () {
                  
                },
              ),

              const Spacer(),
              //logout tiler
              MyDrawerTile(
                title: 'Logout',
                icon: Icons.logout,
                onTap: () => context.read<AuthCubit>().signOut(),
              ),
            ]
          ),
        ),
      )
    );
  }
}