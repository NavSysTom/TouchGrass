import 'package:flutter/material.dart';
import 'package:touch_grass/screens/log_in_page.dart';
import 'package:touch_grass/screens/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  bool showLoginPage = true;

  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LogInPage(
        togglePages: togglePage,

      );
    } else {
      return Register(
        togglePages: togglePage,
      );
    }
  }
}