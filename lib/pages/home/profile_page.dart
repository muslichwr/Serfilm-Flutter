import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            floating: false,
            elevation: 0,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withOpacity(0.5),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                  // Profile image and info
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 60,
                      top: 30,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://cdn-icons-png.flaticon.com/512/9582/9582626.png',
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                      size: 40,
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.textSecondary,
                                      size: 40,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Pengguna',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bergabung sejak Januari 2023',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(),
                  const SizedBox(height: 30),
                  _buildSettingsSection(),
                  const SizedBox(height: 30),
                  _buildAccountSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Statistik pengguna
  Widget _buildStatsSection() {
    // Buat widget stat item terlebih dahulu
    final List<Widget> statItems = [
      _buildStatItem(
        icon: Icons.movie_outlined,
        title: 'Ditonton',
        value: '36',
        color: AppColors.primary,
      ),
      _buildStatItem(
        icon: Icons.bookmarks_outlined,
        title: 'Watchlist',
        value: '24',
        color: AppColors.accent,
      ),
      _buildStatItem(
        icon: Icons.reviews_outlined,
        title: 'Ulasan',
        value: '12',
        color: Colors.orangeAccent,
      ),
    ];

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik',
            style: AppTextStyles.heading.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder:
                  (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
              children: statItems,
            ),
          ),
        ],
      ),
    );
  }

  // Item statistik
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    // Buat content widget terlebih dahulu
    Widget content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    // Bungkus dengan Expanded di luar
    return Expanded(child: content);
  }

  // Pengaturan aplikasi
  Widget _buildSettingsSection() {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Aplikasi',
            style: AppTextStyles.heading.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder:
                  (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
              children: [
                _buildSettingItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tema Gelap',
                  description: 'Aktif',
                  iconColor: AppColors.accent,
                ),
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  description: 'Film Baru, Ulasan',
                  iconColor: Colors.orangeAccent,
                ),
                _buildSettingItem(
                  icon: Icons.language_outlined,
                  title: 'Bahasa',
                  description: 'Indonesia',
                  iconColor: Colors.greenAccent,
                ),
                _buildSettingItem(
                  icon: Icons.play_arrow_outlined,
                  title: 'Pemutaran Video',
                  description: 'HD saat Wi-Fi',
                  iconColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Item pengaturan
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bagian akun
  Widget _buildAccountSection() {
    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Akun', style: AppTextStyles.heading.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder:
                  (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
              children: [
                _buildAccountItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  iconColor: AppColors.primary,
                ),
                _buildAccountItem(
                  icon: Icons.lock_outline,
                  title: 'Ubah Password',
                  iconColor: Colors.blueAccent,
                ),
                _buildAccountItem(
                  icon: Icons.help_outline,
                  title: 'Bantuan & Dukungan',
                  iconColor: Colors.purpleAccent,
                ),
                _buildAccountItem(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  iconColor: Colors.teal,
                ),
                _buildAccountItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  iconColor: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Item akun
  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
