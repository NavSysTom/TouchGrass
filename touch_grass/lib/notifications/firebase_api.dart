import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

bool hasPostedToday(DateTime lastPostDate) {
  final now = DateTime.now();
  return now.year == lastPostDate.year &&
         now.month == lastPostDate.month &&
         now.day == lastPostDate.day;
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final usersSnapshot = await _firestore.collection('users').get();
    return usersSnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> sendDailyNotifications() async {
    final users = await fetchAllUsers();
    final now = DateTime.now();

    for (final user in users) {
      final lastPostDate = DateTime.parse(user['lastPostDate']);
      final fcmToken = user['fcmToken'];

      if (!hasPostedToday(lastPostDate) && fcmToken != null) {
        await _firebaseMessaging.sendMessage(
          to: fcmToken,
          data: {
            'title': 'Daily Reminder',
            'body': 'Don\'t forget to post a photo today!',
          },
        );
        print('Notification sent to user: ${user['uid']}');
      }
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    print('Notification permission granted');
    final token = await _firebaseMessaging.getToken();
    print('Firebase token: $token');

    if (token != null) {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
        print('FCM token stored in Firestore');
      }
    }
  }
}