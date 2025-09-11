import 'package:flutter/material.dart';
import 'package:legacy_lane_fresh/services/auth_service.dart';
import 'package:legacy_lane_fresh/screens/admin_dashboard.dart';
import 'package:legacy_lane_fresh/screens/member_dashboard.dart';

class NavigationUtils {
  static void redirectBasedOnRole(
    BuildContext context,
    String role,
    String communityId,
  ) {
    if (role == 'master_admin' || role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MemberDashboard()),
      );
    }
  }

  static Future<void> redirectAfterAuth(
    BuildContext context,
    String userId,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = AuthService();
      final userData = await authService.getUserData(userId);
      Navigator.pop(context); // Close loading

      if (userData != null) {
        redirectBasedOnRole(context, userData['role'], userData['communityId']);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
