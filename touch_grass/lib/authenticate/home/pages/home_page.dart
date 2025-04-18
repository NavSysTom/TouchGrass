import 'package:flutter/material.dart';
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
  bool showFollowedPosts = false;
  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void fetchFollowedPosts() {
    postCubit.fetchFollowedPosts();
  }

  void fetchPostsByCategory(String category) {
    if (category == 'all') {
      fetchAllPosts();
    } else {
      postCubit.fetchPostsByCategory(category);
    }
  }

  void deletePost(String postId) async {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Grass', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFbfd37a),
        actions: [
          IconButton(
            icon: Icon(showFollowedPosts ? Icons.people : Icons.people_outline),
            onPressed: () {
              setState(() {
                showFollowedPosts = !showFollowedPosts;
              });
              if (showFollowedPosts) {
                fetchFollowedPosts();
              } else {
                fetchAllPosts();
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (String category) {
              setState(() {
                selectedCategory = category;
              });
              fetchPostsByCategory(category);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('All'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'flowers',
                  child: Row(
                    children: [
                      Icon(Icons.local_florist, color: Colors.pink),
                      SizedBox(width: 8),
                      Text('Flowers'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'bugs',
                  child: Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Bugs'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'animals',
                  child: Row(
                    children: [
                      Icon(Icons.pets, color: Colors.brown),
                      SizedBox(width: 8),
                      Text('Animals'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'wildscape',
                  child: Row(
                    children: [
                      Icon(Icons.landscape, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Wildscape'),
                    ],
                  ),
                ),
              ];
            },
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

  return ListView.separated(
    itemCount: allPosts.length,
    itemBuilder: (context, index) {
      final post = allPosts[index];

      return PostTile(post: post, onDeletePressed: () => deletePost(post.id));
    },
    separatorBuilder: (context, index) => const Divider(
      color: Colors.grey, 
      thickness: 2, 
      height: 2, 
    ),
  );
          } else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadPostPage()),
        ),
        backgroundColor: const Color(0xFFbfd37a),
        child: const Icon(Icons.add),
      ),
    );
  }
}