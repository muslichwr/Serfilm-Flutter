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
  final List<String> _tabs = ['Belum Ditonton', 'Sudah Ditonton'];

  // Data film watchlist
  final List<Map<String, dynamic>> _watchlistFilms = [
    {
      'title': 'Oppenheimer',
      'poster': 'https://via.placeholder.com/150x200.png?text=Oppenheimer',
      'year': '2023',
      'rating': 8.4,
      'dateAdded': '20 April 2023',
      'type': 'movie',
      'status': 'unwatched',
    },
    {
      'title': 'The Witcher: Season 2',
      'poster': 'https://via.placeholder.com/150x200.png?text=Witcher',
      'year': '2021',
      'rating': 8.1,
      'dateAdded': '15 Maret 2023',
      'type': 'tv',
      'status': 'watched',
    },
    {
      'title': 'Godzilla vs. Kong',
      'poster': 'https://via.placeholder.com/150x200.png?text=Godzilla',
      'year': '2021',
      'rating': 7.8,
      'dateAdded': '5 Februari 2023',
      'type': 'movie',
      'status': 'unwatched',
    },
    {
      'title': 'Loki',
      'poster': 'https://via.placeholder.com/150x200.png?text=Loki',
      'year': '2021',
      'rating': 8.3,
      'dateAdded': '12 Januari 2023',
      'type': 'tv',
      'status': 'watched',
    },
    {
      'title': 'Spider-Man: No Way Home',
      'poster': 'https://via.placeholder.com/150x200.png?text=SpiderMan',
      'year': '2021',
      'rating': 8.7,
      'dateAdded': '2 Januari 2023',
      'type': 'movie',
      'status': 'unwatched',
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
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
                tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildWatchlistTab(_watchlistFilms),
            _buildWatchlistTab(_watchlistFilms),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new movie to watchlist
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWatchlistTab(List<Map<String, dynamic>> films) {
    // Filter film berdasarkan tab yang aktif
    final filteredFilms =
        films
            .where(
              (film) =>
                  film['status'] ==
                  (_tabController.index == 0 ? 'unwatched' : 'watched'),
            )
            .toList();

    if (filteredFilms.isEmpty) {
      return _buildEmptyState(
        _tabController.index == 0
            ? 'Belum ada film yang ingin ditonton'
            : 'Belum ada film yang sudah ditonton',
        _tabController.index == 0 ? Icons.add_to_queue : Icons.local_movies,
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredFilms.length,
        itemBuilder: (context, index) {
          final film = filteredFilms[index];

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
    final bool isWatched = film['status'] == 'watched';

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
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail_film',
            arguments: {
              'title': film['title'],
              'poster': film['poster'],
              'year': film['year'],
              'rating': film['rating'],
              'type': film['type'],
              'status': film['status'],
              'dateAdded': film['dateAdded'],
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster film
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
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
                  ),
                  // Badge status
                  if (isWatched)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Detail film
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
                    Row(
                      children: [
                        Icon(
                          film['type'] == 'movie' ? Icons.movie : Icons.tv,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          film['year'],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          (film['rating'] is int)
                              ? (film['rating'] as int).toStringAsFixed(1)
                              : (film['rating'] as double).toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ditambahkan ${film['dateAdded']}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              // TODO: Toggle watch status
                            },
                            icon: Icon(
                              isWatched ? Icons.refresh : Icons.check,
                              size: 18,
                            ),
                            label: Text(
                              isWatched ? 'Tandai Belum' : 'Tandai Selesai',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  isWatched ? Colors.orange : Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color:
                                      isWatched ? Colors.orange : Colors.green,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            // TODO: Delete from watchlist
                          },
                          icon: const Icon(Icons.delete_outline, size: 20),
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.all(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                          ),
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
            onPressed: () {
              // TODO: Add new movie
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Film'),
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

  Color _getRatingColor(double rating) {
    if (rating >= 7.5) return Colors.green;
    if (rating >= 5.0) return Colors.orange;
    return Colors.red;
  }
}
