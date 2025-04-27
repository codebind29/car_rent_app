import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Fetch user data from Firestore based on the logged-in user's UID
  Future<Map<String, dynamic>> getUserData() async {
    User? user = _auth.currentUser;
    Map<String, dynamic> userData = {};

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(
            user.uid).get();
        userData = userDoc.data() as Map<String, dynamic>;
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user data: $e");
        }
      }
    }
    return userData;
  }

  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
    required int phno,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          name.isNotEmpty ||
          phno != null) {
        // register user in auth with email and password
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // add user to your  firestore database
        if (kDebugMode) {
          print(cred.user!.uid);
        }
        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
          'phno': phno,
        });

        res = "success";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

// logIn user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

// for sighout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error during sign-out: $e");
      }
      // Optionally, handle the error, e.g., show an error message
    }
  }
/*signOut() async {
   await _auth.signOut();
}
}*/
}
