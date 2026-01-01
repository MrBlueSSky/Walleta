import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/appUser.dart';

class AuthProvider extends ChangeNotifier {
  fb.User? firebaseUser;
  AppUser appUser = AppUser.empty;

  AuthProvider() {
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      firebaseUser = user;

      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          appUser = AppUser.fromFirestore(doc.data()!);
        }
      } else {
        appUser = AppUser.empty;
      }

      notifyListeners();
    });
  }
}
