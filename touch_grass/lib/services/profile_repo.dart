import 'package:touch_grass/components/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser> fetchUserProfile(String uid);
  Future<void> updateUserProfile(ProfileUser profileUser);

}