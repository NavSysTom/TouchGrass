import 'package:cloud_firestore/cloud_firestore.dart';

class Streak {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String text;
  final DateTime timestamp;
  int streakCount; // Add streakCount field

  Streak({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.text,
    required this.timestamp,
    this.streakCount = 0, // Initialize streakCount
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'streakCount': streakCount, // Add streakCount to JSON
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    print('Streak.fromJson: json = $json'); // Debug print statement

    return Streak(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '', // Ensure correct field name
      text: json['text'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      streakCount: json['streakCount'] as int? ?? 0, // Retrieve streakCount
    );
  }

  // Method to retrieve streak count from Firebase
  static Future<int> getStreakCount(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('streaks').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['streakCount'] ?? 0;
    } else {
      return 0;
    }
  }

  // Method to update streak count in Firebase
  static Future<void> updateStreakCount(String userId, int streakCount) async {
    await FirebaseFirestore.instance.collection('streaks').doc(userId).set({
      'streakCount': streakCount,
    }, SetOptions(merge: true));
  }
}