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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 60.0),
                Text(
                  'Signup',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40.0),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (val) => val!.length < 6 ? 'Enter a password at least 6+ characters long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Password must be at least 6 characters long',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50), // Green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                        if (result == null) {
                          setState(() {
                            error = 'Incorrect Sign In, Please Try Again';
                          });
                        } else {
                          // Navigate to HomeUI after successful login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeUI()),
                          );
                        }
                      }
                    },
                    child: const Text('Log In'),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 14.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                        child: Text(
                          'Register here',
                          style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: 14.0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}