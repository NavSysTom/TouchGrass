import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:touch_grass/services/app_user.dart';
import 'package:touch_grass/services/auth_repo.dart';

class FirebaseAuthRepo  implements AuthServiceRepo{

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginwithEmailPassword(String email, String password) async {
    try{ 
       UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

       AppUser user = AppUser(
         uid: userCredential.user!.uid,
         email: email,
         name : '', 
       );

       return user;
    } catch(e){
      throw('Login failed $e');
    }
  }

  @override
  Future<AppUser?> registerwithEmailPassword(String name, String email, String password) async {
    try{ 
       UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

       AppUser user = AppUser(
         uid: userCredential.user!.uid,
         email: email,
         name : name, 
       );

       //save user data in firestore
       await firestore
       .collection("users")
       .doc(user.uid)
       .set(user.toJson());

       return user;
    } catch(e){
      throw('Login failed $e');
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();

  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    } else {
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: '',
      );
    }   
  }

}