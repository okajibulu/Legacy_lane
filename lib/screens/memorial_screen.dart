import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/memorial_card.dart'; // Make sure this file exists

class MemorialScreen extends StatelessWidget {
  const MemorialScreen({super.key});

  // Fetch the theme from Firestore
  Future<String> fetchMemorialTheme() async {
    final doc = await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('settings')
        .doc('memorial')
        .get();

    final data = doc.data();
    return data != null && data.containsKey('theme') ? data['theme'] : 'grid';
  }

  // Fetch members marked as 'memorial'
  Future<List<Map<String, dynamic>>> fetchMemorialMembers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('members')
        .where('status', isEqualTo: 'memorial')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memorial')),
      body: FutureBuilder<String>(
        future: fetchMemorialTheme(),
        builder: (context, themeSnapshot) {
          if (themeSnapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final theme = themeSnapshot.data ?? 'grid';

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchMemorialMembers(),
            builder: (context, memberSnapshot) {
              if (memberSnapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = memberSnapshot.data ?? [];

              if (members.isEmpty) {
                return const Center(child: Text('No memorials yet.'));
              }

              switch (theme) {
                case 'list':
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) =>
                        MemorialCard(member: members[index]),
                  );
                case 'grid':
                default:
                  return GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(8),
                    children: members
                        .map((member) => MemorialCard(member: member))
                        .toList(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
