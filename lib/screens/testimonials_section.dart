import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          const Text(
            'Trusted by Communities Worldwide',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildTestimonialCard(
                'Harvard Alumni Association',
                '"Legacy Lane transformed how we connect 400,000+ alumni across generations."',
                'Sarah Chen, Alumni Director',
              ),
              _buildTestimonialCard(
                'St. Theresa\'s College',
                '"Finally, a platform that understands the needs of educational institutions."',
                'Fr. Michael O\'Connor, Principal',
              ),
              _buildTestimonialCard(
                'Tech Professionals Network',
                '"The professional directory features helped our members connect meaningfully."',
                'David Kim, Community Manager',
              ),
            ],
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
}