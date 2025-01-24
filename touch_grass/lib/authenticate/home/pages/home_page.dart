import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/authenticate/home/pages/upload_post_page.dart';
import 'package:touch_grass/components/drawer.dart';
import 'package:touch_grass/components/post_tile.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/posts/post_states.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) async {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Touch Grass'),
        centerTitle: true,
        backgroundColor: Color(0xFFbfd37a),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPostPage()),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          if (state is PostsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(child: Text("No posts available"));
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];

                return PostTile(post: post, onDeletePressed: () => deletePost(post.id));
              },
            );
          } else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}