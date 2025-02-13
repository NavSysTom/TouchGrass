import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/components/user_tile.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({super.key, required this.followers, required this.following});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Followers & Following',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const TabBar(
              tabs: [
                Tab(text: 'Followers'),
                Tab(text: 'Following'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(followers, 'No followers found', context),
                  _buildUserList(following, 'No following found', context),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pop(context),
          backgroundColor: const Color(0xFFbfd37a),
          child: const Icon(Icons.arrow_back),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }

  Widget _buildUserList(List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              final uid = uids[index];
              return FutureBuilder<ProfileUser?>(
                future: context.read<ProfileCubit>().getuserProfile(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading"));
                  } else if (snapshot.hasData) {
                    final user = snapshot.data!;
                    print('User found: ${user.name}');
                    return UserTile(user: user);
                  } else {
                    print('User not found for UID: $uid');
                    return const ListTile(title: Text("User not found"));
                  }
                },
              );
            },
          );
  }
}