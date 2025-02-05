import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/profile_state.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/services/profile_repo.dart';
import 'package:touch_grass/storage/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({
    required this.profileRepo,
    required this.storageRepo,
  }) : super(ProfileInitial());

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfile(uid);
      emit(ProfileLoaded(profileUser: user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<ProfileUser?> getuserProfile(String uid) async {
    try {
      return await profileRepo.fetchUserProfile(uid);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatedProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      String? imageDownloadUrl;

      if (imageWebBytes != null || imageMobilePath != null) {
        if (imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImage(imageMobilePath, uid);
        } else if (imageWebBytes != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError('Error uploading image'));
          return;
        }
      }

      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );
      await profileRepo.updateUserProfile(updatedProfile);

      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: ${e.toString()}"));
    }
  }

  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      print('Toggling follow for user: $currentUserId -> $targetUserId'); // Debug statement
      await profileRepo.toggleFollow(currentUserId, targetUserId);
      print('Follow toggled successfully'); // Debug statement
      await fetchUserProfile(targetUserId);
    } catch (e) {
      print('Error toggling follow: $e'); // Debug statement
      emit(ProfileError("Error toggling follow: ${e.toString()}"));
    }
  }
}
