import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:touch_grass/comments/comment.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFbfd37a),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CachedNetworkImage(
            imageUrl: post.imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            imageBuilder: (context, imageProvider) => Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            post.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            'Posted by ${post.username}',
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: post.comments.length,
            itemBuilder: (context, index) {
              final Comment comment = post.comments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${comment.username}: ',
                      style: const TextStyle(
                      ),
                    ),
                    Expanded(
                      child: Text(comment.text),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}