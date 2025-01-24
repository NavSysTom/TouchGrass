import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:touch_grass/posts/post_repo.dart';
import 'package:touch_grass/posts/post_states.dart';
import 'package:touch_grass/storage/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imageMobilePath, Uint8List? imageWebBytes}) async {
    String? imageUrl;

    try {
      emit(PostsUploading());

      if (imageMobilePath != null) {
        imageUrl =
            await storageRepo.uploadPostImage(imageMobilePath, post.id);
      } else if (imageWebBytes != null) {
        imageUrl =
            await storageRepo.uploadPostImageWeb(imageWebBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      await postRepo.createPost(newPost);

      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to create post: $e"));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      emit(PostsLoading());
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError("Failed to delete post: $e"));
    }
  }
}
