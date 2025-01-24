import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/components/profile_user.dart';
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

  void getCurrentUser(){
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
      final fetchedUser = await profileCubit.getuserProfile(widget.post.userId);
      if (fetchedUser != null){
        setState(() {
          postUser = fetchedUser;
        });
      }
  }

  void showOptions(){
    showDialog(context: context,
     builder: (context) => AlertDialog(
      title: const Text("Delete Post?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"),),

        TextButton(onPressed: () { widget.onDeletePressed!(); Navigator.of(context).pop();
        },
        child: const Text("Delete")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            
                postUser?.profileImageUrl != null ? CachedNetworkImage(
                  imageUrl: postUser!.profileImageUrl,
                  errorWidget: ( context, url, error) =>const Icon(Icons.person),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: imageProvider,
                      fit: BoxFit.cover
                      )
                    ),
                  ),
                 ) : const Icon(Icons.person),
            
                 const Spacer(),

                const SizedBox(width: 10,),
            
                Text(widget.post.username),
                if(isOwnPost)
                GestureDetector(onTap: showOptions, child: const Icon(Icons.delete))
              ],

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
              Icon(Icons.favorite_border),

              const Spacer(),

              Text(widget.post.timestamp.toString())
            ],
          )
        ],
      ),
    );
  }
}
