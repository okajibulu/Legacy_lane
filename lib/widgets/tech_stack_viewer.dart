import 'package:flutter/material.dart';

class TechStackViewer extends StatelessWidget {
  final Map<String, dynamic> techStack;

  const TechStackViewer({required this.techStack, super.key});

  @override
  Widget build(BuildContext context) {
    final runtimeDeps = techStack['dependencies'] ?? [];
    final devDeps = techStack['devDependencies'] ?? [];
    final assets = techStack['assets'] ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("🔧 Tech Stack", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        const SizedBox(height: 10),
        Text("Runtime Dependencies (${runtimeDeps.length})"),
        ...runtimeDeps.map<Widget>((dep) => Text("- ${dep['name']} v${dep['resolved_version']}")).toList(),

        const SizedBox(height: 20),
        Text("Dev Dependencies (${devDeps.length})"),
        ...devDeps.map<Widget>((dep) => Text("- ${dep['name']} v${dep['resolved_version']}")).toList(),

        const SizedBox(height: 20),
        Text("Assets"),
        if (assets['images'] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🖼️ Images"),
              ...assets['images'].map<Widget>((img) => Text("- $img")).toList(),
            ],
          ),
        if (assets['icons'] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🎯 Icons"),
              ...assets['icons'].map<Widget>((icon) => Text("- $icon")).toList(),
            ],
          ),
      ],
    );
  }
}
