import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String type;
  final String ownerUid;
  final Timestamp createdAt;
  final String subscriptionStatus;
  final String planTier;
  final int currentMemberCount;
  final int maxMemberCount;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final List<String> enabledModules;
  final String registrationIdStyle;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.ownerUid,
    required this.createdAt,
    required this.subscriptionStatus,
    required this.planTier,
    required this.currentMemberCount,
    required this.maxMemberCount,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    required this.enabledModules,
    required this.registrationIdStyle,
  });

  // Add the 'factory' keyword here
  factory Community.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Community(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      subscriptionStatus: data['subscriptionStatus'] ?? 'inactive',
      planTier: data['planTier'] ?? 'free',
      currentMemberCount: data['currentMemberCount'] ?? 0,
      maxMemberCount: data['maxMemberCount'] ?? 5,
      stripeCustomerId: data['stripeCustomerId'],
      stripeSubscriptionId: data['stripeSubscriptionId'],
      enabledModules: List<String>.from(data['enabledModules'] ?? []),
      registrationIdStyle: data['registrationIdStyle'] ?? 'MEM-{####}',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'ownerUid': ownerUid,
      'createdAt': createdAt,
      'subscriptionStatus': subscriptionStatus,
      'planTier': planTier,
      'currentMemberCount': currentMemberCount,
      'maxMemberCount': maxMemberCount,
      'stripeCustomerId': stripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId,
      'enabledModules': enabledModules,
      'registrationIdStyle': registrationIdStyle,
    };
  }
}
