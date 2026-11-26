import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final uid    = authVM.user?.uid;

    if (uid == null) return const SizedBox.shrink();

    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<UserModel?>(
        stream: firestoreService.streamUser(uid),
        builder: (context, snap) {
          final user = snap.data ?? authVM.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildAvatar(user),
                const SizedBox(height: 24),
                _buildInfoCard(context, user),
                const SizedBox(height: 16),
                _buildStatsCard(user),
                const SizedBox(height: 32),
                _buildLogoutButton(context, authVM),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(UserModel? user) => Column(
    children: [
      Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: Text(
            user?.email.isNotEmpty == true ? user!.email[0].toUpperCase() : 'U',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(user?.email ?? '', style: const TextStyle(color: AppTheme.onBackground, fontSize: 16, fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildInfoCard(BuildContext context, UserModel? user) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        _infoRow(Icons.email_outlined, 'Email', user?.email ?? '—'),
        const Divider(height: 24),
        _infoRow(Icons.badge_outlined, 'Role',
            user?.isAdmin == true ? 'Cafeteria Admin 👑' : 'Student 🎓'),
      ],
    ),
  );

  Widget _buildStatsCard(UserModel? user) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.primary.withValues(alpha: 0.15), AppTheme.accent.withValues(alpha: 0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.receipt_long, color: AppTheme.primary, size: 32),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user?.totalOrders ?? 0}',
                style: const TextStyle(color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.w800)),
            const Text('Total Orders Placed', style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13)),
          ],
        ),
      ],
    ),
  );

  Widget _buildLogoutButton(BuildContext context, AuthViewModel authVM) => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppTheme.error,
      side: const BorderSide(color: AppTheme.error),
    ),
    icon: const Icon(Icons.logout),
    label: const Text('Sign Out'),
    onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Sign out?'),
          content: const Text('You will be redirected to the login screen.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
            ),
          ],
        ),
      );
      if (confirm == true) authVM.signOut();
    },
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, color: AppTheme.onSurfaceDim, size: 20),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.onSurfaceDim, fontSize: 12)),
          Text(value, style: const TextStyle(color: AppTheme.onBackground, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    ],
  );
}
