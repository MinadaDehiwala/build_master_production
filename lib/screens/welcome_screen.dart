import 'package:flutter/material.dart';
import 'login/forgotPassword/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 20, 23, 24), // Background color
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildTitle(screenHeight), // Title
            _buildVersion(), // Version text
            _buildGetStartedButton(context, screenWidth), // Button
          ],
        ),
      ),
    );
  }

  // Build the title text
  Widget _buildTitle(double screenHeight) {
    return Positioned(
      top: screenHeight * 0.4, // Responsive positioning
      child: const Text(
        'BuildMaster',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 40, // Keep font size responsive
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build the version text at the bottom
  Widget _buildVersion() {
    return const Positioned(
      bottom: 20,
      child: Text(
        'Version 1.0',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 117, 113, 113),
          fontSize: 16,
        ),
      ),
    );
  }

  // Build the 'Get Started' button
  Widget _buildGetStartedButton(BuildContext context, double screenWidth) {
    return Positioned(
      bottom: 80,
      left: screenWidth * 0.1, // Adjust button width responsively
      right: screenWidth * 0.1,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the LoginScreen
          try {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } catch (e) {
            // Handle navigation failure gracefully
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Unable to navigate to Login Screen. Please try again."),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
