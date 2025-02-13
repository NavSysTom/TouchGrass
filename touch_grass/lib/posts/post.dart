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
  final String category; // Add this line

  Post({
    required this.id,
    required this.userId,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.comments,
    required this.category, // Add this line
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
      category: category, // Add this line
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
      'category': category, // Add this line
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final List<Comment> comments = (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson as Map<String, dynamic>))
            .toList() ?? [];

    return Post(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      comments: comments,
      category: json['category'] as String? ?? '', // Add this line
    );
  }
}