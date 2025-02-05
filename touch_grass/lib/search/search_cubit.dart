import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/search/search_repo.dart';
import 'package:touch_grass/search/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({
    required this.searchRepo,
  }) : super(SearchInitial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      emit(SearchLoading());
      print('Searching for users with query: $query'); // Debug statement
      final users = await searchRepo.searchUsers(query);
      print('Search results: ${users.length} users found'); // Debug statement
      emit(SearchLoaded(users));
    } catch (e) {
      print('Error searching: $e'); // Debug statement
      emit(SearchError('Error searching'));
    }
  }
}