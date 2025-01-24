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

      DocumentSnapshot userDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();

       AppUser user = AppUser(
         uid: userCredential.user!.uid,
         email: email,
         name : userDoc['name'], 
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

    DocumentSnapshot userDoc = await firestore.collection("users").doc(firebaseUser!.uid).get();

    if (!userDoc.exists) {
      return null;
    } else {
      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email!,
        name: userDoc['name'],
      );
    }   
  }

}