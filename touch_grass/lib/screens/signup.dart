import 'package:touch_grass/services/auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget{
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup>{

final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Color(0xFFbfd37a),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Sign in Anon'),
              onPressed: () async {
                dynamic result = await _auth.signInAnon();
                if (result == null){
                  print('error signing in');
                } else {
                  print('signed in');
                  print(result);
                }
              }
            ),
          ],
        ),
      ),
    );

  }
}