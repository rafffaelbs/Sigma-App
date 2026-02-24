import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // <--- Import the screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MaterialApp(
      // We point to the separated screen file
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
