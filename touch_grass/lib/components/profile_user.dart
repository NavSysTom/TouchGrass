import 'package:touch_grass/services/app_user.dart';

class ProfileUser extends AppUser{

    final String bio;
    final String profileImageUrl;

    ProfileUser({
      required String uid,
      required String email,
      required String name,
      required this.bio,
      required this.profileImageUrl
    }) : super(uid: uid, email: email, name: name);


    ProfileUser copyWith({
      String? newBio,
      String? newProfileImageUrl
    }) {
      return ProfileUser(
        uid: uid,
        email: email,
        name: name,
        bio: newBio ?? bio,
        profileImageUrl: newProfileImageUrl ?? profileImageUrl
      );
    }

    //covert profile to json
    Map<String, dynamic> toJson() {
      return {
        'uid': uid,
        'email': email,
        'name': name,
        'bio': bio,
        'profileImageUrl': profileImageUrl
      };
    }
    //convert json to profile
    factory ProfileUser.fromJson(Map<String, dynamic> jsonUser) {
      return ProfileUser(
        uid: jsonUser['uid'],
        email: jsonUser['email'],
        name: jsonUser['name'],
        bio: jsonUser['bio'] ?? '', 
        profileImageUrl: jsonUser['profileImageUrl'] ?? ''
      );
    }

 }