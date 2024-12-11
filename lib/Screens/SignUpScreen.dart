import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignInScreen.dart'; // Make sure to import the SignInScreen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passcontroller = TextEditingController();
  TextEditingController confirmpasscontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF22223B),
                  Color(0xFF4A4E69),
                  Color(0xFF9A8C98),
                  Color(0xFFC9ADA7),
                  Color(0xFFF2E9E4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Form Container
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Color(0xFFF2E9E4),
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildTextField(
                          controller: namecontroller,
                          label: "Full Name",
                          hint: "Enter your name",
                          icon: Icons.person,
                          validator: (value) {
                            if (value!.isEmpty) return "Name must not be null";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: emailcontroller,
                          label: "Email Address",
                          hint: "Enter your email",
                          icon: Icons.email,
                          validator: (value) {
                            if (value!.isEmpty) return "Email must not be null";
                            if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                .hasMatch(value)) {
                              return "Please enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: passcontroller,
                          label: "Password",
                          hint: "Enter your password",
                          icon: Icons.lock,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) return "Password must not be null";
                            if (value.length < 6) return "Password must be at least 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: confirmpasscontroller,
                          label: "Confirm Password",
                          hint: "Re-enter your password",
                          icon: Icons.lock,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) return "Please confirm your password";
                            if (value != passcontroller.text) return "Passwords do not match";
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: const Color(0xFF22223B),
                            ),
                            onPressed: signup,
                            child: const Text(
                              "Register Account",
                              style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(children: [
                              TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(color: Color(0xFF22223B), fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    void Function()? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF22223B)),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF22223B),
          ),
          onPressed: onToggleVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF22223B)),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  void signup() async {
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
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailcontroller.text.trim(),
          password: passcontroller.text.trim(),
        );

        Navigator.pop(context); // Dismiss loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // Close the dialog
        String message = '';
        switch (e.code) {
          case 'email-already-in-use':
            message = "This email is already in use. Please use a different email.";
            break;
          case 'weak-password':
            message = "Password is too weak.";
            break;
          default:
            message = "An error occurred. Please try again.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }
}
