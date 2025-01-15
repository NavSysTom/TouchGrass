import 'package:flutter/material.dart';
import 'package:touch_grass/services/auth.dart';
import 'package:touch_grass/models/myUser.dart';
import 'package:provider/provider.dart';
import 'package:touch_grass/authenicate/authenticate.dart';
import 'package:touch_grass/screens/homeUI.dart';

class ProfilePage extends StatelessWidget {
  final myUser? user;
  final AuthService _auth = AuthService();

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    // Replace with actual logic to get the number of friends
    int numberOfFriends = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Authenticate()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${user?.uid ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Number of Friends: $numberOfFriends', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement search friends functionality
              },
              child: Text('Search for Friends'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeUI()),
            );
          }
        },
      ),
    );
  }
}