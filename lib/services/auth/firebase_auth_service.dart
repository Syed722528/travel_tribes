import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/screens/home_page.dart';
import 'package:firebase_learn/services/auth/login_or_signup.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  //------------------------------Creating User-----------------------------//
  Future<User?> signUpWithEmailAndPassword(String email, String password,
      String userName, BuildContext context) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Save user data in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set(
        {
          'username': userName,
          'email': email,
          'phone': null,
          'bio': null,
          'createdat': DateTime.now(),
          'uid': credential.user!.uid,
          'profilepic': null,
          'fcmToken': null,  // Initial token field
        },
      );

      // Get FCM token after user sign-up
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set(
          {'fcmToken': fcmToken},
          SetOptions(merge: true),
        );
        print('FCM Token saved: $fcmToken');
      }

      User? user = _auth.currentUser;
      await user!.sendEmailVerification();
      _showSnackBar(context, 'Verification email has been sent');

      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginOrSignup()));

      return credential.user;
    } catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e);
      _showSnackBar(context, errorMessage);
    }
    return null;
  }

  //------------------------------Sign in User-----------------------------//
  Future<Object?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = _auth.currentUser;

      if (user!.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        await FirebaseAuth.instance.signOut();
        _showSnackBar(context, 'Please verify your email to continue');
      }

      // Get FCM token
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        // Save the FCM token in Firestore under the user's document
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'fcmToken': fcmToken,
        }, SetOptions(merge: true)); // Merge ensures we don't overwrite existing data
        print('FCM Token saved: $fcmToken');
      } else {
        print('Failed to get FCM Token');
      }

      return credential.user;
    } catch (e) {
      String errorMessage = _getFirebaseSignInErrorMessage(e);
      _showSnackBar(context, errorMessage);
    }
    return null;
  }

  //------------------------------Error Handling-----------------------------//
  String _getFirebaseAuthErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is invalid.';
        default:
          return 'An error occurred. Please try again.';
      }
    } else {
      return 'An unexpected error occurred.';
    }
  }

  String _getFirebaseSignInErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
          return 'Email or Password is Incorrect';
        default:
          return 'An error occurred. Please try again.';
      }
    } else {
      return 'An unexpected error occurred.';
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      content: Text(message),
    ));
  }
}
