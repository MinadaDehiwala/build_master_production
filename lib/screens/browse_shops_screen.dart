import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowseShopsPage extends StatefulWidget {
  const BrowseShopsPage({super.key});

  @override
  _BrowseShopsPageState createState() => _BrowseShopsPageState();
}

class _BrowseShopsPageState extends State<BrowseShopsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/forum_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF20232D),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Navigate back when the button is pressed
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Browse Shops',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Shops List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('shops').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final shops = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: shops.length,
                        itemBuilder: (context, index) {
                          var shop = shops[index];
                          var shopName = shop['name'];
                          var shopNumber = shop['number'];
                          var shopWebsite = shop['website'];
                          var shopLocation = shop['location'];

                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      // Call Icon
                                      IconButton(
                                        icon: const Icon(Icons.phone, color: Colors.white),
                                        onPressed: () => _launchPhone(shopNumber),
                                      ),
                                      // Message Icon
                                      IconButton(
                                        icon: const Icon(Icons.message, color: Colors.white),
                                        onPressed: () => _launchMessage(shopNumber),
                                      ),
                                      // Web Icon
                                      IconButton(
                                        icon: const Icon(Icons.web, color: Colors.white),
                                        onPressed: () => _launchWebsite(shopWebsite),
                                      ),
                                      // Map Icon
                                      IconButton(
                                        icon: const Icon(Icons.map, color: Colors.white),
                                        onPressed: () => _launchMap(shopLocation),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch $phoneUri');
    }
  }

  void _launchMessage(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      print('Could not launch $smsUri');
    }
  }

  void _launchWebsite(String url) async {
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    } else {
      print('Could not launch $url');
    }
  }

  void _launchMap(List<dynamic> location) async {
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${location[0]},${location[1]}');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      print('Could not launch Google Maps with $location');
    }
  }
}
