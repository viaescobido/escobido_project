
import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  static const purple = Color(0xFF6941C6);
  static const darkPurple = Color(0xFF35245E);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    final emailPattern =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      showMessage('Please enter a valid email address.');
      return;
    }

    // DEMO ONLY:
    // This does not verify a real account.
    // Connect your authentication API later.

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          userEmail: email,
          isGuest: false,
        ),
      ),
    );
  }

  void continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(
          isGuest: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: purple,
                          size: 76,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'ParkKeys',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: purple,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Your ride, your route.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Login to continue your journey.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    controller: emailController,
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    controller: passwordController,
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      tooltip: hidePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  AppButton(
                    text: 'Login',
                    onPressed: login,
                  ),

                  const SizedBox(height: 18),

                  const Center(
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  AppButton(
                    text: 'Continue as Guest',
                    isOutlined: true,
                    onPressed: continueAsGuest,
                  ),

                  const SizedBox(height: 26),

                  const Center(
                    child: Text(
                      'ParkKeys • Community Transportation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
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
}
