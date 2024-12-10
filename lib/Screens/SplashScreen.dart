import 'package:flutter/material.dart';
import 'SignInScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration of the animation
    );

    // Define the fade animation (from 0 to 1)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start the animation
    _animationController.forward();

    // Navigate to SignInScreen after the animation completes
    _navigateToSignIn();
  }

  _navigateToSignIn() async {
    // Wait for 3 seconds before navigating to the SignInScreen
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()), // Navigate to SignInScreen after the delay
    );
  }

  @override
  void dispose() {
    // Dispose the animation controller when no longer needed
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use a Container to apply the gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexaStringToColor("71EEFE"),
              const Color(0xff227B81),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'Goods4You',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to convert hex color string to Color object
  Color hexaStringToColor(String hexCode) {
    final buffer = StringBuffer();
    if (hexCode.length == 6 || hexCode.length == 7) {
      buffer.write('ff'); // Default opacity (ff for fully opaque)
      buffer.write(hexCode.replaceFirst('#', ''));
    } else {
      throw FormatException("Invalid Hex Code Format");
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
