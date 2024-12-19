import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_learn/firebase_options.dart';
import 'package:firebase_learn/services/auth/auth_gate.dart';
import 'package:firebase_learn/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightMode,
      darkTheme: AppTheme.darkMode,
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
