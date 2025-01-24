import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_states.dart';
import 'package:touch_grass/services/app_user.dart';
import 'package:touch_grass/services/auth_repo.dart';


class AuthCubit extends Cubit<AuthState>{
  final AuthServiceRepo authRepo;
  AppUser? _currentUser; 

  AuthCubit({required this.authRepo, required authServiceRepo}) : super(AuthInitial());

  //check if user is authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();
    
    if(user != null){
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(UnAuthenticated());
    }
  }

  // get current user
  AppUser? get currentUser => _currentUser;

  // login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepo.loginwithEmailPassword(email, password);
      if(user != null){
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch(e){
      emit(AuthError(e.toString()));
    }
  }

  // register with email and password
  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepo.registerwithEmailPassword(name, email, password);
      if(user != null){
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch(e){
      emit(AuthError(e.toString()));
    }
  }

  // sign out
  Future<void> signOut() async {
     authRepo.signOut();
    _currentUser = null;
    emit(UnAuthenticated());
  }
}
