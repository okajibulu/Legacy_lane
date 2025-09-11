import 'package:flutter/material.dart';

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  static const List<Map<String, String>> _faqItems = [
    {
      'question': 'What types of communities can use Legacy Lane?',
      'answer': 'Legacy Lane works for any community type',
    },
    {
      'question': 'How does the free tier work?',
      'answer': 'First 5 members are free',
    },
    {
      'question': 'Can we customize the terminology?',
      'answer': 'Yes, admins can customize all terms',
    },
    {'question': 'Is our data secure?', 'answer': 'Enterprise-grade security'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ..._faqItems.map(
            (faq) => ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(faq['answer']!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}