import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userDetails;

  Map<String, dynamic>? get userDetails => _userDetails;

  Future<void> loadUserDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _userDetails = userDoc.data() as Map<String, dynamic>?;
      notifyListeners();
    }
  }

  void setUserDetails(Map<String, dynamic> details) {
    _userDetails = details;
    notifyListeners();
  }

  Future<void> updateUserDetails(Map<String, dynamic> newDetails) async {
    _userDetails = newDetails;
    notifyListeners();
  }
}
