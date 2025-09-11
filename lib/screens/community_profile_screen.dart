import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/tech_stack_viewer.dart';

class CommunityProfileScreen extends StatelessWidget {
  final String communityId;

  const CommunityProfileScreen({required this.communityId, super.key});

  Future<Map<String, dynamic>?> fetchCommunityData() async {
    final doc = await FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community Profile")),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchCommunityData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Community not found"));
          }

          final data = snapshot.data!;
          final name = data['name'] ?? 'Unnamed';
          final description = data['description'] ?? 'No description';
          final avatarUrl = data['avatarUrl'];
          final techStack = data['techStack'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (avatarUrl != null)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(name, style: Theme.of(context).textTheme.titleLarge),

                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 24),
                if (techStack != null)
                  TechStackViewer(techStack: techStack),
                const SizedBox(height: 24),
                // Placeholder for future modules
                Text("🎧 Audio, 🕊️ Memorials, 💰 Donations coming soon...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
