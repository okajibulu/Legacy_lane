import 'community_profile_screen.dart'; // Adjust path if needed
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/parser_service.dart';
import '../widgets/tech_stack_viewer.dart'; // Make sure this file exists

class GroupHomeScreen extends StatefulWidget {
  const GroupHomeScreen({super.key});

  @override
  State<GroupHomeScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<GroupHomeScreen> {

  late Future<List<ParsedFile>> parsedFilesFuture;
  late Future<Map<String, dynamic>?> techStackFuture;

  final parserService = ParserService();

  @override
  void initState() {
    super.initState();
    parsedFilesFuture = parserService.fetchParsedFiles();
    techStackFuture = fetchTechStack();
  }

  Future<Map<String, dynamic>?> fetchTechStack() async {
    final doc = await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001') // Replace with your actual document ID
        .get();

    return doc.data()?['techStack'];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Parsed Dart Files'),
              Tab(text: 'Tech Stack'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Parsed Dart Files
            FutureBuilder<List<ParsedFile>>(
              future: parsedFilesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Dart files found.'));
                } ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityProfileScreen(communityId: 'legacy_lane_001'),
      ),
    );
  },
  child: Text("View Community Profile"),
);


                final files = snapshot.data!;
                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ExpansionTile(
                      title: Text(file.filename),
                      subtitle: Text(file.filepath),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(file.content),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Tab 2: Tech Stack Viewer
            FutureBuilder<Map<String, dynamic>?>(
              future: techStackFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('No tech stack found.'));
                }

                return TechStackViewer(techStack: snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
