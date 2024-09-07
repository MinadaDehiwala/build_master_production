import 'package:build_master/screens/forum.dart';
import 'package:build_master/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../screens/login/forgotPassword/login_screen.dart';
import '../providers/user_provider.dart';
import '../screens/home_screen.dart'; // Import the home screen
import '../my_builds/my_builds_screen.dart'; // Import the My Builds screen

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required Map<String, String> userDetails});

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return; // Guard against using BuildContext if widget is unmounted
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!context.mounted) return; // Guard statement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during logout: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<UserProvider>(context).userDetails;
    final profileImageUrl = userDetails?['profileImageUrl'] ?? '';

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.6),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              '${userDetails?['firstName'] ?? ''} ${userDetails?['lastName'] ?? ''}',
              style: const TextStyle(color: Colors.white),
            ),
            accountEmail: Text(
              userDetails?['email'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: _buildProfileImage(profileImageUrl),
            decoration: const BoxDecoration(color: Colors.transparent),
          ),
          // Home button
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to home screen if not already there
              if (ModalRoute.of(context)?.settings.name != '/home') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen(firstName: 'FirstName')), // Pass appropriate data
                );
              }
            },
          ),
          // My Builds button
          ListTile(
            leading: const Icon(Icons.build, color: Colors.white),
            title: const Text('My Builds', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to My Builds screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBuildsScreen()),
              );
            },
          ),
          // Forum button
          ListTile(
            leading: const Icon(Icons.forum, color: Colors.white),
            title: const Text('Forum', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Forum screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              );
            },
          ),
          // Profile button
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Navigate to Profile screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage(userDetails: {},)), // Replace with actual Profile screen
              );
            },
          ),
          const Divider(color: Colors.white70),
          // Logout button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  // Build profile image with fallback to local asset image
  Widget _buildProfileImage(String profileImageUrl) {
    if (profileImageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profileImageUrl),
      );
    } else {
      return const CircleAvatar(
        child: Icon(Icons.person, color: Colors.white),
      );
    }
  }
}
