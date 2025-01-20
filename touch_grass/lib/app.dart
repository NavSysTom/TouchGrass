import 'package:touch_grass/data/firebase_auth.dart';
import 'package:touch_grass/screens/auth_page.dart';
import 'authenticate/auth_cubit.dart';
import 'authenticate/auth_states.dart';
import 'authenticate/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class MyApp extends StatelessWidget {

  final AuthServiceRepo = FirebaseAuthRepo();


  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AuthCubit(authRepo: AuthServiceRepo)..checkAuth(),
    child: MaterialApp(
      title: 'Touch Grass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocConsumer<AuthCubit, AuthState> (builder: (context, authState){
        if(authState is UnAuthenticated){
          return const AuthPage();
        } 
        if(authState is Authenticated){
          return const HomePage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ), 
          );
        }
      } , listener: (context, authState) {
        if (authState is AuthError){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authState.message)));
        }
      },
      ),
    )
    );
  }
}