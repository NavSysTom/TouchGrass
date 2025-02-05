import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/authenticate/home/pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;

  const UserTile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: user.profileImageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: user.profileImageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.person),
              imageBuilder: (context, imageProvider) => CircleAvatar(
                backgroundImage: imageProvider,
              ),
            )
          : const CircleAvatar(
              child: Icon(Icons.person),
            ),
      title: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: user.uid),
          ),
        ),
        child: Text(user.name),
      ),
      subtitle: Text(user.email),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    );
  }
}