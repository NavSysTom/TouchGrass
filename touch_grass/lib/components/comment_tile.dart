import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/comments/comment.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:touch_grass/services/app_user.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.comment.userId == currentUser!.uid);
  }

  void showOptions() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Comment?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                    onPressed: () {
                      context.read<PostCubit>().deleteComment(widget.comment.postId, widget.comment.id);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Delete")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.comment.username}: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(widget.comment.text),
          ),
          if (isOwnPost)
            GestureDetector(
              onTap: showOptions,
              child: const Icon(Icons.more_horiz),
            ),
        ],
      ),
    );
  }
}