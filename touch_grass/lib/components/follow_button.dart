import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {

  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
    });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(
        isFollowing ? 'Unfollow' : 'Follow',
        style: TextStyle(
          color: isFollowing ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}