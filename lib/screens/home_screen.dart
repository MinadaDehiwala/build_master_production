import 'package:build_master/my_builds/create_build_screen.dart';
import 'package:build_master/my_builds/my_builds_screen.dart';
import 'package:build_master/screens/ai/ai_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:build_master/providers/user_provider.dart';

import 'package:build_master/screens/QuickStartGuide.dart';
import 'package:build_master/widgets/custom_bottom_navbar.dart';
import 'package:build_master/components/side_panel.dart';
import 'package:build_master/components/notification_menu.dart';
import 'package:build_master/screens/ai/camera_screen.dart';
import 'package:build_master/screens/ai/gallery_screen.dart';
import 'package:build_master/screens/compatibility.dart';
import 'package:build_master/screens/browse_shops_screen.dart'; // Import the new BrowseShopsScreen
// Add prefixes to imports to resolve conflicts
import 'package:build_master/screens/forum.dart' as forum1;
import 'package:build_master/screens/profile_page.dart' as profile1;

class HomeScreen extends StatefulWidget {
  final String firstName;

  const HomeScreen({super.key, required this.firstName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  late AnimationController _arrowAnimationController;
  late AnimationController _textAnimationController;
  final PageController _pageController = PageController();
  bool _showSwipeRightText = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserDetails();
    });

    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showNotifications() {
    showNotificationsMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<UserProvider>(context).userDetails;
    final userDetailsString = userDetails?.map((key, value) => MapEntry(key, value.toString())) ?? {
      'firstName': widget.firstName,
      'lastName': 'Doe',
      'email': 'john.doe@example.com',
      'profileImageUrl': '',
    };

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: CustomDrawer(userDetails: userDetailsString),
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _showSwipeRightText = index == 0;
                });
              },
              children: [
                _buildHomePage(),
                const MyBuildsScreen(),
                const forum1.ForumPage(),
                profile1.ProfilePage(userDetails: userDetailsString),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: _showNotifications,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: _openDrawer,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/build_master.png',
                  height: 23,
                ),
              ),
            ),
            if (_showSwipeRightText)
              Positioned(
                bottom: 90,
                right: 20,
                child: Row(
                  children: [
                    const Text(
                      'Swipe right to navigate',
                      style: TextStyle(color: Color.fromARGB(255, 93, 93, 93), fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    AnimatedBuilder(
                      animation: _arrowAnimationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_arrowAnimationController.value * 10 - 5, 0),
                          child: child,
                        );
                      },
                      child: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 93, 93, 93), size: 16),
                    ),
                  ],
                ),
              ),
            if (!_showSwipeRightText)
              Positioned(
                bottom: 90,
                left: 20,
                child: AnimatedBuilder(
                  animation: _arrowAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-(_arrowAnimationController.value * 10 - 5), 0),
                      child: child,
                    );
                  },
                  child: const Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 93, 93, 93), size: 16),
                ),
              ),
            if (_currentIndex != 3 && !_showSwipeRightText)
              Positioned(
                bottom: 90,
                right: 20,
                child: AnimatedBuilder(
                  animation: _arrowAnimationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_arrowAnimationController.value * 10 - 5, 0),
                      child: child,
                    );
                  },
                  child: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 93, 93, 93), size: 16),
                ),
              ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
                      child: AnimatedText(
                        text: 'Welcome, ${widget.firstName}!',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        animationController: _textAnimationController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Replaced text with the requested 'Enjoy building your dream PC.'
                  const Text(
                    'Enjoy building your dream PC.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateBuildScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC6F432),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Start with a new Build',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const QuickStartGuide()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1DB954),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Quick Start Guide',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CompatibilityPage()), // Navigate to CompatibilityScreen
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD700),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Check Compatibility',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // New Button for 'Browse Shops'
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BrowseShopsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF), // New Color for 'Browse Shops' button
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Browse Shops',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Adding back the "How may we help you today?" text
                  const Text(
                    'How may we help you today?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/ai_buddy.png',
                                height: 80,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AIChatPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC6F432),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Chat with AI Buddy',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(left: 1),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Part Recogniser',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CameraScreen()), // Navigate to CameraScreen
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC6F432),
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Image.asset(
                                    'assets/images/ai_camera_icon.png',
                                    height: 22,
                                  ),
                                ),
                                label: const Text(
                                  'Take a Picture',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const GalleryScreen()), // Navigate to GalleryScreen
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC6F432),
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: Image.asset(
                                  'assets/images/image_upload_icon.png',
                                  height: 22,
                                ),
                                label: const Text(
                                  'Upload an Image',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Adding back the bottom AI Buddy help text
                  const Text(
                    'Your AI Buddy will help you build your dream PC',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final AnimationController animationController;

  const AnimatedText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        int textLength = (text.length * animationController.value).round();
        String displayedText = textLength > 0 ? text.substring(0, textLength) : '';
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              minWidth: 1,
              minHeight: 1,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: displayedText,
                style: textStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
