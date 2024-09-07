import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  void _onItemTapped(int index) {
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88, // Fixed height for the custom bottom navigation bar
      decoration: BoxDecoration(
        color: Colors.transparent, // Set to transparent
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Slight shadow to elevate the icons
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: FontAwesomeIcons.home, index: 0, label: "Home"),
          _buildNavItem(icon: FontAwesomeIcons.tools, index: 1, label: "My Builds"),
          _buildNavItem(icon: FontAwesomeIcons.comments, index: 2, label: "Forum"),
          _buildNavItem(icon: FontAwesomeIcons.user, index: 3, label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    final isSelected = index == widget.currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 136, 136, 136),
            size: isSelected ? 37 : 30, // Increased size for the selected icon
          ),
          const SizedBox(height: 5), // Add spacing between the icon and text
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color.fromARGB(255, 255, 255, 255) : const Color(0xFFBABABA),
              fontSize: 12, // Slightly larger font size for the labels
            ),
          ),
        ],
      ),
    );
  }
}
