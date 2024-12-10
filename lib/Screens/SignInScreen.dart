import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MainScreen.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool _isPasswordVisible = false;
  bool _rememberMe = false; // Remember me flag

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials(); // Load saved credentials on screen load
  }

  // Load credentials from SharedPreferences
  _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      String? savedEmail = prefs.getString('email');
      String? savedPassword = prefs.getString('password');
      if (savedEmail != null && savedPassword != null) {
        emailcontroller.text = savedEmail;
        passcontroller.text = savedPassword;
        _rememberMe = true;
      }
    }
    setState(() {});
  }

  // Save credentials in SharedPreferences
  _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setBool('rememberMe', true);
      prefs.setString('email', emailcontroller.text.trim());
      prefs.setString('password', passcontroller.text.trim());
    } else {
      prefs.setBool('rememberMe', false);
      prefs.remove('email');
      prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [hexaStringToColor("71EEFE"), Color(0xff227B81)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 125, 20, 0),
              child: Column(
                children: <Widget>[
                  logoWidget("assets/Images/avatar.png"),
                  const SizedBox(height: 60),
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Email must not be null";
                      }
                      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextFormField(
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return "Password must not be null";
                        }
                        return null;
                      },
                      controller: passcontroller,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        prefixIcon: Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      const Text("Remember Me")
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: signin,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                  color: Color(0xff227B81),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Add Forgot Password link
                  TextButton(
                    onPressed: () => _forgotPassword(),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signin() async {
    if (formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // Sign in the user with Firebase Authentication
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passcontroller.text.trim(),
        );

        // Save credentials if "Remember Me" is selected
        _saveCredentials();

        // Pop the loading dialog and navigate to MainScreen
        Navigator.pop(context);  // Dismiss the dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);  // Close the loading dialog

        // Handle error based on the error code
        String message = '';
        switch (e.code) {
          case 'user-not-found':
            message = "No user found for this email.";
            break;
          case 'wrong-password':
            message = "Incorrect password.";
            break;
          case 'invalid-email':
            message = "Invalid email address.";
            break;
          default:
            message = "An error occurred. Please try again.";
        }

        // Show the error in an AlertDialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Function to handle Forgot Password
  Future<void> _forgotPassword() async {
    String email = emailcontroller.text.trim();

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Please enter your email address."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Password Reset"),
            content: Text("Password reset email has been sent! Please check your inbox."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        message = "No user found for this email address.";
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
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

  // Function to show logo from an asset path
  Widget logoWidget(String imagePath) {
    return Center(
      child: Image.asset(
        imagePath,
        height: 120, // Adjust the height as needed
        width: 120,  // Adjust the width as needed
      ),
    );
  }
}
