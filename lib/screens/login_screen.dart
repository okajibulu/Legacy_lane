import 'package:flutter/material.dart';
import 'package:legacy_lane_fresh/services/auth_service.dart';
import 'package:legacy_lane_fresh/utils/navigation_utils.dart';
import 'package:legacy_lane_fresh/screens/landing_page.dart';
import 'package:legacy_lane_fresh/widgets/hover_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  // No hover state variables needed with HoverWidget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Legacy Lane Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to your community',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onChanged: (value) => _email = value,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onChanged: (value) => _password = value,
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: HoverWidget(
                          builder: (isHovered) {
                            return TextButton(
                              onPressed: () {
                                print('Forgot password pressed');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: isHovered
                                    ? Colors.deepPurple[800]
                                    : Colors.deepPurple,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: isHovered
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Login Button with Hover Effect
            HoverWidget(
              builder: (isHovered) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final user = await AuthService().loginWithEmail(
                            _email,
                            _password,
                          );
                          if (user != null) {
                            await NavigationUtils.redirectAfterAuth(
                              context,
                              user.uid,
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHovered
                          ? Colors.deepPurple[700]
                          : Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: isHovered ? 4 : 2,
                      shadowColor: isHovered
                          ? Colors.deepPurple.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                    child: AnimatedScale(
                      scale: isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Or', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Quick access to your existing community',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Google Login Button with Hover Effect
            HoverWidget(
              builder: (isHovered) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final user = await AuthService().loginWithGoogle();
                        if (user != null) {
                          await NavigationUtils.redirectAfterAuth(
                            context,
                            user.uid,
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Google login failed: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: AnimatedScale(
                      scale: isHovered ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text('Login with Google'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isHovered
                          ? Colors.deepPurple
                          : Colors.black,
                      side: BorderSide(
                        color: isHovered ? Colors.deepPurple : Colors.grey,
                        width: isHovered ? 1.5 : 1.0,
                      ),
                      backgroundColor: isHovered
                          ? Colors.deepPurple.withOpacity(0.1)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Signup Link with Hover Effect
            Center(
              child: HoverWidget(
                onTap: () {
                  Navigator.pop(context);
                },
                builder: (isHovered) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? Colors.deepPurple.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: isHovered ? 15 : 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: isHovered
                                  ? Colors.deepPurple[800]
                                  : Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: isHovered ? 15 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Home Link with Hover Effect
            Center(
              child: HoverWidget(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingPage(),
                    ),
                  );
                },
                builder: (isHovered) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          size: 16,
                          color: isHovered ? Colors.deepPurple : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Back to Home',
                          style: TextStyle(
                            color: isHovered ? Colors.deepPurple : Colors.grey,
                            fontWeight: isHovered
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
