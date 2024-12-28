import 'dart:developer';
import 'auth/auth_service.dart';
import 'auth/login_page.dart';
import 'widgets/button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Sign Out",
              onPressed: _signOut,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await auth.signout();
      log("User signed out successfully."); // Logging the success message
      if (mounted) {
        goToLogin(context);
      }
    } catch (e) {
      log("Sign-out error: $e", level: 1000); // Use a higher log level for errors
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}