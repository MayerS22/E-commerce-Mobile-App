import 'package:e_commerce/Screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/HomePage.dart';
import 'Screens/SignInScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => SplashScreen(), // Define splash screen route
        '/home': (context) => HomeScreen(), // Define home screen route
        '/login': (context) => SignInScreen(), // Define login screen route
        // Other routes can go here
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
