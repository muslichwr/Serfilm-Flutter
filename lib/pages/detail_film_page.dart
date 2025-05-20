import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import '../../widgets/film_card.dart';
import '../../widgets/review_card.dart';
import './review_film_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailFilmPage extends StatelessWidget {
  const DetailFilmPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menerima data film dari arguments
    final Map<String, dynamic> filmData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final bool isWatched = filmData['status'] == 'watched';
    final bool isInWatchlist = filmData['isInWatchlist'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Status badge di app bar
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isWatched
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWatched ? Icons.check_circle : Icons.schedule,
                  color: isWatched ? Colors.green : Colors.orange,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  isWatched ? 'Sudah Ditonton' : 'Belum Ditonton',
                  style: TextStyle(
                    color: isWatched ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan poster film
            Stack(
              children: [
                // Poster film dengan efek gradient overlay
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withOpacity(0.8),
                        AppColors.background,
                      ],
                      stops: const [0.4, 0.75, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: CachedNetworkImage(
                    imageUrl:
                        filmData['poster'] ??
                        "https://via.placeholder.com/400x250.png?text=Movie+Poster",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Info film overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Rating
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _getRatingColor(
                                  filmData['rating'] as double,
                                ).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    (filmData['rating'] as double)
                                        .toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tahun dan Tipe
                            Text(
                              "${filmData['year']} • ${filmData['type'] == 'movie' ? 'Film' : 'Serial TV'}",
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Judul film
                        Text(
                          filmData['title'] ?? "Judul Tidak Tersedia",
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 28,
                            height: 1.2,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Status dan tanggal ditambahkan
                        Row(
                          children: [
                            if (isInWatchlist) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isWatched
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isWatched
                                      ? 'Sudah Ditonton'
                                      : 'Belum Ditonton',
                                  style: TextStyle(
                                    color:
                                        isWatched
                                            ? Colors.green
                                            : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ditambahkan ${filmData['dateAdded']}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                children: [
                  // Tombol tambah ke watchlist
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement watchlist toggle
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInWatchlist
                                  ? 'Dihapus dari watchlist'
                                  : 'Ditambahkan ke watchlist',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        isInWatchlist
                            ? Icons.playlist_remove
                            : Icons.playlist_add,
                        size: 20,
                      ),
                      label: Text(
                        isInWatchlist
                            ? 'Hapus dari Watchlist'
                            : 'Tambah ke Watchlist',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isInWatchlist
                                ? Colors.red.shade800
                                : AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol tulis ulasan
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigasi ke halaman review film
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ReviewFilmPage(filmData: filmData),
                        ),
                      );
                    },
                    icon: Icon(Icons.rate_review, size: 20),
                    label: Text(
                      'Tulis Ulasan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten detail film
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Sinopsis
                  Text(
                    "Sinopsis",
                    style: AppTextStyles.heading.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Seorang pencuri profesional memasuki mimpi target-targetnya untuk mencuri rahasia mereka. Namun kali ini ia ditawari kesempatan untuk menghapus masa lalunya dengan melakukan hal yang mustahil.",
                    style: AppTextStyles.body.copyWith(
                      height: 1.6,
                      color: AppColors.textPrimary.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cast
                  _buildSectionTitle("Cast"),
                  const SizedBox(height: 12),
                  _buildCastList(),

                  const SizedBox(height: 32),

                  // Film Serupa
                  _buildSectionTitle("Film Serupa"),
                  const SizedBox(height: 12),
                  _buildSimilarMovies(),

                  const SizedBox(height: 32),

                  // Ulasan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Ulasan Pengguna"),
                      TextButton.icon(
                        onPressed: () {
                          // Navigasi ke halaman review film
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ReviewFilmPage(filmData: filmData),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        label: Text(
                          "Tulis Ulasan",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildUserReviews(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section title yang lebih minimalis
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading.copyWith(fontSize: 16, letterSpacing: 0.5),
    );
  }

  // Cast dengan tampilan minimalis
  Widget _buildCastList() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://via.placeholder.com/80x80.png?text=Cast+$index",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surface,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Actor $index",
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Film serupa dengan desain card yang lebih minimalis
  Widget _buildSimilarMovies() {
    final List<Map<String, dynamic>> similarMovies = [
      {
        'title': 'Shutter Island',
        'poster': 'https://via.placeholder.com/120x160.png?text=Movie+1',
        'rating': 8.2,
      },
      {
        'title': 'The Prestige',
        'poster': 'https://via.placeholder.com/120x160.png?text=Movie+2',
        'rating': 8.5,
      },
      {
        'title': 'Memento',
        'poster': 'https://via.placeholder.com/120x160.png?text=Movie+3',
        'rating': 7.9,
      },
      {
        'title': 'Interstellar',
        'poster': 'https://via.placeholder.com/120x160.png?text=Movie+4',
        'rating': 9.0,
      },
      {
        'title': 'The Matrix',
        'poster': 'https://via.placeholder.com/120x160.png?text=Movie+5',
        'rating': 8.7,
      },
    ];

    return SizedBox(
      height: 220, // Menambah tinggi container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: similarMovies.length,
        itemBuilder: (context, index) {
          final movie = similarMovies[index];
          final rating = movie['rating'] as double?;
          final formattedRating =
              rating != null ? rating.toStringAsFixed(1) : "N/A";

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Poster film dengan corner radius
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.08),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  movie['poster'] as String? ??
                                  'https://via.placeholder.com/120x160.png?text=No+Image',
                              fit: BoxFit.cover,
                              width: 120,
                              height: 160,
                              placeholder:
                                  (_, __) => Container(
                                    color: AppColors.surface,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: AppColors.surface,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Judul film dan rating dalam satu container
                        Container(
                          height: 44, // Tinggi tetap untuk judul dan rating
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Judul film
                              Text(
                                movie['title'] as String? ?? 'Tidak ada judul',
                                style: AppTextStyles.bodyBold.copyWith(
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Rating
                              if (rating != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRatingColor(
                                      rating,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: _getRatingColor(rating),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        formattedRating,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _getRatingColor(rating),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  "Rating tidak tersedia",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
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
              ),
            ),
          );
        },
      ),
    );
  }

  // Ulasan dengan desain yang lebih modern dan minimalis
  Widget _buildUserReviews() {
    final List<Map<String, dynamic>> reviewSamples = [
      {
        'id': '1',
        'name': 'Hiroko Tanaka',
        'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
        'rating': 9.2,
        'comment':
            'Film dengan alur cerita yang menarik dan visual yang memukau. Sangat direkomendasikan!',
        'date': '2 hari lalu',
        'isCurrentUser': true,
      },
      {
        'id': '2',
        'name': 'Kenji Watanabe',
        'avatar': 'https://randomuser.me/api/portraits/men/52.jpg',
        'rating': 7.5,
        'comment':
            'Konsep yang menarik, meskipun beberapa adegan terasa agak dipaksakan. Tapi secara keseluruhan masih layak ditonton.',
        'date': '1 minggu lalu',
        'isCurrentUser': false,
      },
      {
        'id': '3',
        'name': 'Yumi Kobayashi',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
        'rating': 8.7,
        'comment':
            'Akting para pemain sangat mengesankan. Sutradara berhasil membangun tensi dengan baik.',
        'date': '2 minggu lalu',
        'isCurrentUser': false,
      },
    ];

    if (reviewSamples.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada ulasan',
              style: AppTextStyles.heading.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama memberikan ulasan untuk film ini',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviewSamples.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 20, // Mengurangi jarak antar review
            thickness: 0.5,
            color: AppColors.divider.withOpacity(0.08),
          ),
      itemBuilder: (context, index) {
        final review = reviewSamples[index];
        final bool isUserReview = review['isCurrentUser'] == true;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == reviewSamples.length - 1 ? 0 : 8,
          ),
          child: ReviewCard(
            posterUrl: review['avatar'],
            title: review['title'] as String?,
            rating: review['rating'] as double?,
            comment: review['comment'] as String?,
            username: review['name'] as String?,
            date: review['date'] as String?,
            isCurrentUser: isUserReview,
            onEditReview:
                isUserReview ? () => _editReview(context, review) : null,
            onWriteReview: () {},
          ),
        );
      },
    );
  }

  // Fungsi untuk membuka halaman edit review
  void _editReview(BuildContext context, Map<String, dynamic> review) async {
    // Navigasi ke halaman review dengan data yang sudah ada
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReviewFilmPage(
              filmData: {
                'id': '123',
                'title': 'Inception',
                'poster':
                    'https://via.placeholder.com/400x250.png?text=Movie+Poster',
                'year': '2010',
                'type': 'movie',
                'status': 'watched',
              }, // Hardcoded film data for demo
              existingReview: review,
            ),
      ),
    );

    // Handle hasil dari halaman review
    if (result != null) {
      if (result['action'] == 'delete') {
        // Handle delete action
        print('Review deleted');
      } else if (result['action'] == 'update') {
        // Handle update action
        print('Review updated: ${result['comment']}');
        print('New rating: ${result['rating']}');
        print('New status: ${result['status']}');
      }
    }
  }

  // Mendapatkan warna berdasarkan nilai rating
  Color _getRatingColor(double? rating) {
    final safeRating = rating ?? 0.0;
    if (safeRating >= 7.5) return Colors.green;
    if (safeRating >= 5.0) return Colors.orange;
    return Colors.red;
  }
}
