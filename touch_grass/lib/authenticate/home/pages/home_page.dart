import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/authenticate/auth_cubit.dart';
import 'package:touch_grass/components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Touch Grass'),
        centerTitle: true,
        backgroundColor: Color(0xFFbfd37a),

        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
    );
  }
}