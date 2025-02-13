import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touch_grass/components/profile_user.dart';
import 'package:touch_grass/search/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try {
      print('Executing search query: $query'); 
      final result = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isGreaterThanOrEqualTo: query)
          .where("email", isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      print('Search query executed successfully'); 
      final users = result.docs
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .toList();
      print('Users found: ${users.length}');
      return users;
    } catch (e) {
      print('Error executing search query: $e'); 
      throw Exception('Error searching');
    }
  }
}