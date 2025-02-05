import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/components/user_tile.dart';
import 'package:touch_grass/search/search_cubit.dart';
import 'package:touch_grass/search/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search users by email",
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoaded) {
            print('SearchLoaded state: ${state.users.length} users found'); // Debug statement
            if (state.users.isEmpty) {
              print('No users found'); // Debug statement
              return const Center(child: Text("No users found"));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                print('Displaying user: ${user?.name}'); // Debug statement
                return UserTile(user: user!);
              },
            );
          } else if (state is SearchLoading) {
            print('SearchLoading state'); // Debug statement
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchError) {
            print('SearchError state: ${state.message}'); // Debug statement
            return Center(child: Text(state.message));
          }
          print('SearchInitial state'); // Debug statement
          return const Center(child: Text("Search for users"));
        },
      ),
    );
  }
}