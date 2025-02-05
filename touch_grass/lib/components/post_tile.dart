import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/home/pages/profile_page.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/comments/comment.dart';
import 'package:touch_grass/components/comment_tile.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/components/textfield.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:touch_grass/posts/post_states.dart';
import 'package:touch_grass/services/app_user.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  AppUser? currentUser;

  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getuserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
      print('fetchPostUser: postUser = $postUser'); // Debug print statement
      print(
          'fetchPostUser: profileImageUrl = ${postUser?.profileImageUrl}'); // Debug print statement
    } else {
      print('fetchPostUser: fetchedUser is null'); // Debug print statement
    }
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Post?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                    onPressed: () {
                      widget.onDeletePressed!();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  //comments
  final commentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add a new comment"),
              content: MyTextfield(
                  controller: commentTextController,
                  hintText: "",
                  obscureText: false),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save")),
              ],
            ));
  }

  void addComment() {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid, // Use currentUser's ID
      username: currentUser!.name, // Use currentUser's name
      text: commentTextController.text, // Use the text from the TextField
      timestamp: DateTime.now(),
    );

    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F5E9), // Very light shade of green
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProfilePage(uid: widget.post.userId))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            print(
                                'Error loading image: $url'); // Debug print statement
                            return const Icon(Icons.person);
                          },
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                 
                  const SizedBox(
                    width: 10,
                  ),
                  Text(widget.post.username),
                   const Spacer(),
                  if (isOwnPost)
                    GestureDetector(
                        onTap: showOptions, child: const Icon(Icons.more_horiz))
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Row(
            children: [
              GestureDetector(
                  onTap: openNewCommentBox, child: const Icon(Icons.comment)),
              Text(widget.post.comments.length.toString()),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
            child: Row(
              children: [
                Text(
                  widget.post.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(":"),
                const SizedBox(width: 5),
                Text(widget.post.text),
              ],
            ),
          ),
          BlocBuilder<PostCubit, PostState>(builder: (context, state) {
            if (state is PostsLoaded) {
              final post =
                  state.posts.firstWhere((post) => (post.id == widget.post.id));

              if (post.comments.isNotEmpty) {
                int showCommentCount = post.comments.length;

                return ListView.builder(
                  itemCount: showCommentCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final comment = post.comments[index];

                    return CommentTile(comment: comment);
                  },
                );
              }
            }

            if (state is PostsLoading) {
              return const CircularProgressIndicator();
            } else if (state is PostsError) {
              return Center(
                child: Text(state.message),
              );
            } else {
                return const Center(
                child: Text(
                  "No Comments Available",
                  style: TextStyle(color: Colors.grey),
                ),
                );
              }
          }),
        ],
      ),
    );
  }
}