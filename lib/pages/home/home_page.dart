import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import '../../widgets/film_card.dart';
import '../../widgets/review_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  // Data kategori film
  final List<String> _categories = ["Films", "TV Shows", "Anime", "My List"];
  int _selectedCategoryIndex = 0;

  // Data film featured
  final List<Map<String, dynamic>> _featuredMovies = [
    {
      'title': 'INCEPTION',
      'poster': 'https://via.placeholder.com/500x800.png?text=Inception',
      'genre': 'SCI-FI',
      'year': '2010',
      'duration': '148 menit',
      'rating': 8.8,
      'description':
          'Seorang pencuri handal memasuki alam mimpi untuk menanamkan sebuah ide dalam pikiran target.',
    },
    {
      'title': 'DUNE',
      'poster': 'https://via.placeholder.com/500x800.png?text=Dune',
      'genre': 'ADVENTURE',
      'year': '2021',
      'duration': '155 menit',
      'rating': 8.4,
      'description':
          'Paul Atreides, seorang pemuda brilian dengan takdir luar biasa, harus menghadapi bahaya di planet paling berbahaya di alam semesta.',
    },
    {
      'title': 'INTERSTELLAR',
      'poster': 'https://via.placeholder.com/500x800.png?text=Interstellar',
      'genre': 'SCI-FI',
      'year': '2014',
      'duration': '169 menit',
      'rating': 8.7,
      'description':
          'Tim astronot melakukan perjalanan melewati lubang cacing untuk menemukan planet baru yang layak huni bagi umat manusia.',
    },
  ];

  // Current banner index
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController()..addListener(() {
          setState(() {
            _scrollOffset = _scrollController.offset;
          });
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Menampilkan snackbar untuk kategori yang masih dalam pengembangan
  void _showDevelopmentSnackbar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur ini masih dalam tahap pengembangan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.accent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCollapsed = _scrollOffset > 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.background,
            stretch: true,
            title: AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: "https://via.placeholder.com/32",
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            width: 24,
                            height: 24,
                            color: AppColors.surface,
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            width: 24,
                            height: 24,
                            color: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Pengguna",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedOpacity(
                      opacity: isCollapsed ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: _buildProfile(context),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryTabs(context),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isCollapsed
                      ? Icons.notifications_outlined
                      : Icons.notifications,
                  color: AppColors.accent,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildFeaturedFilm(context),
                const SizedBox(height: 30),
                _buildTrendingSection(context),
                const SizedBox(height: 30),
                _buildPopularMoviesSection(context),
                const SizedBox(height: 30),
                _buildTopRatedSection(context),
                const SizedBox(height: 30),
                _buildFavoritesSection(context),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // 🧑‍🦱 Header - Foto profil + nama
  Widget _buildProfile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: "https://via.placeholder.com/32",
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    width: 32,
                    height: 32,
                    color: AppColors.surface,
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    width: 32,
                    height: 32,
                    color: AppColors.surface,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "Pengguna",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 📂 Menu Tab Kategori
  Widget _buildCategoryTabs(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isActive = index == _selectedCategoryIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (index == 0) {
                    // Kategori Film - halaman utama
                    _selectedCategoryIndex = index;
                  } else {
                    // Kategori lain - masih dalam pengembangan
                    _showDevelopmentSnackbar();
                  }
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _categories[index],
                    style: TextStyle(
                      color:
                          isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎥 Featured Film - Improved with Carousel
  Widget _buildFeaturedFilm(BuildContext context) {
    return Column(
      children: [
        // Movie Banner Carousel
        CarouselSlider(
          options: CarouselOptions(
            height: 450,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.3,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
          items:
              _featuredMovies
                  .map((movie) => _buildFeaturedMovieItem(movie))
                  .toList(),
        ),

        // Carousel Indicator
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _featuredMovies.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentBannerIndex = entry.key;
                    });
                  },
                  child: Container(
                    width: _currentBannerIndex == entry.key ? 24 : 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient:
                          _currentBannerIndex == entry.key
                              ? LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                              )
                              : null,
                      color:
                          _currentBannerIndex == entry.key
                              ? null
                              : AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // Single featured movie item for carousel
  Widget _buildFeaturedMovieItem(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail_film',
          arguments: {
            'title': movie['title'],
            'poster': movie['poster'],
            'year': movie['year'],
            'rating': movie['rating'],
            'type': 'movie',
            'description': movie['description'],
            'duration': movie['duration'],
            'genre': movie['genre'],
            'status': 'unwatched',
          },
        );
      },
      child: Stack(
        children: [
          // Poster Film dengan overlay gradient
          Container(
            height: 450,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withOpacity(0.4),
                      AppColors.background.withOpacity(0.8),
                      AppColors.background,
                    ],
                    stops: const [0.3, 0.6, 0.8, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: CachedNetworkImage(
                  imageUrl: movie['poster'],
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(
                        color: AppColors.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  errorWidget:
                      (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                            size: 48,
                          ),
                        ),
                      ),
                ),
              ),
            ),
          ),

          // Content overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre tag
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withOpacity(0.9),
                          AppColors.primary.withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      movie['genre'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Movie title
                  Text(
                    movie['title'],
                    style: TextStyle(
                      fontSize: 30,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Movie details
                  Row(
                    children: [
                      // Year
                      Text(
                        movie['year'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Duration
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie['duration'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Rating
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRatingColor(
                            movie['rating'],
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: _getRatingColor(movie['rating']),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (movie['rating'] as double)
                                  .toStringAsFixed(1)
                                  .replaceAll('.', ','),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getRatingColor(movie['rating']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Brief description
                  Text(
                    movie['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 24),

                  // Info button
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail_film',
                          arguments: {
                            'title': movie['title'],
                            'poster': movie['poster'],
                            'year': movie['year'],
                            'rating': movie['rating'],
                            'type': 'movie',
                            'description': movie['description'],
                            'duration': movie['duration'],
                            'genre': movie['genre'],
                            'status': 'unwatched',
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "LIHAT DETAIL",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Trending Section
  Widget _buildTrendingSection(BuildContext context) {
    final List<Map<String, dynamic>> trendingMovies = [
      {
        'title': 'Dune',
        'poster': 'https://via.placeholder.com/150x200.png?text=Dune',
        'rating': 8.4,
      },
      {
        'title': 'Oppenheimer',
        'poster': 'https://via.placeholder.com/150x200.png?text=Oppenheimer',
        'rating': 9.1,
      },
      {
        'title': 'Barbie',
        'poster': 'https://via.placeholder.com/150x200.png?text=Barbie',
        'rating': 7.6,
      },
      {
        'title': 'Guardians of the Galaxy',
        'poster': 'https://via.placeholder.com/150x200.png?text=GOTG',
        'rating': 8.0,
      },
      {
        'title': 'Mission Impossible',
        'poster': 'https://via.placeholder.com/150x200.png?text=Mission',
        'rating': 7.8,
      },
    ];

    return _buildHorizontalMovieSection(
      title: "Trending Saat Ini",
      tagline: "TRENDING",
      tagColor: Colors.amber,
      movies: trendingMovies,
      height: 220,
    );
  }

  // 👑 Popular Movies Section
  Widget _buildPopularMoviesSection(BuildContext context) {
    final List<Map<String, dynamic>> popularMovies = [
      {
        'title': 'Avatar: The Way of Water',
        'poster': 'https://via.placeholder.com/150x200.png?text=Avatar',
        'rating': 7.9,
      },
      {
        'title': 'The Batman',
        'poster': 'https://via.placeholder.com/150x200.png?text=Batman',
        'rating': 8.0,
      },
      {
        'title': 'Top Gun: Maverick',
        'poster': 'https://via.placeholder.com/150x200.png?text=TopGun',
        'rating': 8.3,
      },
      {
        'title': 'John Wick 4',
        'poster': 'https://via.placeholder.com/150x200.png?text=JohnWick',
        'rating': 8.5,
      },
      {
        'title': 'Fast X',
        'poster': 'https://via.placeholder.com/150x200.png?text=FastX',
        'rating': 6.4,
      },
    ];

    return _buildHorizontalMovieSection(
      title: "Film Populer",
      tagline: "POPULER",
      tagColor: Colors.deepPurple,
      movies: popularMovies,
      height: 220,
    );
  }

  // ⭐ Top Rated Section
  Widget _buildTopRatedSection(BuildContext context) {
    final List<Map<String, dynamic>> topRatedMovies = [
      {
        'title': 'The Shawshank Redemption',
        'poster': 'https://via.placeholder.com/150x200.png?text=Shawshank',
        'rating': 9.3,
      },
      {
        'title': 'The Godfather',
        'poster': 'https://via.placeholder.com/150x200.png?text=Godfather',
        'rating': 9.2,
      },
      {
        'title': 'The Dark Knight',
        'poster': 'https://via.placeholder.com/150x200.png?text=DarkKnight',
        'rating': 9.0,
      },
      {
        'title': 'Pulp Fiction',
        'poster': 'https://via.placeholder.com/150x200.png?text=PulpFiction',
        'rating': 8.9,
      },
      {
        'title': 'Parasite',
        'poster': 'https://via.placeholder.com/150x200.png?text=Parasite',
        'rating': 8.8,
      },
    ];

    return _buildHorizontalMovieSection(
      title: "Film Terbaik",
      tagline: "TOP RATED",
      tagColor: Colors.green,
      movies: topRatedMovies,
      height: 220,
    );
  }

  // ❤️ My Favorites
  Widget _buildFavoritesSection(BuildContext context) {
    final List<Map<String, dynamic>> favoriteMovies = [
      {
        'title': 'Inception',
        'poster': 'https://via.placeholder.com/150x200.png?text=Inception',
        'rating': 10.0,
        'addedDate': 'Kemarin',
      },
      {
        'title': 'Your Name',
        'poster': 'https://via.placeholder.com/150x200.png?text=YourName',
        'rating': 9.5,
        'addedDate': '2 hari lalu',
      },
      {
        'title': 'The Dark Knight',
        'poster': 'https://via.placeholder.com/150x200.png?text=DarkKnight',
        'rating': 9.8,
        'addedDate': 'Minggu lalu',
      },
      {
        'title': 'Spirited Away',
        'poster': 'https://via.placeholder.com/150x200.png?text=SpiritedAway',
        'rating': 9.7,
        'addedDate': '2 minggu lalu',
      },
      {
        'title': 'Whiplash',
        'poster': 'https://via.placeholder.com/150x200.png?text=Whiplash',
        'rating': 9.0,
        'addedDate': 'Bulan lalu',
      },
      {
        'title': 'La La Land',
        'poster': 'https://via.placeholder.com/150x200.png?text=LaLaLand',
        'rating': 8.5,
        'addedDate': '2 bulan lalu',
      },
    ];

    return _buildHorizontalMovieSection(
      title: "Film Favorit Saya",
      tagline: "FAVORIT",
      tagColor: Colors.redAccent,
      movies:
          favoriteMovies
              .map(
                (movie) => {
                  'title': movie['title'],
                  'poster': movie['poster'],
                  'rating': movie['rating'],
                  'addedDate': movie['addedDate'],
                  'isFavorite': true,
                },
              )
              .toList(),
      height: 220,
    );
  }

  // Template untuk section film horizontal dengan data yang dapat dikustomisasi
  Widget _buildHorizontalMovieSection({
    required String title,
    required String tagline,
    required Color tagColor,
    required List<Map<String, dynamic>> movies,
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tagline,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: tagColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final rating = movie['rating'] as double?;
              final formattedRating =
                  rating != null
                      ? rating.toStringAsFixed(1).replaceAll('.', ',')
                      : "N/A";
              final bool isFavorite = movie['isFavorite'] ?? false;
              final String? addedDate = movie['addedDate'] as String?;

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail_film',
                            arguments: {
                              'title': movie['title'],
                              'poster': movie['poster'],
                              'rating': movie['rating'],
                              'type': 'movie',
                              'year':
                                  movie['year'] ??
                                  DateTime.now().year.toString(),
                              'dateAdded': movie['addedDate'],
                              'status': movie['status'] ?? 'unwatched',
                              'isFavorite': movie['isFavorite'] ?? false,
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poster film
                            Stack(
                              children: [
                                Container(
                                  height: 170,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadow.withOpacity(
                                          0.1,
                                        ),
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
                                          'https://via.placeholder.com/150x200.png?text=No+Image',
                                      fit: BoxFit.cover,
                                      width: 130,
                                      height: 170,
                                      placeholder:
                                          (_, __) => Container(
                                            color: AppColors.surface,
                                            child: Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
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

                                // Rating badge
                                if (rating != null)
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getRatingColor(
                                          rating,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 14,
                                            color: _getRatingColor(rating),
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            formattedRating,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getRatingColor(rating),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Favorite icon if isFavorite = true
                                if (isFavorite)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.redAccent,
                                        size: 14,
                                      ),
                                    ),
                                  ),

                                // Added date for favorites
                                if (addedDate != null)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        addedDate,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Judul film
                            Text(
                              movie['title'] as String? ?? 'Tidak ada judul',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ),

        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              "Lihat Semua",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
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
