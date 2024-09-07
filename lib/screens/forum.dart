import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showReplyDialog(DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reply to Post"),
          content: TextField(
            controller: _replyController,
            decoration: const InputDecoration(hintText: "Write your reply here..."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Reply"),
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final userDetails = userProvider.userDetails;

                if (userDetails != null) {
                  await FirebaseFirestore.instance.collection('posts').doc(post.id).collection('replies').add({
                    'content': _replyController.text,
                    'userId': userDetails['uid'] ?? 'unknown_user',
                    'timestamp': Timestamp.now(),
                    'username': '${userDetails['firstName'] ?? 'Unknown'} ${userDetails['lastName'] ?? 'User'}',
                    'location': userDetails['location'] ?? 'Unknown Location',
                    // Bypass Firebase Storage by using a hardcoded image
                    'profileImageUrl': 'assets/images/profile.png',
                  });
                }
                _replyController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDetails = userProvider.userDetails;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/forum_background.png'),
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
                      "Communities",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0), // Adjusted padding for content spacing
                    child: Row(
                      children: <Widget>[
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/profile.png'),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _postController,
                            decoration: InputDecoration(
                              hintText: 'Write your post here...',
                              hintStyle: const TextStyle(color: Colors.white), // White text color
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.54),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (userDetails != null) {
                          await FirebaseFirestore.instance.collection('posts').add({
                            'content': _postController.text,
                            'userId': userDetails['uid'] ?? 'unknown_user',
                            'timestamp': Timestamp.now(),
                            'username': '${userDetails['firstName'] ?? 'Unknown'} ${userDetails['lastName'] ?? 'User'}',
                            'location': userDetails['location'] ?? 'Unknown Location',
                            // Bypass Firebase Storage by using a hardcoded image
                            'profileImageUrl': 'assets/images/profile.png',
                            'type': 'post',
                          });
                          _postController.clear();
                        }
                      },
                      child: const Text('Publish Post'),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching posts', style: TextStyle(color: Colors.white)));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildNoPostsView();
                      } else {
                        return _buildPostsListView(snapshot.data!.docs);
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

  Widget _buildNoPostsView() {
    return Center(
      child: Column(
        children: [
          const Text(
            "No posts available",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Add action to create a new post
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Create New Post",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsListView(List<QueryDocumentSnapshot> posts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        var postData = post.data() as Map<String, dynamic>;
        var timestamp = postData['timestamp'] as Timestamp;
        var dateTime = timestamp.toDate();
        var formattedTime = DateFormat('hh:mm a').format(dateTime);
        var formattedDate = DateFormat('dd.MM.yyyy').format(dateTime);

        return Card(
          color: Colors.black.withOpacity(0.54),
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                    const SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          postData.containsKey('username') ? postData['username'] : 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          postData.containsKey('location') ? postData['location'] : 'Unknown Location',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Row(
                          children: [
                            Text(
                              'Posted at $formattedTime',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Text(
                  postData.containsKey('content') ? postData['content'] : '',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16.0),
                if (postData['type'] == 'post')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          _showReplyDialog(post);
                        },
                        child: const Text(
                          'Reply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                StreamBuilder<QuerySnapshot>(
                  stream: post.reference.collection('replies').orderBy('timestamp', descending: false).snapshots(),
                  builder: (context, replySnapshot) {
                    if (!replySnapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    var replies = replySnapshot.data?.docs ?? [];
                    return Column(
                      children: replies.map((reply) {
                        var replyData = reply.data() as Map<String, dynamic>;
                        var replyTimestamp = replyData['timestamp'] as Timestamp;
                        var replyDateTime = replyTimestamp.toDate();
                        var replyFormattedTime = DateFormat('hh:mm a').format(replyDateTime);
                        var replyFormattedDate = DateFormat('dd.MM.yyyy').format(replyDateTime);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 0, 8.0),
                          child: Card(
                            color: Colors.black.withOpacity(0.34),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      const CircleAvatar(
                                        backgroundImage: AssetImage('assets/images/profile.png'),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            replyData.containsKey('username') ? replyData['username'] : 'Unknown User',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          Text(
                                            replyData.containsKey('location') ? replyData['location'] : 'Unknown Location',
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Replied at $replyFormattedTime',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              const SizedBox(width: 4.0),
                                              Text(
                                                replyFormattedDate,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    replyData.containsKey('content') ? replyData['content'] : '',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
