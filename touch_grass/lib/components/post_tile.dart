import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/comments/comment.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/components/textfield.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:touch_grass/services/app_user.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({super.key, required this.post, required this.onDeletePressed});

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
    }
  }
  void deleteComment(Comment comment) {
  setState(() {
    widget.post.comments.remove(comment);
  });
  postCubit.deleteComment(widget.post.id, comment.id); 
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

  // Comments
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
      userId: currentUser!.uid,
      username: currentUser!.name,
      text: commentTextController.text,
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
    color: const Color(0xFFE8F5E9), 
    child: Column(
      children: [
        Container(
          color: const Color(0xFFbfd37a), 
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              postUser?.profileImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: postUser!.profileImageUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
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
              const SizedBox(width: 10),
              Text(
                widget.post.username,
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isOwnPost)
                GestureDetector(
                    onTap: showOptions,
                    child: const Icon(Icons.more_horiz, color: Colors.white)),
            ],
          ),
        ),

        Container(
          color: Colors.white, 
          child: CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.contain, 
            placeholder: (context, url) => const SizedBox(height: 430),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),

      
      Container(
  color: const Color(0xFFbfd37a), 
  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.post.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ": ",
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: widget.post.text,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          softWrap: true, 
          overflow: TextOverflow.visible,
        ),
      ),

      Row(
        children: [
          GestureDetector(
            onTap: openNewCommentBox,
            child: const Icon(Icons.comment, color: Colors.white),
          ),
          const SizedBox(width: 5),
          Text(
            widget.post.comments.length.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ],
  ),
),

if (widget.post.comments.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widget.post.comments.map((comment) {
      final isMyComment = comment.userId == currentUser?.uid; 
      return Container(
        width: double.infinity, 
        color: const Color(0xFFbfd37a),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${comment.username}: "${comment.text}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
                softWrap: true,
                overflow: TextOverflow.visible, 
              ),
            ),
            if (isMyComment)
              GestureDetector(
                onTap: () => showOptions(),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
          ],
        ),
      );
    }).toList(),
  ),
      ],
    ),
  );
}
}