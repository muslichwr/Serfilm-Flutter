import 'package:flutter/material.dart';
import 'package:serfilm/models/user_model.dart';
import 'package:serfilm/pages/sign_in_page.dart';
import 'package:serfilm/theme/app_theme.dart';
import 'package:serfilm/widgets/profile_stats.dart';
import 'package:serfilm/widgets/profile_settings.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement logout logic
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                    (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Jika user null, tampilkan tampilan kosong yang menarik
    if (user.id == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data user',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silakan login atau daftar untuk melihat profil Anda.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigasi ke halaman login
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Login / Daftar'),
            ),
          ],
        ),
      );
    }

    // Data statistik user (dummy)
    final stats = [
      {'icon': Icons.movie, 'label': 'Movies Watched', 'value': '27'},
      {'icon': Icons.star, 'label': 'Reviews Written', 'value': '15'},
      {'icon': Icons.bookmark, 'label': 'Watchlist Items', 'value': '42'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage:
                      user.profilePhotoUrl != null
                          ? NetworkImage(user.profilePhotoUrl!)
                          : null,
                  child:
                      user.profilePhotoUrl == null
                          ? Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats section dipisah ke widget agar lebih rapi
          ProfileStats(stats: stats),
          const SizedBox(height: 24),

          // Settings section dipisah ke widget agar lebih rapi
          const ProfileSettings(),

          // Logout button
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout, size: 20),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
