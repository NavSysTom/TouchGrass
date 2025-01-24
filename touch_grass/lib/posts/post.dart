import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/comments/comment.dart';

class Post {
  final String id;
  final String userId;
  final String username;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      username: username,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      comments: comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    print('Post.fromJson: json = $json'); // Debug print statement

    final List<Comment> comments = (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson as Map<String, dynamic>))
            .toList() ?? [];

    print('Post.fromJson: comments = $comments'); // Debug print statement

    return Post(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      comments: comments,
    );
  }
}