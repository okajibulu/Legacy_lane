import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'features_section.dart';
import 'pricing_section.dart';
import 'faq_section.dart';
import 'footer_section.dart';
import 'hero_section.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  void _testFirebaseConnection() async {
    try {
      final auth = FirebaseAuth.instance;
      print('🔥 Firebase Project: ${auth.app.options.projectId}');
      print('✅ Successfully connected to Legacy-Lane-DS-FB!');

      // Test Firestore connection too
      final firestore = FirebaseFirestore.instance;
      print('📊 Firestore initialized: ${firestore.app.name}');
    } catch (e) {
      print('❌ Firebase connection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            HeroSection(),

            // Features Section
            FeaturesSection(),

            // Testimonials Section
            _buildTestimonialsSection(),

            // Pricing Section
            PricingSection(),

            // FAQ Section
            FAQSection(),

            // Footer with CTA
            FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          Text(
            'Trusted by Communities Worldwide',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),

          // Responsive testimonials
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTestimonialCard(
                        'Harvard Alumni Association',
                        '"Legacy Lane transformed how we connect 400,000+ alumni across generations."',
                        'Sarah Chen, Alumni Director',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTestimonialCard(
                        'St. Theresa\'s College',
                        '"Finally, a platform that understands the needs of educational institutions."',
                        'Fr. Michael O\'Connor, Principal',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTestimonialCard(
                        'Tech Professionals Network',
                        '"The professional directory features helped our members connect meaningfully."',
                        'David Kim, Community Manager',
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTestimonialCard(
                      'Harvard Alumni Association',
                      '"Legacy Lane transformed how we connect 400,000+ alumni across generations."',
                      'Sarah Chen, Alumni Director',
                    ),
                    const SizedBox(height: 24),
                    _buildTestimonialCard(
                      'St. Theresa\'s College',
                      '"Finally, a platform that understands the needs of educational institutions."',
                      'Fr. Michael O\'Connor, Principal',
                    ),
                    const SizedBox(height: 24),
                    _buildTestimonialCard(
                      'Tech Professionals Network',
                      '"The professional directory features helped our members connect meaningfully."',
                      'David Kim, Community Manager',
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
    String organization,
    String quote,
    String author,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              organization,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quote,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Text(
              author,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      color: Colors.deepPurple[900],
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'Ready to Build Your Community\'s Legacy?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Join thousands of communities preserving their stories and connections',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Start Your Free Community'),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          const Text(
            '© 2024 Legacy Lane. All rights reserved.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
