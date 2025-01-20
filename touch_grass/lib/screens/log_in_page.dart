import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/components/button.dart';
import 'package:touch_grass/components/textfield.dart';


class LogInPage extends StatefulWidget {
  final void Function()? togglePages;

  const LogInPage({super.key, required this.togglePages,});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {


  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void logIn() {
    final String email = emailController.text;
    final String password = passwordController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && password.isNotEmpty) {
      authCubit.login(email, password);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
    }
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFbfd37a),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_open_rounded, size: 100.0, color: Colors.black),

              // Welcome back message
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Email input
              MyTextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              // Password textfield
              MyTextfield(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              // Login button
              MyButton(
                onTap: logIn,
                text: 'Log In',
              ),

              // Not a member? Register button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not a member? '),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Change to your desired color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
