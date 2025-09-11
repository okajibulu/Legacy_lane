import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../widgets/tribute_form.dart';

class YearbookProfileScreen extends StatefulWidget {
  final String memberId;

  const YearbookProfileScreen({required this.memberId, super.key});

  @override
  State<YearbookProfileScreen> createState() => _YearbookProfileScreenState();
}

class _YearbookProfileScreenState extends State<YearbookProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  List<DocumentSnapshot> _tributeDocs = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
    _loadInitialTributes();
  }

  @override
  void dispose() {
    _player.closePlayer();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> fetchMemberData() async {
    final doc = await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('members')
        .doc(widget.memberId)
        .get();

    return doc.data();
  }

  Future<void> _loadInitialTributes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('members')
        .doc(widget.memberId)
        .collection('tributes')
        .orderBy('createdAt', descending: true)
        .limit(_pageSize)
        .get();

    setState(() {
      _tributeDocs = snapshot.docs;
      _hasMore = snapshot.docs.length == _pageSize;
    });
  }

  Future<void> _loadMoreTributes() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final lastDoc = _tributeDocs.last;
    final snapshot = await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('members')
        .doc(widget.memberId)
        .collection('tributes')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(_pageSize)
        .get();

    setState(() {
      _tributeDocs.addAll(snapshot.docs);
      _hasMore = snapshot.docs.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void reactToTribute(String tributeId, String type) async {
    final ref = FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('members')
        .doc(widget.memberId)
        .collection('tributes')
        .doc(tributeId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(ref);
      final data = snapshot.data();
      final current = data?['reactions']?[type] ?? 0;
      tx.update(ref, {
        'reactions.$type': current + 1,
      });
    });
  }

  Widget buildReactionRow(String tributeId, Map<String, dynamic>? reactions) {
    final heart = reactions?['heart'] ?? 0;
    final pray = reactions?['pray'] ?? 0;
    final star = reactions?['star'] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: () => reactToTribute(tributeId, 'heart'),
          icon: const Icon(Icons.favorite, color: Colors.pink),
          label: Text('$heart'),
        ),
        TextButton.icon(
          onPressed: () => reactToTribute(tributeId, 'pray'),
          icon: const Icon(Icons.volunteer_activism, color: Colors.blue),
          label: Text('$pray'),
        ),
        TextButton.icon(
          onPressed: () => reactToTribute(tributeId, 'star'),
          icon: const Icon(Icons.star, color: Colors.orange),
          label: Text('$star'),
        ),
      ],
    );
  }

  int totalReactions(Map<String, dynamic>? reactions) {
    if (reactions == null) return 0;
    return (reactions['heart'] ?? 0) +
           (reactions['pray'] ?? 0) +
           (reactions['star'] ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yearbook Profile')),
      floatingActionButton: FloatingActionButton(
        onPressed: scrollToTop,
        child: const Icon(Icons.arrow_upward),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchMemberData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final member = snapshot.data!;
          final name = member['name'] ?? 'Unnamed';
          final avatarUrl = member['avatarUrl'];
          final bio = member['bio'] ?? '';
          final passedOn = member['passedOn'] ?? 'Date unknown';

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (avatarUrl != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(avatarUrl),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text("Passed on: $passedOn", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Text(bio, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                TributeForm(memberId: widget.memberId),
                const SizedBox(height: 24),
                const Text('Tributes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Column(
                  children: _tributeDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final text = data['text'] ?? '';
                    final createdBy = data['createdBy'] ?? 'Anonymous';
                    final createdAt = data['createdAt'] as Timestamp?;
                    final photoUrl = data['photoUrl'];
                    final voiceUrl = data['voiceUrl'];
                    final reactions = data['reactions'];
                    final isPrivate = data['isPrivate'] ?? false;
                    final date = createdAt != null
                        ? createdAt.toDate().toLocal().toString().split(' ')[0]
                        : 'Unknown date';

                    if (isPrivate) return const SizedBox.shrink(); // hide if private

                    final total = totalReactions(reactions);
                    final isMostLoved = total > 5; // arbitrary threshold

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (photoUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photoUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Text(text, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 6),
                            Text('By $createdBy on $date',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            if (isMostLoved)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text('🌟 Most Loved Tribute',
                                    style: TextStyle(color: Colors.orange)),
                              ),
                            buildReactionRow(doc.id, reactions),
                            if (voiceUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (_player