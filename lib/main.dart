import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import the package
import 'screens/home_screen.dart'; // <--- Import the screen


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  await Firebase.initializeApp();
  runApp(
    const MaterialApp(home: HomeScreen(), debugShowCheckedModeBanner: false),
  );
}
