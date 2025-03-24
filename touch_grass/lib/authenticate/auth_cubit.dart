import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:touch_grass/authenticate/auth_states.dart';
import 'package:touch_grass/services/app_user.dart';
import 'package:touch_grass/services/auth_repo.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthServiceRepo authRepo;
  final FirebaseAuth _firebaseAuth;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo, required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        super(AuthInitial()) {
    _monitorAuthState();
  }

  // Check if user is authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(UnAuthenticated());
    }
  }

  // Get current user
  AppUser? get currentUser => _currentUser;

  // Login with email and password
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepo.loginwithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Register with email and password
  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepo.registerwithEmailPassword(name, email, password);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Sign out
  Future<void> signOut() async {
    await authRepo.signOut();
    _currentUser = null;
    emit(UnAuthenticated());
  }

  // Monitor Firebase Authentication state
  void _monitorAuthState() {
    _firebaseAuth.authStateChanges().listen((user) {
      if (user == null) {
        emit(UnAuthenticated());
      } else {
        _checkUserDocument(user.uid);
      }
    });
  }

  // Check if Firestore user document exists
  Future<void> _checkUserDocument(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _currentUser = AppUser(
          uid: userId,
          name: userDoc.data()?['name'] ?? 'Unknown',
          email: userDoc.data()?['email'] ?? 'Unknown',
        );
        emit(Authenticated(_currentUser!));
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to check user document: $e'));
    }
  }

  // Emit unauthenticated state
  void emitUnauthenticated() {
    emit(UnAuthenticated());
  }
}