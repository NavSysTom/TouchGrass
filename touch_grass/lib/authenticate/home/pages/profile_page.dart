import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/home/pages/edit_profile_page.dart';
import 'package:touch_grass/authenticate/home/pages/follower_page.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/authenticate/profile_state.dart';
import 'package:touch_grass/components/bio_box.dart';
import 'package:touch_grass/components/drawer.dart';
import 'package:touch_grass/components/follow_button.dart';
import 'package:touch_grass/components/profile_stats.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:touch_grass/posts/post_states.dart';
import 'package:touch_grass/services/app_user.dart';
import 'package:touch_grass/authenticate/home/pages/post_detail_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthCubit authCubit;
  late final ProfileCubit profileCubit;
  late final PostCubit postCubit;
  AppUser? currentUser;
  int streakCount = 0;

  @override
  void initState() {
    super.initState();
    authCubit = context.read<AuthCubit>();
    profileCubit = context.read<ProfileCubit>();
    postCubit = context.read<PostCubit>();
    currentUser = authCubit.currentUser;
    profileCubit.fetchUserProfile(widget.uid);
    postCubit.fetchAllPosts();
    fetchStreakCount();
  }

  Future<void> fetchStreakCount() async {
    streakCount = await profileCubit.fetchStreakCount(widget.uid);
    setState(() {});
  }

  Future<void> _refreshPage() async {
    profileCubit.fetchUserProfile(widget.uid);
    postCubit.fetchAllPosts();
    fetchStreakCount();
  }

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      if (isFollowing) {
        profileUser.followers.add(currentUser!.uid);
      } else {
        profileUser.followers.remove(currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfileLoaded) {
        final user = state.profileUser;

        return Scaffold(
          appBar: AppBar(
              title: Text(user.name),
              centerTitle: true,
              backgroundColor: const Color(0xFFbfd37a),
              actions: [
                if (isOwnPost)
                  IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                    user: user,
                                  ))),
                      icon: const Icon(Icons.settings)),
              ]),
          drawer: const MyDrawer(), // Add the drawer here
          body: RefreshIndicator(
            onRefresh: _refreshPage,
            child: ListView(
              children: [
                const SizedBox(height: 15.0),
                Column(
                  children: [
                    ClipOval(
                      child: user.profileImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.profileImageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) {
                                return const Icon(Icons.person);
                              },
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.whatshot, color: Colors.orange),
                        const SizedBox(width: 5),
                        Text(
                          'Streak: $streakCount days',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10.0), // Reduced space
                ProfileStats(
                  postCount: postCubit.state is PostsLoaded
                      ? (postCubit.state as PostsLoaded)
                          .posts
                          .where((post) => post.userId == widget.uid)
                          .length
                      : 0,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowerPage(
                              followers: user.followers,
                              following: user.following))),
                ),
                const SizedBox(height: 10.0), // Reduced space
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),
                BioBox(text: user.bio),
                Padding(
                  padding: const EdgeInsets.all(10.0), // Reduced padding
                  child: Column(
                    children: [
                      const Text('Posts', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10), // Reduced space
                      BlocBuilder<PostCubit, PostState>(
                        builder: (context, state) {
                          if (state is PostsLoaded) {
                            final userPosts = state.posts
                                .where((post) => post.userId == widget.uid)
                                .toList();

                            return GridView.builder(
                              itemCount: userPosts.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemBuilder: (context, index) {
                                final post = userPosts[index];

                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PostDetailPage(post: post),
                                    ),
                                  ),
                                  child: post.imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: post.imageUrl,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const Icon(Icons.image_not_supported),
                                );
                              },
                            );
                          } else if (state is PostsLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            return const Center(child: Text("No posts"));
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
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