import 'package:flutter/material.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          const Text(
            'Simple, Transparent Pricing',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Start free, grow as you need. No hidden fees.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _buildPricingCard(
                'Free',
                '\$0',
                'Perfect for small communities',
                [
                  'First 5 members free',
                  'Basic features',
                  '1 GB storage',
                  'Community support',
                ],
              ),
              _buildPricingCard(
                'Growth',
                '\$10/year',
                'For growing communities',
                [
                  '+\$2 per additional member',
                  'All features',
                  '10 GB storage',
                  'Priority support',
                ],
                isFeatured: true,
              ),
              _buildPricingCard(
                'Enterprise',
                'Custom',
                'Large organizations',
                [
                  'Unlimited members',
                  'Advanced analytics',
                  'Custom branding',
                  'Dedicated support',
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    String plan,
    String price,
    String description,
    List<String> features, {
    bool isFeatured = false,
  }) {
    return Card(
      elevation: isFeatured ? 8 : 2,
      color: isFeatured ? Colors.deepPurple : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              plan,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isFeatured ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              price,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isFeatured ? Colors.white : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: isFeatured ? Colors.white70 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isFeatured ? Colors.white : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: isFeatured ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isFeatured ? Colors.white : Colors.deepPurple,
                foregroundColor: isFeatured ? Colors.deepPurple : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Get Started', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}