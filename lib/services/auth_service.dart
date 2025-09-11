import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

import '../models/user_model.dart';
import '../models/community_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SIGN UP WITH EMAIL - CREATE COMMUNITY
  Future<Map<String, dynamic>?> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String communityName,
    required String communityType,
    String communityDescription = '',
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      // DEBUG: Check if user is properly authenticated
      print('🔥 User UID: ${user.uid}');
      print('🔥 Is user authenticated: ${user.uid != null}');
      print('🔥 Current auth state: ${_auth.currentUser?.uid}');

      // Generate unique community ID
      String communityId = _generateCommunityId(communityName);

      // 1. Get a new batch write object
      final WriteBatch batch = _firestore.batch();

      // 2. Create references to the documents we want to write to
      final DocumentReference communityRef = _firestore
          .collection('communities')
          .doc(communityId);
      final DocumentReference userRef = _firestore
          .collection('users')
          .doc(user.uid);

      // 3. Create the Community object and add it to the batch
      Community newCommunity = Community(
        id: communityId,
        name: communityName,
        description: communityDescription,
        type: communityType,
        ownerUid: user.uid,
        createdAt: Timestamp.now(),
        subscriptionStatus: 'trialing',
        planTier: 'free',
        currentMemberCount: 1,
        maxMemberCount: 5,
        stripeCustomerId: null,
        stripeSubscriptionId: null,
        enabledModules: [],
        registrationIdStyle: 'MEM-{####}',
      );
      batch.set(communityRef, newCommunity.toFirestore());

      // 4. Create the AppUser object and add it to the batch
      // First, create the CommunityMembership for this user
      CommunityMembership masterAdminMembership = CommunityMembership(
        isMasterAdmin: true,
        customRegistrationId: 'TEMP_ID', // Temporary placeholder
        adminRights: {
          'canManageUsers': true,
          'canManageGroups': true,
          'canViewFinance': true,
          'canManageEvents': true,
        },
        groupIds: [],
        joinDate: Timestamp.now(),
      );

      // Now create the AppUser
      AppUser newUser = AppUser(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: null,
        memberships: {communityId: masterAdminMembership},
      );
      batch.set(userRef, newUser.toFirestore());

      // 5. Commit the batch (writes both documents atomically)
      await batch.commit();

      // 6. Now we can generate a custom ID now that the community is guaranteed to exist.
      // We update the user's membership with the final ID.
      String finalId = _generateRegistrationId(
        communityId,
        newCommunity.registrationIdStyle,
      );
      await userRef.update({
        'memberships.$communityId.customRegistrationId': finalId,
      });

      return {
        'userId': user.uid,
        'communityId': communityId,
        'role': 'master_admin',
      };
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore Error during sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // SIGN UP WITH EMAIL - JOIN EXISTING COMMUNITY
  Future<Map<String, dynamic>?> joinCommunityWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String communityId,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = result.user!;

      // Verify community exists and has space
      DocumentSnapshot communityDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .get();

      if (!communityDoc.exists) {
        throw Exception('Community not found. Please check the community ID.');
      }

      Map<String, dynamic> communityData =
          communityDoc.data() as Map<String, dynamic>;
      int memberCount = communityData['memberCount'] ?? 0;
      int maxMembers = communityData['maxMembers'] ?? 5;

      if (memberCount >= maxMembers) {
        throw Exception(
          'This community has reached its maximum member capacity.',
        );
      }

      // Update community member count
      await _firestore.collection('communities').doc(communityId).update({
        'memberCount': memberCount + 1,
      });

      // Create user document with new structure
      CommunityMembership newMemberMembership = CommunityMembership(
        isMasterAdmin: false,
        customRegistrationId: 'TEMP_ID', // Will be updated after creation
        adminRights: {}, // No admin rights for new members
        groupIds: [],
        joinDate: Timestamp.now(),
      );

      AppUser newUser = AppUser(
        uid: user.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        avatarUrl: null,
        memberships: {communityId: newMemberMembership},
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toFirestore());

      // Generate final registration ID
      String finalId = _generateRegistrationId(
        communityId,
        communityData['registrationIdStyle'] ?? 'MEM-{####}',
      );
      await _firestore.collection('users').doc(user.uid).update({
        'memberships.$communityId.customRegistrationId': finalId,
      });

      return {'userId': user.uid, 'communityId': communityId, 'role': 'member'};
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during join',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore Error during join',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during join',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // GOOGLE SIGN IN - CREATE COMMUNITY
  Future<Map<String, dynamic>?> signInWithGoogleCreateCommunity({
    required String communityName,
    required String communityType,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User user = result.user!;

      String communityId = _generateCommunityId(communityName);

      // Use batch write for Google sign-up as well
      final WriteBatch batch = _firestore.batch();
      final DocumentReference communityRef = _firestore
          .collection('communities')
          .doc(communityId);
      final DocumentReference userRef = _firestore
          .collection('users')
          .doc(user.uid);

      Community newCommunity = Community(
        id: communityId,
        name: communityName,
        description: '', // Add description parameter to this function if needed
        type: communityType,
        ownerUid: user.uid,
        createdAt: Timestamp.now(),
        subscriptionStatus: 'trialing',
        planTier: 'free',
        currentMemberCount: 1,
        maxMemberCount: 5,
        stripeCustomerId: null,
        stripeSubscriptionId: null,
        enabledModules: [],
        registrationIdStyle: 'MEM-{####}',
      );
      batch.set(communityRef, newCommunity.toFirestore());

      CommunityMembership masterAdminMembership = CommunityMembership(
        isMasterAdmin: true,
        customRegistrationId: 'TEMP_ID',
        adminRights: {
          'canManageUsers': true,
          'canManageGroups': true,
          'canViewFinance': true,
          'canManageEvents': true,
        },
        groupIds: [],
        joinDate: Timestamp.now(),
      );

      AppUser newUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        firstName: user.displayName?.split(' ').first ?? '',
        lastName: user.displayName?.split(' ').last ?? '',
        avatarUrl: user.photoURL,
        memberships: {communityId: masterAdminMembership},
      );
      batch.set(userRef, newUser.toFirestore());

      await batch.commit();

      String finalId = _generateRegistrationId(
        communityId,
        newCommunity.registrationIdStyle,
      );
      await userRef.update({
        'memberships.$communityId.customRegistrationId': finalId,
      });

      return {
        'userId': user.uid,
        'communityId': communityId,
        'role': 'master_admin',
      };
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during Google sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore Error during Google sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during Google sign-up',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // GOOGLE SIGN IN - JOIN COMMUNITY
  Future<Map<String, dynamic>?> signInWithGoogleJoinCommunity(
    String communityId,
  ) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User user = result.user!;

      DocumentSnapshot communityDoc = await _firestore
          .collection('communities')
          .doc(communityId)
          .get();
      if (!communityDoc.exists) throw Exception('Community not found');

      Map<String, dynamic> communityData =
          communityDoc.data() as Map<String, dynamic>;
      int memberCount = communityData['memberCount'] ?? 0;
      int maxMembers = communityData['maxMembers'] ?? 5;

      if (memberCount >= maxMembers) throw Exception('Community is full');

      await _firestore.collection('communities').doc(communityId).update({
        'memberCount': memberCount + 1,
      });

      CommunityMembership newMemberMembership = CommunityMembership(
        isMasterAdmin: false,
        customRegistrationId: 'TEMP_ID',
        adminRights: {},
        groupIds: [],
        joinDate: Timestamp.now(),
      );

      AppUser newUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        firstName: user.displayName?.split(' ').first ?? '',
        lastName: user.displayName?.split(' ').last ?? '',
        avatarUrl: user.photoURL,
        memberships: {communityId: newMemberMembership},
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(newUser.toFirestore());

      String finalId = _generateRegistrationId(
        communityId,
        communityData['registrationIdStyle'] ?? 'MEM-{####}',
      );
      await _firestore.collection('users').doc(user.uid).update({
        'memberships.$communityId.customRegistrationId': finalId,
      });

      return {'userId': user.uid, 'communityId': communityId, 'role': 'member'};
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during Google join',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore Error during Google join',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during Google join',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // EMAIL LOGIN
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during login',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during login',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // GOOGLE LOGIN (existing users)
  Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during Google login',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during Google login',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during logout',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during logout',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // PASSWORD RESET
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Firebase Auth Error during password reset',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      developer.log(
        'Unexpected error during password reset',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // GET USER DATA
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore Error getting user data',
        error: e,
        stackTrace: StackTrace.current,
      );
      return null;
    } catch (e) {
      developer.log(
        'Unexpected error getting user data',
        error: e,
        stackTrace: StackTrace.current,
      );
      return null;
    }
  }

  // Helper Methods
  String _generateCommunityId(String communityName) {
    return communityName
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]'), '')
            .padRight(3, '0')
            .substring(0, 10) +
        DateTime.now().millisecondsSinceEpoch.toString().substring(9);
  }

  // NEW HELPER: Generate registration ID
  String _generateRegistrationId(String communityId, String stylePattern) {
    String currentYear = DateTime.now().year.toString();
    String randomDigits = (1000 + Random().nextInt(8999)).toString();

    return stylePattern
        .replaceAll('{year}', currentYear)
        .replaceAll('{####}', randomDigits);
  }

  Map<String, dynamic> _getDefaultSettings(String communityType) {
    return {
      'primaryColor': '#6A0DAD',
      'secondaryColor': '#9575CD',
      'terminology': _getDefaultTerminology(communityType),
      'featuresEnabled': {
        'blog': true,
        'events': true,
        'marketplace': false,
        'memorialPage': true,
      },
    };
  }

  Map<String, String> _getDefaultTerminology(String communityType) {
    switch (communityType) {
      case 'Alumni Association':
        return {
          'roots': 'Our Alma Mater',
          'groups': 'Class of',
          'members': 'Alumni',
        };
      case 'Religious Organization':
        return {
          'roots': 'Our Church',
          'groups': 'Ministry',
          'members': 'Congregation',
        };
      case 'Professional Association':
        return {
          'roots': 'Our Profession',
          'groups': 'Department',
          'members': 'Members',
        };
      default:
        return {'roots': 'Our Roots', 'groups': 'Group', 'members': 'Members'};
    }
  }

  // NEW: Firebase Auth Error Handler
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }

  // NEW: Firebase Error Handler (for Firestore and other Firebase services)
  String _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'unavailable':
        return 'The service is currently unavailable. Please try again later.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'deadline-exceeded':
        return 'The operation took too long. Please try again.';
      default:
        return 'A database error occurred: ${e.message}';
    }
  }

  // Get community data
  Future<Map<String, dynamic>?> getCommunityData(String communityId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('communities')
          .doc(communityId)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } on FirebaseException catch (e) {
      developer.log(
        'Firestore Error getting community data',
        error: e,
        stackTrace: StackTrace.current,
      );
      return null;
    } catch (e) {
      developer.log(
        'Unexpected error getting community data',
        error: e,
        stackTrace: StackTrace.current,
      );
      return null;
    }
  }
}
