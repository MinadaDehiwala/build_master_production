import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'create_build_screen.dart';

class MyBuildsScreen extends StatefulWidget {
  const MyBuildsScreen({super.key});

  @override
  _MyBuildsScreenState createState() => _MyBuildsScreenState();
}

class _MyBuildsScreenState extends State<MyBuildsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, dynamic>>> _fetchUserBuilds;

  @override
  void initState() {
    super.initState();
    _fetchUserBuilds = _getUserBuilds();
  }

  Future<List<Map<String, dynamic>>> _getUserBuilds() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      final QuerySnapshot snapshot = await _firestore
          .collection('builds')
          .where('userId', isEqualTo: user.uid)
          .orderBy('buildName', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching builds: $e');
      throw Exception('Error fetching builds');
    }
  }

  // Method to delete build from Firestore and Firebase Storage
  Future<void> _deleteBuild(String buildId, String? imageUrl) async {
    try {
      // Delete the build document from Firestore
      await _firestore.collection('builds').doc(buildId).delete();

      // If there is an imageUrl, delete the image from Firebase Storage
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }

      // Refresh the build list
      setState(() {
        _fetchUserBuilds = _getUserBuilds();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Build deleted successfully')),
      );
    } catch (e) {
      print('Error deleting build: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting build: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0), // Adjusted padding to bring content down
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "My Builds",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateBuildScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Create New Build",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchUserBuilds,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching builds', style: TextStyle(color: Colors.white)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildNoBuildsView();
                      } else {
                        return _buildBuildsListView(snapshot.data!);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBuildsView() {
    return const Center(
      child: Text(
        "You don't have any builds yet",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildBuildsListView(List<Map<String, dynamic>> builds) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: builds.length,
      itemBuilder: (context, index) {
        final build = builds[index];
        final String? buildImageUrl = build['imageUrl'] as String?;
        final String buildId = build['buildId'] ?? '';

        return Card(
          color: Colors.black.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Build image (left side)
                    buildImageUrl != null && buildImageUrl.isNotEmpty
                        ? Image.network(buildImageUrl, width: 150, height: 150, fit: BoxFit.cover)
                        : const Icon(Icons.computer, color: Colors.white, size: 120), // Fallback image if no image is available
                    const SizedBox(width: 10),
                    // Build details (right side)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(build['buildName'] ?? 'Unknown Build',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text('CPU: ${build['cpu'] ?? 'Unknown CPU'}', style: const TextStyle(color: Colors.grey)),
                          Text('HDD: ${build['hdd'] ?? 'No HDD Available'}', style: const TextStyle(color: Colors.grey)),
                          Text('SSD: ${build['ssd'] ?? 'Unknown SSD'}', style: const TextStyle(color: Colors.grey)),
                          Text('RAM: ${build['ram'] ?? 'Unknown RAM'}', style: const TextStyle(color: Colors.grey)),
                          Text('GPU: ${build['gpu'] ?? 'Unknown GPU'}', style: const TextStyle(color: Colors.grey)),
                          Text('MB: ${build['motherboard'] ?? 'Unknown Motherboard'}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Delete button (bottom of the card)
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteBuild(buildId, buildImageUrl), // Delete build when icon is pressed
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
