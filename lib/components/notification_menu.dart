import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showNotificationsMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, // Set background to transparent
    builder: (BuildContext context) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6), // Background color with opacity
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: <Widget>[
            const ListTile(
              title: Text('Notifications', style: TextStyle(color: Colors.white)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var notifications = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      return ListTile(
                        title: Text(notification['title'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(notification['body'], style: const TextStyle(color: Colors.white70)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
