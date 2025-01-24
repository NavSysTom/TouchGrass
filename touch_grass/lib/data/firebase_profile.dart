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
          return ProfileUser(
            uid: uid, 
            email: userData['email'], 
            name: userData['name'], 
            bio: userData['bio'] ?? '', 
            profileImageUrl: userData['profileImageUrl'].toString()
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
}