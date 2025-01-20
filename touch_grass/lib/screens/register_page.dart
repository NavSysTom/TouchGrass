import 'package:provider/provider.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/components/button.dart';
import 'package:touch_grass/components/textfield.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();

  final void Function()? togglePages;

  const Register({Key? key, required this.togglePages});
}

class _RegisterState extends State<Register> {


  //text controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register(){ 
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    final authCubit = context.read<AuthCubit>();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      if(password == confirmPassword){
        authCubit.register(name, email, password);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
          ),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all fields'),
        ),
      );
    }
  }
 
 @override
 void dispose() {
   nameController.dispose();
   emailController.dispose();
   passwordController.dispose();
   confirmPasswordController.dispose();
   super.dispose();
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
        
            const Text(
              'Welcome to Touch Grass! Create an account to get started.',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),  
            //email input
            MyTextfield(
              controller: nameController,
              hintText: 'Name',
              obscureText: false,
            ),

            MyTextfield(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
        
            //password textfield
            MyTextfield(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
        
         //confirm password textfield
            MyTextfield(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),
        
            //Register button
            MyButton(onTap: register,
             text: 'Register'),
        
        
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already a member? '),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: const Text(
                      'Login now',
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