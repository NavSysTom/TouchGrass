import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;

  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80, 
            child: Column(
              children: [
                Text(
                  postCount.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text("Posts"),
              ],
            ),
          ),
          SizedBox(
            width: 80, 
            child: Column(
              children: [
                Text(
                  followerCount.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text("Followers"),
              ],
            ),
          ),
          SizedBox(
            width: 80, 
            child: Column(
              children: [
                Text(
                  followingCount.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text("Following"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}