import 'package:flutter/material.dart';

class MemorialCard extends StatelessWidget {
  final Map<String, dynamic> member;

  const MemorialCard({required this.member, super.key});

  @override
  Widget build(BuildContext context) {
    final name = member['name'] ?? 'Unnamed';
    final avatarUrl = member['avatarUrl'];
    final passedOn = member['passedOn'] ?? 'Date unknown';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (avatarUrl != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(avatarUrl),
              )
            else
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Passed on: $passedOn",
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Yearbook Profile
              },
              child: const Text("View Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
