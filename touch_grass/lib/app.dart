import 'package:firebase_auth/firebase_auth.dart';
import 'package:touch_grass/authenticate/profile_cubit.dart';
import 'package:touch_grass/data/firebase_auth.dart';
import 'package:touch_grass/data/firebase_profile.dart';
import 'package:touch_grass/posts/post_cubit.dart';
import 'package:touch_grass/screens/auth_page.dart';
import 'package:touch_grass/search/firebase_search_repo.dart';
import 'package:touch_grass/search/search_cubit.dart';
import 'package:touch_grass/storage/firebase_storage_repo.dart';
import 'authenticate/auth_cubit.dart';
import 'authenticate/auth_states.dart';
import 'authenticate/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final profileRepo = FirebaseProfileRepo();
    final storageRepo = FirebaseStorageRepo();
    final searchRepo = FirebaseSearchRepo();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: FirebaseAuthRepo(), firebaseAuth: _firebaseAuth),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: profileRepo,
            storageRepo: storageRepo,
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(storageRepo: storageRepo),
        ),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepo: searchRepo),
        ),
      ],
      child: MaterialApp(
        title: 'Touch Grass',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is UnAuthenticated) {
              return const AuthPage();
            }
            if (authState is Authenticated) {
              return const HomePage();
            } else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          listener: (context, authState) {
            if (authState is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(authState.message)),
              );
            }
          },
        ),
      ),
    );
  }
}