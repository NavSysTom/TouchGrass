import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/comments/comment.dart';
import 'package:touch_grass/posts/post.dart';
import 'package:touch_grass/posts/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference postCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postsSnapshot =
          await postCollection.orderBy('timestamp', descending: true).get();

      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception("error fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUser(String userId) async {


    try {
      final postsSnapshot =
          await postCollection.where('userId', isEqualTo: userId).get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("error fetching posts by user: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try{
      final postDoc = await postCollection.doc(postId).get();

      if(postDoc.exists){
        final post = Post.fromJson(postDoc.data() as Map<String,dynamic>);

        post.comments.add(comment);

        await postCollection.doc(postId).update({'comments': post.comments.map((comment) => comment.toJson()).toList()});
      }
      else{
        throw Exception("Post not found");
      }
    }catch(e){
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
      try{
      final postDoc = await postCollection.doc(postId).get();

      if(postDoc.exists){
        final post = Post.fromJson(postDoc.data() as Map<String,dynamic>);

        post.comments.removeWhere((comment) => comment.id == commentId);

        await postCollection.doc(postId).update({'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      }
      else{
        throw Exception("Post not found");
      }
    }catch(e){
      throw Exception("Error deleting comment: $e");
    }
  }
}

