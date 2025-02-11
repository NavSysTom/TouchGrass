import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/profile_state.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/services/profile_repo.dart';
import 'package:touch_grass/storage/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  Future<int> fetchStreakCount(String uid) async {
    try {
      final doc = await firestore.collection('streaks').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['streakCount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception("Failed to fetch streak count: $e");
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
      await profileRepo.toggleFollow(currentUserId, targetUserId);
      await fetchUserProfile(targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling follow: ${e.toString()}"));
    }
  }
}