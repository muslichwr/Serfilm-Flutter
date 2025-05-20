import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Ditonton', 'Favorit', 'Menonton', 'Nanti'];

  // Data film watchlist
  final List<Map<String, dynamic>> _watchlistFilms = [
    {
      'title': 'Oppenheimer',
      'poster': 'https://via.placeholder.com/150x200.png?text=Oppenheimer',
      'year': '2023',
      'rating': 8.4,
      'dateAdded': '20 April 2023',
      'type': 'movie',
      'progress': 0,
    },
    {
      'title': 'The Witcher: Season 2',
      'poster': 'https://via.placeholder.com/150x200.png?text=Witcher',
      'year': '2021',
      'rating': 8.1,
      'dateAdded': '15 Maret 2023',
      'type': 'tv',
      'progress': 0.6,
    },
    {
      'title': 'Godzilla vs. Kong',
      'poster': 'https://via.placeholder.com/150x200.png?text=Godzilla',
      'year': '2021',
      'rating': 7.8,
      'dateAdded': '5 Februari 2023',
      'type': 'movie',
      'progress': 0.3,
    },
    {
      'title': 'Loki',
      'poster': 'https://via.placeholder.com/150x200.png?text=Loki',
      'year': '2021',
      'rating': 8.3,
      'dateAdded': '12 Januari 2023',
      'type': 'tv',
      'progress': 1.0,
    },
    {
      'title': 'Spider-Man: No Way Home',
      'poster': 'https://via.placeholder.com/150x200.png?text=SpiderMan',
      'year': '2021',
      'rating': 8.7,
      'dateAdded': '2 Januari 2023',
      'type': 'movie',
      'progress': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              floating: true,
              elevation: 0,
              backgroundColor: AppColors.background,
              title: Text(
                'Watchlist Saya',
                style: AppTextStyles.heading.copyWith(fontSize: 20),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    top: 80,
                  ),
                  child: Text(
                    'Kelola film dan serial TV yang ingin kamu tonton',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 13),
                tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.sort, color: AppColors.accent),
                  onPressed: () {},
                ),
              ],
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWatchlistTab(_watchlistFilms),
            _buildEmptyState('Belum ada film favorit', Icons.favorite_border),
            _buildEmptyState(
              'Belum ada film yang sedang ditonton',
              Icons.play_circle_outline,
            ),
            _buildEmptyState(
              'Belum ada film untuk ditonton nanti',
              Icons.watch_later_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistTab(List<Map<String, dynamic>> films) {
    if (films.isEmpty) {
      return _buildEmptyState(
        'Belum ada film dalam watchlist',
        Icons.playlist_add,
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: films.length,
        itemBuilder: (context, index) {
          final film = films[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: _buildWatchlistItem(film)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWatchlistItem(Map<String, dynamic> film) {
    final double progress = film['progress'] as double? ?? 0.0;
    final bool isCompleted = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster film
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: film['poster'],
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            width: 80,
                            height: 120,
                            color: AppColors.textFieldBg,
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            width: 80,
                            height: 120,
                            color: AppColors.textFieldBg,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppColors.textSecondary,
                            ),
                          ),
                    ),
                    // Badge tipe (film/tv)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          film['type'] == 'movie' ? 'FILM' : 'TV',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Detail film
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Film title dan tahun
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                film['title'],
                                style: AppTextStyles.bodyBold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(film['year'], style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(
                              film['rating'],
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: _getRatingColor(film['rating']),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (film['rating'] as double)
                                    .toStringAsFixed(1)
                                    .replaceAll('.', ','),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getRatingColor(film['rating']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tanggal ditambahkan
                    Text(
                      'Ditambahkan pada ${film['dateAdded']}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    if (progress > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isCompleted ? 'Selesai' : 'Sedang ditonton',
                                style: AppTextStyles.caption.copyWith(
                                  color:
                                      isCompleted
                                          ? Colors.green
                                          : AppColors.primary,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.textFieldBg,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted ? Colors.green : AppColors.primary,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      children: [
                        _buildActionButton(
                          icon: isCompleted ? Icons.replay : Icons.play_arrow,
                          label: isCompleted ? 'Tonton Ulang' : 'Tonton',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          label: 'Hapus',
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 70, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Tambahkan Film'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mendapatkan warna berdasarkan nilai rating
  Color _getRatingColor(double? rating) {
    final safeRating = rating ?? 0.0;
    if (safeRating >= 7.5) return Colors.green;
    if (safeRating >= 5.0) return Colors.orange;
    return Colors.red;
  }
}
