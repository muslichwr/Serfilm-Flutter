import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final List<Map<String, dynamic>> _genreList = [
    {'name': 'Aksi', 'icon': Icons.local_fire_department},
    {'name': 'Petualangan', 'icon': Icons.explore},
    {'name': 'Animasi', 'icon': Icons.movie_creation},
    {'name': 'Komedi', 'icon': Icons.sentiment_very_satisfied},
    {'name': 'Kriminal', 'icon': Icons.gavel},
    {'name': 'Dokumenter', 'icon': Icons.video_camera_back},
    {'name': 'Drama', 'icon': Icons.theater_comedy},
    {'name': 'Keluarga', 'icon': Icons.family_restroom},
    {'name': 'Fantasi', 'icon': Icons.auto_awesome},
    {'name': 'Sejarah', 'icon': Icons.history_edu},
    {'name': 'Horor', 'icon': Icons.sentiment_very_dissatisfied},
    {'name': 'Musik', 'icon': Icons.music_note},
    {'name': 'Misteri', 'icon': Icons.help_outline},
    {'name': 'Romansa', 'icon': Icons.favorite},
    {'name': 'Fiksi Ilmiah', 'icon': Icons.rocket_launch},
    {'name': 'Thriller', 'icon': Icons.psychology},
    {'name': 'Perang', 'icon': Icons.brightness_7},
    {'name': 'Western', 'icon': Icons.terrain},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.background,
            title: Text(
              'Eksplorasi',
              style: AppTextStyles.heading.copyWith(fontSize: 20),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  top: 80,
                ),
                child: Text(
                  'Jelajahi film berdasarkan genre yang kamu suka',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.accent),
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: _buildGenreCard(
                        _genreList[index]['name'],
                        _genreList[index]['icon'],
                      ),
                    ),
                  ),
                );
              }, childCount: _genreList.length),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Berdasarkan Negara',
                    style: AppTextStyles.heading.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  _buildCountriesList(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreCard(String name, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountriesList() {
    final List<Map<String, dynamic>> countries = [
      {
        'name': 'Korea Selatan',
        'flag': 'https://via.placeholder.com/40x40.png?text=KR',
      },
      {
        'name': 'Jepang',
        'flag': 'https://via.placeholder.com/40x40.png?text=JP',
      },
      {
        'name': 'Amerika Serikat',
        'flag': 'https://via.placeholder.com/40x40.png?text=US',
      },
      {
        'name': 'Indonesia',
        'flag': 'https://via.placeholder.com/40x40.png?text=ID',
      },
      {
        'name': 'India',
        'flag': 'https://via.placeholder.com/40x40.png?text=IN',
      },
    ];

    return Column(
      children:
          countries.map((country) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: country['flag'],
                            width: 32,
                            height: 24,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => Container(
                                  width: 32,
                                  height: 24,
                                  color: AppColors.textFieldBg,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(country['name'], style: AppTextStyles.body),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
