import 'package:touch_grass/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:touch_grass/screens/signup.dart'; // Import the Signin page

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Account'),
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
                  validator: (val) => val!.length < 6 ? 'Enter a password at least 6+ characters long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                      if (result == null) {
                        setState(() {
                          error = 'Please supply a valid email';
                        });
                      }
                    }
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(height: 20.0),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  },
                  child: const Text('Already have an account? Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}