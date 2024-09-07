import 'package:flutter/material.dart';

class QuickStartGuide extends StatelessWidget {
  const QuickStartGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Start Guide'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home Screen Section
            buildSectionTitle('Home Screen'),
            buildSectionImage('assets/images/home_screen.png'),
            buildSectionDescription(
              'Welcome Message: Personalized greeting with your name.\n\n'
              'Start with a new Build: Begin creating a new PC build.\n\n'
              'Quick Start Guide: Access this guide.\n\n'
              'Chat with AI Buddy: Get assistance from the AI.\n\n'
              'Part Recogniser: Identify PC parts by taking or uploading a picture.',
            ),
            const SizedBox(height: 20),
            
            // My Builds Screen Section
            buildSectionTitle('My Builds Screen'),
            buildSectionImage('assets/images/my_builds_screen.png'),
            buildSectionDescription(
              'Build List: View your saved builds.\n\n'
              'Build Details: Each build shows its name, components, and specifications.',
            ),
            const SizedBox(height: 20),
            
            // Forum Screen Section
            buildSectionTitle('Forum Screen'),
            buildSectionImage('assets/images/forum_screen.png'),
            buildSectionDescription(
              'Post and Reply: Engage with the community by posting questions or comments and replying to others.\n\n'
              'User Posts: View posts from other users with timestamps.',
            ),
            const SizedBox(height: 20),
            
            // Profile Screen Section
            buildSectionTitle('Profile Screen'),
            buildSectionImage('assets/images/profile_screen.png'),
            buildSectionDescription(
              'Profile Picture and Info: View your profile picture and information.\n\n'
              'Edit Profile: Update your profile details.\n\n'
              'Delete Profile: Remove your account and data.\n\n'
              'Sign Out: Log out of the app.',
            ),
            const SizedBox(height: 20),
            
            // Steps to Get Started Section
            buildSectionTitle('Steps to Get Started'),
            buildSectionDescription(
              '1. Create an Account:\n'
              '   - Open the app and navigate to the signup screen.\n'
              '   - Fill in your details and sign up.\n'
              '   - Optionally, upload a profile picture.\n\n'
              '2. Create a New Build:\n'
              '   - From the home screen, tap "Start with a new Build".\n'
              '   - Follow the prompts to add components to your build.\n'
              '   - Save the build to view it later in "My Builds".\n\n'
              '3. Use the Part Recogniser:\n'
              '   - Tap on "Take a Picture" or "Upload an Image" under Part Recogniser on the home screen.\n'
              '   - Capture or upload an image of a PC part to identify it.\n\n'
              '4. Chat with AI Buddy:\n'
              '   - Tap "Chat with AI Buddy" on the home screen.\n'
              '   - Ask questions or get recommendations for your PC build.\n\n'
              '5. Engage in the Forum:\n'
              '   - Go to the Forum screen.\n'
              '   - Write a post or reply to others to engage with the community.\n\n'
              '6. Manage Your Profile:\n'
              '   - Navigate to the Profile screen.\n'
              '   - Tap "Edit Profile" to update your information.\n'
              '   - Use "Delete Profile" to remove your account, or "Sign Out" to log out.\n',
            ),
            const SizedBox(height: 20),
            
            // Additional Tips Section
            buildSectionTitle('Additional Tips'),
            buildSectionDescription(
              'Navigation: Use the bottom navigation bar to switch between Home, My Builds, Forum, and Profile screens.\n\n'
              'Personalization: Update your profile regularly to keep your information current and accurate.\n\n'
              'Community Engagement: Participate in the forum to get the most out of the community features.\n\n'
              'For further assistance, you can always access this Quick Start Guide from the home screen.\n\n'
              'Happy building with Build Master!',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildSectionImage(String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Image.asset(assetPath),
    );
  }

  Widget buildSectionDescription(String description) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }
}
