import 'package:touch_grass/screens/homeUI.dart';
import 'package:touch_grass/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/authenicate/register.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        backgroundColor: const Color(0xFFbfd37a),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 60.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Enter a password atleast 6+ characters long' : null,
                  onChanged: (val) {
                  setState(() => password = val);
                },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()){
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                      if (result == null){
                        setState(() {
                          error = 'Incorrect Sign In, Please Try Again';
                        });
                      } else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeUI()),
                        );
                      }
                    }
                  },
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}