import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/comments/comment.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:touch_grass/posts/post_states.dart';
import 'package:touch_grass/storage/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference postCollection = FirebaseFirestore.instance.collection('posts');
  final StorageRepo storageRepo;

  PostCubit({
    required this.storageRepo,
  }) : super(PostsInitial());

  Future<void> createPost(Post post, {String? imageMobilePath, Uint8List? imageWebBytes}) async {
    String? imageUrl;

    try {
      emit(PostsUploading());

      // Upload the image
      if (imageMobilePath != null) {
        imageUrl = await storageRepo.uploadPostImage(imageMobilePath, post.id);
      } else if (imageWebBytes != null) {
        imageUrl = await storageRepo.uploadPostImageWeb(imageWebBytes, post.id);
      }

      // Create a new post with the uploaded image URL
      final newPost = post.copyWith(imageUrl: imageUrl);
      await postCollection.doc(newPost.id).set(newPost.toJson());

      // Handle streak count
      final userId = post.userId;
      final streakCount = await _getStreakCount(userId);
      final lastPostDate = await _getLastPostDate(userId);
      final now = DateTime.now();

      final lastPostDateOnly = lastPostDate != null
          ? DateTime(lastPostDate.toDate().year, lastPostDate.toDate().month, lastPostDate.toDate().day)
          : null;
      final nowDateOnly = DateTime(now.year, now.month, now.day);

      if (lastPostDateOnly == null) {
        // First post, initialize streak
        await _updateStreakCount(userId, 1);
      } else if (lastPostDateOnly.isBefore(nowDateOnly.subtract(const Duration(days: 1)))) {
        // Reset streak count if the last post was more than 1 day ago
        await _updateStreakCount(userId, 1);
      } else if (lastPostDateOnly.isAtSameMomentAs(nowDateOnly.subtract(const Duration(days: 1)))) {
        // Increment streak count if the last post was exactly 1 day ago
        await _updateStreakCount(userId, streakCount + 1);
      } else {
        // Keep the same streak count if the post was made today
        await _updateStreakCount(userId, streakCount);
      }

      // Fetch all posts and emit the updated state
      final posts = await _fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to create post: $e"));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await _fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts: $e"));
    }
  }

  Future<void> fetchPostsByCategory(String category) async {
    try {
      emit(PostsLoading());
      final postsSnapshot = await postCollection
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .get();

      final List<Post> categoryPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      emit(PostsLoaded(categoryPosts));
    } catch (e) {
      emit(PostsError("Failed to fetch posts by category: $e"));
    }
  }

  Future<void> fetchFollowedPosts() async {
    try {
      emit(PostsLoading());
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(PostsError("User not logged in"));
        return;
      }

      final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        emit(PostsError("User not found"));
        return;
      }

      final followedUsers = List<String>.from(userDoc.data()?['following'] ?? []);
      if (followedUsers.isEmpty) {
        emit(PostsLoaded([]));
        return;
      }

      final postsSnapshot = await postCollection
          .where('userId', whereIn: followedUsers)
          .orderBy('timestamp', descending: true)
          .get();

      final List<Post> followedPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      emit(PostsLoaded(followedPosts));
    } catch (e) {
      emit(PostsError("Failed to fetch followed posts: $e"));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      emit(PostsLoading());
      await postCollection.doc(postId).delete();
      final posts = await _fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to delete post: $e"));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.add(comment);

        await postCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });

        final posts = await _fetchAllPosts();
        emit(PostsLoaded(posts));
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.removeWhere((comment) => comment.id == commentId);

        await postCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });

        final posts = await _fetchAllPosts();
        emit(PostsLoaded(posts));
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      emit(PostsError("Failed to delete comment: $e"));
    }
  }

  Future<int> _getStreakCount(String userId) async {
    final doc = await firestore.collection('streaks').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['streakCount'] ?? 0;
    } else {
      return 0;
    }
  }

  Future<void> _updateStreakCount(String userId, int streakCount) async {
    await firestore.collection('streaks').doc(userId).set({
      'streakCount': streakCount,
      'lastPostDate': Timestamp.now(), // Update the last post timestamp
    }, SetOptions(merge: true));
  }

  Future<Timestamp?> _getLastPostDate(String userId) async {
    final doc = await firestore.collection('streaks').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['lastPostDate'];
    } else {
      return null;
    }
  }

  Future<List<Post>> _fetchAllPosts() async {
    try {
      final postsSnapshot = await postCollection.orderBy('timestamp', descending: true).get();
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return allPosts;
    } catch (e) {
      throw Exception("error fetching posts: $e");
    }
  }
}