import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import '../../widgets/film_card.dart';
import '../../widgets/review_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailFilmPage extends StatelessWidget {
  const DetailFilmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_add_outlined, color: Colors.white),
            onPressed: () {
              // Toggle watchlist
            },
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
                                color: AppColors.accent.withOpacity(0.9),
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
                                    "8.8",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Tahun dan Genre
                            Text(
                              "2010 • Action, Sci-Fi",
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Judul film
                        Text(
                          "Inception",
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 28,
                            height: 1.2,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                        onPressed: () {},
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
                  const SizedBox(height: 16),
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
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: similarMovies.length,
        itemBuilder: (context, index) {
          final movie = similarMovies[index];
          final rating = movie['rating'] as double?;
          final formattedRating =
              rating != null
                  ? rating.toStringAsFixed(1).replaceAll('.', ',')
                  : "N/A";

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
                        // Judul film
                        Text(
                          movie['title'] as String? ?? 'Tidak ada judul',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Rating
                        const SizedBox(height: 2),
                        if (rating != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _getRatingColor(rating).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              formattedRating,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getRatingColor(rating),
                              ),
                            ),
                          )
                        else
                          Text(
                            "Rating tidak tersedia",
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
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
        'name': 'Hiroko Tanaka',
        'avatar': 'https://randomuser.me/api/portraits/women/32.jpg',
        'rating': 9.2,
        'comment':
            'Film dengan alur cerita yang menarik dan visual yang memukau. Sangat direkomendasikan!',
        'date': '2 hari lalu',
      },
      {
        'name': 'Kenji Watanabe',
        'avatar': 'https://randomuser.me/api/portraits/men/52.jpg',
        'rating': 7.5,
        'comment':
            'Konsep yang menarik, meskipun beberapa adegan terasa agak dipaksakan. Tapi secara keseluruhan masih layak ditonton.',
        'date': '1 minggu lalu',
      },
      {
        'name': 'Yumi Kobayashi',
        'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
        'rating': 8.7,
        'comment':
            'Akting para pemain sangat mengesankan. Sutradara berhasil membangun tensi dengan baik.',
        'date': '2 minggu lalu',
      },
      // Contoh dengan data yang tidak lengkap
      {
        'name': 'Pengguna Baru',
        'avatar': '',
        'rating': null,
        'comment': '',
        'date': 'Baru saja',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: reviewSamples.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 24,
            thickness: 0.5,
            color: AppColors.divider.withOpacity(0.08),
          ),
      itemBuilder: (context, index) {
        final review = reviewSamples[index];
        return ReviewCard(
          posterUrl: review['avatar'],
          title: review['title'] as String?,
          rating: review['rating'] as double?,
          comment: review['comment'] as String?,
          username: review['name'] as String?,
          date: review['date'] as String?,
          onWriteReview: () {},
        );
      },
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
