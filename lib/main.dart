import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // <--- Import the screen

void main() {
  runApp(
    const MaterialApp(
      // We point to the separated screen file
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
