import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import '../../widgets/film_card.dart';
import '../../widgets/review_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/tmdb_service.dart';
import '../../models/film_model.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  // Service untuk mendapatkan data film
  final TMDBService _tmdbService = TMDBService();

  // Data kategori film
  final List<String> _categories = ["Films", "TV Shows", "Anime", "My List"];
  int _selectedCategoryIndex = 0;

  // Loading states
  bool _loadingTrending = true;
  bool _loadingFeatured = true;
  bool _loadingPopular = true;
  bool _loadingTopRated = true;

  // Error states
  String? _errorTrending;
  String? _errorFeatured;
  String? _errorPopular;
  String? _errorTopRated;

  // Data film dari API
  List<Film> _trendingMovies = [];
  List<Film> _featuredMovies = [];
  List<Film> _popularMovies = [];
  List<Film> _topRatedMovies = [];

  // Data film rekomendasi watchlist (jika user login)
  List<Film> _recommendedMovies = [];
  bool _loadingRecommended = false;
  String? _errorRecommended;

  // Daftar film favorit - menggunakan data dari API
  List<Film> _favoriteMovies = [];
  bool _loadingFavorites = false;

  // Current banner index
  int _currentBannerIndex = 0;

  // Timer untuk reset loading states jika terlalu lama
  Timer? _loadingTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController()..addListener(() {
          setState(() {
            _scrollOffset = _scrollController.offset;
          });
        });

    // Menunda eksekusi fetch untuk memastikan widget sudah terpasang dengan baik
    Future.delayed(Duration.zero, () {
      // Mengambil data film dari API saat widget diinisialisasi
      _fetchMoviesWithRetry();
    });

    // Set timer untuk reset loading state jika terlalu lama
    _loadingTimeoutTimer = Timer(Duration(seconds: 10), () {
      if (mounted) {
        debugPrint('TIMEOUT: Reset loading states karena terlalu lama');
        setState(() {
          if (_loadingTrending) {
            _loadingTrending = false;
            _errorTrending = "Timeout loading trending";
          }
          if (_loadingFeatured) {
            _loadingFeatured = false;
            _errorFeatured = "Timeout loading featured";
          }
          if (_loadingPopular) {
            _loadingPopular = false;
            _errorPopular = "Timeout loading popular";
          }
          if (_loadingTopRated) {
            _loadingTopRated = false;
            _errorTopRated = "Timeout loading top rated";
          }
          if (_loadingRecommended) {
            _loadingRecommended = false;
            _errorRecommended = "Timeout loading recommendations";
          }
          if (_loadingFavorites) {
            _loadingFavorites = false;
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set token autentikasi dari Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null && authProvider.user!.token != null) {
      debugPrint(
        'Menggunakan token user yang terautentikasi: ${authProvider.user!.name}',
      );
      _tmdbService.setAuthToken(authProvider.user!.token!);
      // Jika user terautentikasi, ambil rekomendasi dari watchlist
      _fetchRecommendedMovies();

      // Jika trending movies kosong, coba fetch ulang dengan token baru
      if (_trendingMovies.isEmpty) {
        debugPrint(
          'Trending movies kosong setelah login, mencoba fetch ulang...',
        );
        _fetchMoviesWithRetry();
      }
    } else {
      debugPrint('User tidak terautentikasi, fitur rekomendasi tidak tersedia');
      // Gunakan token dummy untuk testing API recommendation
      _tmdbService.setAuthToken('dummy_token');
    }
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ambil data jika widget diupdate (misalnya setelah login/register)
    _refreshMovies();
    debugPrint('HomePage diupdate, me-refresh semua data film...');
  }

  // Method untuk reloading data ketika halaman muncul kembali
  void refreshDataOnPageView() {
    debugPrint('HomePage muncul kembali di layar, memeriksa data...');
    // Periksa apakah data perlu dimuat ulang
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null && authProvider.user!.token != null) {
      debugPrint('User terautentikasi, memperbarui token...');
      _tmdbService.setAuthToken(authProvider.user!.token!);
    }

    // Reload data film dari API
    _refreshMovies();
  }

  // Metode untuk mengambil data film dari API
  Future<void> _fetchMovies() async {
    debugPrint('=== Memulai fetch data film ===');
    _fetchTrendingMovies();
    _fetchPopularMovies();
    _fetchTopRatedMovies();
  }

  // Mengambil film trending
  Future<void> _fetchTrendingMovies() async {
    debugPrint('Memulai fetch film trending...');
    setState(() {
      _loadingTrending = true;
      _errorTrending = null;
    });

    try {
      final trending = await _tmdbService.getTrendingMovies();
      debugPrint('Berhasil mendapatkan ${trending.length} film trending!');
      setState(() {
        _trendingMovies = trending;

        // Gunakan 3 film trending pertama sebagai featured
        if (trending.length > 3) {
          _featuredMovies = trending.sublist(0, 3);
          debugPrint('Featured movies diisi dengan 3 film trending pertama');
        } else {
          _featuredMovies = trending;
          debugPrint(
            'Featured movies diisi dengan ${trending.length} film trending yang tersedia',
          );
        }

        _loadingTrending = false;
        _loadingFeatured = false;

        // Force rebuild untuk memastikan carousel terinisialisasi dengan benar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });

        // Log untuk debugging
        debugPrint(
          'Film trending pertama: ${trending.isNotEmpty ? trending[0].title : "Tidak ada"}',
        );
        if (trending.isNotEmpty) {
          debugPrint(
            'Genre film trending pertama: ${trending[0].genres.join(", ")}',
          );
          debugPrint('Rating film trending pertama: ${trending[0].rating}');
          debugPrint(
            'Poster URL film trending pertama: ${trending[0].posterUrl}',
          );
        }
      });
    } catch (e) {
      debugPrint('ERROR fetch trending: $e');
      setState(() {
        _errorTrending = e.toString();
        _loadingTrending = false;
        _loadingFeatured = false;
      });
    }
  }

  // Mengambil film populer
  Future<void> _fetchPopularMovies() async {
    debugPrint('Memulai fetch film populer...');
    setState(() {
      _loadingPopular = true;
      _errorPopular = null;
    });

    try {
      final popular = await _tmdbService.getPopularMovies();
      debugPrint('Berhasil mendapatkan ${popular.length} film populer!');
      setState(() {
        _popularMovies = popular;
        _loadingPopular = false;

        // Log untuk debugging
        if (popular.isNotEmpty) {
          debugPrint('Film populer pertama: ${popular[0].title}');
          debugPrint(
            'Genre film populer pertama: ${popular[0].genres.join(", ")}',
          );
          debugPrint('Rating film populer pertama: ${popular[0].rating}');
        }
      });
    } catch (e) {
      debugPrint('ERROR fetch populer: $e');
      setState(() {
        _errorPopular = e.toString();
        _loadingPopular = false;
      });
    }
  }

  // Mengambil film dengan rating tertinggi
  Future<void> _fetchTopRatedMovies() async {
    debugPrint('Memulai fetch film top rated...');
    setState(() {
      _loadingTopRated = true;
      _errorTopRated = null;
    });

    try {
      final topRated = await _tmdbService.getTopRatedMovies();
      debugPrint('Berhasil mendapatkan ${topRated.length} film top rated!');
      setState(() {
        _topRatedMovies = topRated;
        _loadingTopRated = false;

        // Log untuk debugging
        if (topRated.isNotEmpty) {
          debugPrint('Film top rated pertama: ${topRated[0].title}');
          debugPrint('Rating film top rated pertama: ${topRated[0].rating}');
        }
      });
    } catch (e) {
      debugPrint('ERROR fetch top rated: $e');
      setState(() {
        _errorTopRated = e.toString();
        _loadingTopRated = false;
      });
    }
  }

  // Mengambil film rekomendasi dari watchlist (jika user login)
  Future<void> _fetchRecommendedMovies() async {
    // Kita tidak akan fetch rekomendasi film lagi karena section ini dihapus
    debugPrint('Fetch rekomendasi film dinonaktifkan');
  }

  // Refresh data film
  Future<void> _refreshMovies() async {
    debugPrint('Memulai refresh semua data film...');

    // Periksa apakah data perlu dimuat (jika kosong)
    if (_trendingMovies.isEmpty ||
        _popularMovies.isEmpty ||
        _topRatedMovies.isEmpty) {
      debugPrint('Beberapa koleksi film kosong, memuat ulang semua data...');
      await _fetchMovies();
    } else {
      // Jika data sudah ada, tetap refresh untuk memastikan keterkinian
      await _fetchMovies();
    }

    // Refresh rekomendasi jika user login
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null && authProvider.user!.token != null) {
      if (_recommendedMovies.isEmpty) {
        debugPrint('Rekomendasi film kosong, memuat rekomendasi...');
      }
      await _fetchRecommendedMovies();
    }
  }

  // Method untuk mengambil data dengan retry otomatis
  Future<void> _fetchMoviesWithRetry() async {
    debugPrint('=== Memulai fetch data film dengan retry otomatis ===');

    // Coba fetch data dengan retry
    try {
      await _fetchMovies();
    } catch (e) {
      debugPrint('ERROR pada fetch pertama: $e');
      // Tunggu 2 detik sebelum retry
      await Future.delayed(Duration(seconds: 2));
      debugPrint('Mencoba fetch ulang otomatis...');

      try {
        await _fetchMovies();
      } catch (e) {
        debugPrint('ERROR pada retry pertama: $e');
        // Tunggu 3 detik sebelum retry terakhir
        await Future.delayed(Duration(seconds: 3));
        debugPrint('Mencoba fetch ulang terakhir...');

        try {
          await _fetchMovies();
        } catch (e) {
          debugPrint('ERROR pada retry terakhir: $e');
          // Tampilkan error pada UI
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _loadingTimeoutTimer?.cancel();
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
                  ClipOval(child: _buildAppBarProfileImage(context)),
                  const SizedBox(width: 8),
                  Text(
                    Provider.of<AuthProvider>(context).user?.name ?? "Pengguna",
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final name = user?.name ?? 'Pengguna';
    final photoUrl = authProvider.getProfilePhotoUrl();

    print('DEBUG - Foto URL untuk UI: $photoUrl');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child:
                photoUrl.isEmpty
                    ? Container(
                      width: 32,
                      height: 32,
                      color: AppColors.primary.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    )
                    : CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            width: 32,
                            height: 32,
                            color: AppColors.surface,
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      errorWidget: (context, url, error) {
                        print(
                          'DEBUG - Error loading profile image: $error, URL: $url',
                        );
                        return Container(
                          width: 32,
                          height: 32,
                          color: AppColors.surface,
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
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
    // Menampilkan loading state jika data masih diambil
    if (_loadingFeatured) {
      return Container(
        height: 450,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    // Menampilkan error jika gagal mengambil data
    if (_errorFeatured != null || _featuredMovies.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                "Gagal memuat film trending",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _fetchTrendingMovies,
                child: Text("Coba Lagi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Movie Banner Carousel dengan penyesuaian rasio
        Container(
          width: double.infinity,
          height: 220, // Mengurangi tinggi agar tampilan lebih proporsional
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.surface,
          ),
          child: CarouselSlider(
            key: UniqueKey(),
            options: CarouselOptions(
              height: 220,
              viewportFraction: 1.0,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
            ),
            items:
                _featuredMovies
                    .map((film) => _buildFeaturedMovieItem(film))
                    .toList(),
          ),
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
  Widget _buildFeaturedMovieItem(Film film) {
    String genre = film.genres.isNotEmpty ? film.genres[0] : "FILM";

    // Hanya gunakan backdrop, tanpa fallback ke poster
    String imageUrl = film.backdropUrl;

    debugPrint(
      'Featured item: ${film.title}, using backdrop: ${film.backdropUrl.isNotEmpty}',
    );
    debugPrint('Image URL: $imageUrl');

    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail_film',
            arguments: {
              'id': film.id,
              'title': film.title,
              'poster': film.posterUrl,
              'backdrop': film.backdropUrl,
              'overview': film.overview,
              'year': film.year,
              'rating': film.rating,
              'type': 'movie',
            },
          );
        },
        child: Stack(
          children: [
            // Backdrop Film dengan overlay gradient yang direvisi
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Gambar backdrop
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                      alignment: Alignment.center,
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: AppColors.textSecondary,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Gambar tidak tersedia",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),

                    // Gradient overlay sebagai lapisan terpisah
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.3, 0.55, 0.8, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content overlay - posisi disesuaikan agar lebih proporsional
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genre tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
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
                        genre,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Movie title - ukuran text dikurangi
                    Text(
                      film.title,
                      style: TextStyle(
                        fontSize: 20, // Ukuran font dikecilkan
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Movie details (rating & year)
                    Row(
                      children: [
                        // Year
                        Text(
                          film.year.isNotEmpty
                              ? film.year
                              : 'Tahun tidak tersedia',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Rating
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(
                              film.rating,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: _getRatingColor(film.rating),
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (film.rating)
                                    .toStringAsFixed(1)
                                    .replaceAll('.', ','),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getRatingColor(film.rating),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tombol "LIHAT DETAIL" - posisi disesuaikan
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail_film',
                            arguments: {
                              'id': film.id,
                              'title': film.title,
                              'poster': film.posterUrl,
                              'backdrop': film.backdropUrl,
                              'overview': film.overview,
                              'year': film.year,
                              'rating': film.rating,
                              'type': 'movie',
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
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
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "LIHAT DETAIL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
      ),
    );
  }

  // 🔥 Trending Section
  Widget _buildTrendingSection(BuildContext context) {
    return _buildHorizontalMovieSection(
      title: "Trending Saat Ini",
      tagline: "TRENDING",
      tagColor: Colors.amber,
      movies: _trendingMovies,
      height: 220,
    );
  }

  // 👑 Popular Movies Section
  Widget _buildPopularMoviesSection(BuildContext context) {
    return _buildHorizontalMovieSection(
      title: "Film Populer",
      tagline: "POPULER",
      tagColor: Colors.deepPurple,
      movies: _popularMovies,
      height: 220,
    );
  }

  // ⭐ Top Rated Section
  Widget _buildTopRatedSection(BuildContext context) {
    return _buildHorizontalMovieSection(
      title: "Film Terbaik",
      tagline: "TOP RATED",
      tagColor: Colors.green,
      movies: _topRatedMovies,
      height: 220,
    );
  }

  // Template untuk section film horizontal dengan data yang dapat dikustomisasi
  Widget _buildHorizontalMovieSection({
    required String title,
    required String tagline,
    required Color tagColor,
    required List<dynamic> movies,
    required double height,
  }) {
    if (movies.isEmpty) {
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
              const Spacer(), // Gunakan Spacer sebagai pengganti Expanded
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
          Container(
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      );
    }

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
            const Spacer(), // Gunakan Spacer sebagai pengganti Expanded
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
              dynamic movieData = movies[index];
              String title;
              String posterUrl;
              double? rating;
              String? addedDate;
              bool isFavorite = false;

              // Menangani berbagai jenis data film
              if (movieData is Film) {
                title = movieData.title;
                posterUrl = movieData.posterUrl;
                rating = movieData.rating;
              } else if (movieData is Map<String, dynamic>) {
                title = movieData['title'] as String? ?? 'Tidak ada judul';
                posterUrl = movieData['poster'] as String? ?? '';
                rating = movieData['rating'] as double?;
                addedDate = movieData['addedDate'] as String?;
                isFavorite = movieData['isFavorite'] ?? false;
              } else {
                return SizedBox.shrink(); // Jika tipe data tidak didukung
              }

              final formattedRating =
                  rating != null
                      ? rating.toStringAsFixed(1).replaceAll('.', ',')
                      : "N/A";

              // Buat widget terlebih dahulu sebelum dianimasikan
              Widget movieCard = Container(
                width: 130,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman detail film
                    if (movieData is Film) {
                      Navigator.pushNamed(
                        context,
                        '/detail_film',
                        arguments: {
                          'id': movieData.id,
                          'title': movieData.title,
                          'poster': movieData.posterUrl,
                          'rating': movieData.rating,
                          'overview': movieData.overview,
                          'type': 'movie',
                          'year': movieData.year,
                        },
                      );
                    } else if (movieData is Map<String, dynamic>) {
                      Navigator.pushNamed(
                        context,
                        '/detail_film',
                        arguments: {
                          'title': title,
                          'poster': posterUrl,
                          'rating': rating,
                          'type': 'movie',
                          'year':
                              movieData['year'] ??
                              DateTime.now().year.toString(),
                          'dateAdded': addedDate,
                          'status': movieData['status'] ?? 'unwatched',
                          'isFavorite': isFavorite,
                        },
                      );
                    }
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
                                  color: AppColors.shadow.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: posterUrl,
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
                        title,
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
              );

              // Bungkus dengan animasi
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: movieCard),
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

  // Helper untuk membangun image profile di AppBar
  Widget _buildAppBarProfileImage(BuildContext context) {
    final photoUrl = Provider.of<AuthProvider>(context).getProfilePhotoUrl();

    if (photoUrl.isEmpty) {
      return Container(
        width: 24,
        height: 24,
        color: AppColors.primary.withOpacity(0.2),
        child: Icon(Icons.person, size: 16, color: AppColors.primary),
      );
    }

    return CachedNetworkImage(
      imageUrl: photoUrl,
      width: 24,
      height: 24,
      fit: BoxFit.cover,
      placeholder:
          (_, __) => Container(
            width: 24,
            height: 24,
            color: AppColors.surface,
            child: Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      errorWidget: (_, __, error) {
        print('DEBUG - AppBar profile image error: $error');
        return Container(
          width: 24,
          height: 24,
          color: AppColors.surface,
          child: Icon(Icons.person, size: 16, color: AppColors.textSecondary),
        );
      },
    );
  }
}
