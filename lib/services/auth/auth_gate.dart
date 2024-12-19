import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_learn/screens/home_page.dart';
import 'package:firebase_learn/services/auth/login_or_signup.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirebaseAuth.instance.currentUser != null
          ? HomePage() // Manually show HomePage if user is logged in
          : const LoginOrSignup(),
    );
  }
}