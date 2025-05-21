import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../widgets/film_card.dart';
import '../widgets/review_card.dart';
import './review_film_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/tmdb_service.dart';
import '../models/film_model.dart';
import '../models/cast_model.dart';
import '../providers/auth_provider.dart';

class DetailFilmPage extends StatefulWidget {
  const DetailFilmPage({super.key});

  @override
  State<DetailFilmPage> createState() => _DetailFilmPageState();
}

class _DetailFilmPageState extends State<DetailFilmPage> {
  // Service untuk mengambil data film
  final TMDBService _tmdbService = TMDBService();

  // Data film utama
  Film? _film;

  // Film serupa
  List<Film> _similarMovies = [];

  // Data cast film
  List<CastMember> _castList = [];

  // Status loading dan error
  bool _loadingFilm = true;
  bool _loadingSimilar = true;
  bool _loadingCast = true;
  String? _errorFilm;
  String? _errorSimilar;
  String? _errorCast;

  // Status film dalam watchlist (sementara hardcode)
  bool _isWatched = false;
  bool _isInWatchlist = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil argumen dari halaman sebelumnya
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Memeriksa apakah ada ID film
    if (args.containsKey('id')) {
      _fetchMovieDetails(args['id']);
    } else {
      // Jika tidak ada ID, gunakan data yang diberikan dari argumen
      setState(() {
        _loadingFilm = false;
        _isWatched = args['status'] == 'watched';
        _isInWatchlist = args['isInWatchlist'] ?? false;
      });
    }
  }

  // Mengambil detail film berdasarkan ID
  Future<void> _fetchMovieDetails(int id) async {
    setState(() {
      _loadingFilm = true;
      _errorFilm = null;
    });

    try {
      final film = await _tmdbService.getMovieDetails(id);
      setState(() {
        _film = film;
        _loadingFilm = false;

        // Mengambil film serupa dan cast film
        _fetchSimilarMovies(id);
        _fetchMovieCast(id);
      });
    } catch (e) {
      setState(() {
        _errorFilm = e.toString();
        _loadingFilm = false;
      });
    }
  }

  // Mengambil film serupa
  Future<void> _fetchSimilarMovies(int id) async {
    setState(() {
      _loadingSimilar = true;
      _errorSimilar = null;
    });

    try {
      final similar = await _tmdbService.getSimilarMovies(id);
      setState(() {
        _similarMovies = similar;
        _loadingSimilar = false;
      });
    } catch (e) {
      setState(() {
        _errorSimilar = e.toString();
        _loadingSimilar = false;
      });
    }
  }

  // Mengambil data cast film
  Future<void> _fetchMovieCast(int id) async {
    setState(() {
      _loadingCast = true;
      _errorCast = null;
    });

    try {
      final cast = await _tmdbService.getMovieCast(id);
      setState(() {
        _castList = cast;
        _loadingCast = false;
      });
    } catch (e) {
      print('ERROR - Gagal mengambil cast: $e');
      setState(() {
        _errorCast = e.toString();
        _loadingCast = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menerima data film dari arguments jika tidak menggunakan API
    final Map<String, dynamic> filmData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};

    // Gunakan data film dari API jika tersedia, jika tidak gunakan dari arguments
    final bool isWatched =
        _film != null ? _isWatched : (filmData['status'] == 'watched');
    final bool isInWatchlist =
        _film != null ? _isInWatchlist : (filmData['isInWatchlist'] ?? false);
    final String title = _film?.title ?? filmData['title'] ?? 'Judul Film';
    final String posterUrl = _film?.posterUrl ?? filmData['poster'] ?? '';
    final String backdropUrl =
        _film?.backdropUrl ?? filmData['backdrop'] ?? posterUrl;
    final double rating =
        _film?.rating ?? (filmData['rating'] as double? ?? 0.0);
    final String overview =
        _film?.overview ?? filmData['overview'] ?? 'Tidak ada deskripsi.';
    final String year = _film?.year ?? filmData['year'] ?? '';

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
          if (isInWatchlist)
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
      body:
          _loadingFilm
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
              : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan poster film
                    Stack(
                      children: [
                        // Backdrop film dengan efek gradient overlay
                        Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          color: AppColors.background,
                          child: Stack(
                            children: [
                              // Gambar backdrop
                              CachedNetworkImage(
                                imageUrl:
                                    backdropUrl.isNotEmpty
                                        ? backdropUrl
                                        : posterUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                placeholder:
                                    (_, __) => Container(
                                      color: AppColors.surface,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.primary,
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
                                        size: 48,
                                      ),
                                    ),
                              ),

                              // Gradient overlay sebagai lapisan terpisah
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.3),
                                      Colors.black.withOpacity(0.7),
                                      Colors.black.withOpacity(0.9),
                                    ],
                                    stops: const [0.2, 0.5, 0.75, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Info film overlay - revisi posisi ke bagian bawah backdrop
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Film title
                                Text(
                                  title,
                                  style: AppTextStyles.heading.copyWith(
                                    fontSize: 28,
                                    height: 1.2,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 8),

                                // Rating and year
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Rating
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getRatingColor(
                                          rating,
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
                                            rating.toStringAsFixed(1),
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
                                      "${year.isNotEmpty ? year : 'Tahun tidak diketahui'} • Film",
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Status dan tanggal ditambahkan
                                if (isInWatchlist) ...[
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isWatched
                                                  ? Colors.green.withOpacity(
                                                    0.2,
                                                  )
                                                  : Colors.orange.withOpacity(
                                                    0.2,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
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
                                        'Ditambahkan ${filmData['dateAdded'] ?? 'beberapa waktu lalu'}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Action buttons
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          // Tombol tambah ke watchlist
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement watchlist toggle
                                setState(() {
                                  _isInWatchlist = !_isInWatchlist;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isInWatchlist
                                          ? 'Ditambahkan ke watchlist'
                                          : 'Dihapus dari watchlist',
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
                                      (context) => ReviewFilmPage(
                                        filmData: {
                                          'id':
                                              _film?.id ?? filmData['id'] ?? 0,
                                          'title': title,
                                          'poster': posterUrl,
                                          'year': year,
                                          'type': 'movie',
                                          'status':
                                              isWatched
                                                  ? 'watched'
                                                  : 'unwatched',
                                        },
                                      ),
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
                            overview,
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
                                          (context) => ReviewFilmPage(
                                            filmData: {
                                              'id':
                                                  _film?.id ??
                                                  filmData['id'] ??
                                                  0,
                                              'title': title,
                                              'poster': posterUrl,
                                              'year': year,
                                              'type': 'movie',
                                              'status':
                                                  isWatched
                                                      ? 'watched'
                                                      : 'unwatched',
                                            },
                                          ),
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

  // Cast dengan data dari API
  Widget _buildCastList() {
    // Menampilkan loading state jika data masih diambil
    if (_loadingCast) {
      return Container(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Menampilkan pesan error jika gagal mengambil data
    if (_errorCast != null) {
      return Container(
        height: 110,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(height: 8),
              Text(
                "Gagal memuat data cast",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  if (_film != null) {
                    _fetchMovieCast(_film!.id);
                  }
                },
                child: Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    // Jika data cast kosong, gunakan data dummy
    if (_castList.isEmpty) {
      return _buildDummyCastList();
    }

    // Tampilkan data cast dari API
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: _castList.length,
        itemBuilder: (context, index) {
          final cast = _castList[index];

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
                      imageUrl: cast.profileUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cast.name,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Data cast dummy sebagai fallback jika API tidak tersedia
  Widget _buildDummyCastList() {
    // Data cast dummy dengan gambar yang lebih baik
    final List<Map<String, dynamic>> dummyCastData = [
      {
        'name': 'Leonardo DiCaprio',
        'character': 'Dom Cobb',
        'profile':
            'https://image.tmdb.org/t/p/w200/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
      },
      {
        'name': 'Joseph Gordon-Levitt',
        'character': 'Arthur',
        'profile':
            'https://image.tmdb.org/t/p/w200/zSqJ1qFq8NXFfi7JeIYMlzyb7QA.jpg',
      },
      {
        'name': 'Ellen Page',
        'character': 'Ariadne',
        'profile':
            'https://image.tmdb.org/t/p/w200/vDZzkOLIn19VdjdqXYJvhS1uf3U.jpg',
      },
      {
        'name': 'Tom Hardy',
        'character': 'Eames',
        'profile':
            'https://image.tmdb.org/t/p/w200/r8N5bDlna40Yj8BnUg0hLg7H7fT.jpg',
      },
      {
        'name': 'Ken Watanabe',
        'character': 'Saito',
        'profile':
            'https://image.tmdb.org/t/p/w200/psxtJfL7f7HpTdUhjCpwCjK6Jv7.jpg',
      },
      {
        'name': 'Michael Caine',
        'character': 'Miles',
        'profile':
            'https://image.tmdb.org/t/p/w200/hZsuXxVA8Z8k3LKGGMQd7OfZZXL.jpg',
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: dummyCastData.length,
        itemBuilder: (context, index) {
          final cast = dummyCastData[index];

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
                      imageUrl: cast['profile'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surface,
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cast['name'],
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    // Menampilkan loading state jika data masih diambil
    if (_loadingSimilar) {
      return Container(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Menampilkan pesan error jika gagal mengambil data
    if (_errorSimilar != null) {
      return Container(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              SizedBox(height: 8),
              Text(
                "Gagal memuat film serupa",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  if (_film != null) {
                    _fetchSimilarMovies(_film!.id);
                  }
                },
                child: Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    if (_similarMovies.isEmpty) {
      return Container(
        height: 150,
        child: Center(
          child: Text(
            "Tidak ada film serupa yang ditemukan",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220, // Menambah tinggi container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: _similarMovies.length,
        itemBuilder: (context, index) {
          final film = _similarMovies[index];
          final rating = film.rating;
          final formattedRating = rating.toStringAsFixed(1);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailFilmPage(),
                        settings: RouteSettings(
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
                        ),
                      ),
                    );
                  },
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
                              imageUrl: film.posterUrl,
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
                                film.title,
                                style: AppTextStyles.bodyBold.copyWith(
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Rating
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
                    'https://cdn-icons-png.flaticon.com/512/9582/9582626.png',
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
