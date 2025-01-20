import '../services/app_user.dart';

 abstract class AuthServiceRepo{
  
  Future<AppUser?> loginwithEmailPassword(String email, String password);
  Future<AppUser?> registerwithEmailPassword(String name, String email, String password);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
 }