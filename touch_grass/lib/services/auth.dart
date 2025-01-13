import 'package:firebase_auth/firebase_auth.dart';
import 'package:touch_grass/models/myUser.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  myUser? _userFromFirebaseUser(User? user) {
    return user != null ? myUser(uid: user.uid) : null;
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
  // Auth change user stream
  Stream<myUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //register with email and password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}

