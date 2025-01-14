import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/authenicate/authenticate.dart';
import 'package:touch_grass/services/auth.dart';
import 'models/myUser.dart';
import 'screens/homeUI.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<myUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        home: Wrapper(),
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return HomeUI();
    }
  }
}