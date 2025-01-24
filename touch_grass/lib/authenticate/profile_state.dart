import 'package:touch_grass/components/profile_user.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileUser profileUser;

  ProfileLoaded({required this.profileUser});
}

class ProfileError extends ProfileState {
  final String error;

  ProfileError(this.error);
}
