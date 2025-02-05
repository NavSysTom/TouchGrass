import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/services/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo{

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser> fetchUserProfile(String uid) async {
    try{

      final userDoc = await firebaseFirestore
      .collection('users')
      .doc(uid)
      .get();

      if(userDoc.exists){
        final userData = userDoc.data();
        
        if(userData != null){
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
            uid: uid, 
            email: userData['email'], 
            name: userData['name'], 
            bio: userData['bio'] ?? '', 
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: followers,
            following: following
          );
        }
      }
      throw Exception('User not found');
    }
    catch(e){
      throw Exception(e);
    }
  }

  @override
  Future<void> updateUserProfile(ProfileUser updatedProfile) async{
    try{
      await firebaseFirestore
      .collection('users')
      .doc(updatedProfile.uid)
      .update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl
      });
    } 
    catch(e){
      throw Exception(e);
    }
  }

@override
Future<void> toggleFollow(String currentUid, String targetUid) async {
  try {
    final currentUserDoc = await firebaseFirestore.collection('users').doc(currentUid).get();
    final targetUserDoc = await firebaseFirestore.collection('users').doc(targetUid).get();

    if (currentUserDoc.exists && targetUserDoc.exists) {
      final currentData = currentUserDoc.data();
      final targetData = targetUserDoc.data();

      if (currentData != null && targetData != null) {
        final currentFollowing = List<String>.from(currentData['following'] ?? []);
        final targetFollowers = List<String>.from(targetData['followers'] ?? []);

        if (currentFollowing.contains(targetUid)) {
          currentFollowing.remove(targetUid);
          targetFollowers.remove(currentUid);

          await firebaseFirestore.collection('users').doc(currentUid).update({
            'following': FieldValue.arrayRemove([targetUid])
          });

          await firebaseFirestore.collection('users').doc(targetUid).update({
            'followers': FieldValue.arrayRemove([currentUid])
          });

          print('Unfollowed user: $targetUid'); // Debug statement
        } else {
          currentFollowing.add(targetUid);
          targetFollowers.add(currentUid);

          await firebaseFirestore.collection('users').doc(currentUid).update({
            'following': FieldValue.arrayUnion([targetUid])
          });

          await firebaseFirestore.collection('users').doc(targetUid).update({
            'followers': FieldValue.arrayUnion([currentUid])
          });

          print('Followed user: $targetUid'); // Debug statement
        }

        // Update the local lists after Firestore update
        await firebaseFirestore.collection('users').doc(currentUid).update({
          'following': currentFollowing
        });

        await firebaseFirestore.collection('users').doc(targetUid).update({
          'followers': targetFollowers
        });

        print('Updated following and followers lists'); // Debug statement
      }
    }
  } catch (e) {
    print('Error toggling follow: $e'); // Debug statement
    throw Exception(e);
  }
}
}