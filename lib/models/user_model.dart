import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final Map<String, CommunityMembership> memberships; // Key: communityId

  AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.memberships,
  });

  // Factory constructor to create a User from a Firestore DocumentSnapshot
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    // Parse the memberships map from Firestore's Map<dynamic, dynamic>
    Map<String, CommunityMembership> membershipsMap = {};
    if (data['memberships'] != null) {
      data['memberships'].forEach((key, value) {
        membershipsMap[key] = CommunityMembership.fromMap(value);
      });
    }

    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      avatarUrl: data['avatarUrl'],
      memberships: membershipsMap,
    );
  }

  // Convert a User to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    // Convert memberships to a map of simple maps
    Map<String, dynamic> membershipsMap = {};
    memberships.forEach((key, value) {
      membershipsMap[key] = value.toMap();
    });

    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'memberships': membershipsMap,
    };
  }
}

class CommunityMembership {
  final bool isMasterAdmin;
  final String customRegistrationId;
  final Map<String, bool> adminRights;
  final List<String> groupIds;
  final Timestamp joinDate;

  CommunityMembership({
    required this.isMasterAdmin,
    required this.customRegistrationId,
    required this.adminRights,
    required this.groupIds,
    required this.joinDate,
  });

  factory CommunityMembership.fromMap(Map<String, dynamic> map) {
    return CommunityMembership(
      isMasterAdmin: map['isMasterAdmin'] ?? false,
      customRegistrationId: map['customRegistrationId'] ?? '',
      adminRights: Map<String, bool>.from(map['adminRights'] ?? {}),
      groupIds: List<String>.from(map['groupIds'] ?? []),
      joinDate: map['joinDate'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isMasterAdmin': isMasterAdmin,
      'customRegistrationId': customRegistrationId,
      'adminRights': adminRights,
      'groupIds': groupIds,
      'joinDate': joinDate,
    };
  }
}
