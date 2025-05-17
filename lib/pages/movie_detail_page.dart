import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/models/watchlist.dart';
import 'package:serfilm/services/tmdb_service.dart';
import 'package:serfilm/widgets/cast_list.dart';
import 'package:serfilm/widgets/loading_indicator.dart';
import 'package:serfilm/pages/reviews_page.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final TMDBService _tmdbService = TMDBService();
  MovieDetails? _movieDetails;
  bool _isLoading = true;
  String? _error;
  bool _isInWatchlist = false;
  WatchStatus _watchStatus = WatchStatus.unwatched;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
    _checkWatchlistStatus();
  }

  Future<void> _loadMovieDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final details = await _tmdbService.fetchMovieDetails(widget.movieId);
      setState(() {
        _movieDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load movie details';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkWatchlistStatus() async {
    // TODO: Implementasi dengan service asli
    // Ini hanya contoh, nantinya harus diambil dari provider atau service
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isInWatchlist = false;
    });
  }

  void _toggleWatchlist(WatchStatus status) {
    // TODO: Implementasi dengan service asli
    setState(() {
      _isInWatchlist = true;
      _watchStatus = status;
    });

    String message =
        status == WatchStatus.watched
            ? 'Film ditandai sebagai sudah ditonton'
            : 'Film ditambahkan ke watchlist';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openReviews() {
    if (_movieDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ReviewsPage(
                movieId: _movieDetails!.id,
                movieTitle: _movieDetails!.title,
                moviePoster: _movieDetails!.posterPath,
              ),
        ),
      );
    }
  }

  void _openTrailer() async {
    if (_movieDetails == null) return;

    final trailerVideo = _movieDetails!.videos.results.firstWhere(
      (video) => video.type == 'Trailer' && video.site == 'YouTube',
      orElse: () => Video(id: '', key: '', name: '', site: '', type: ''),
    );

    if (trailerVideo.key.isNotEmpty) {
      final url = Uri.parse(
        'https://www.youtube.com/watch?v=${trailerVideo.key}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  String _formatCurrency(int amount) {
    if (amount == 0) return 'N/A';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }

  String _formatRuntime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!),
                    ElevatedButton(
                      onPressed: _loadMovieDetails,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(child: _buildMovieOverview()),
                  SliverToBoxAdapter(child: _buildActionButtons()),
                  SliverToBoxAdapter(child: _buildMovieStats()),
                  SliverToBoxAdapter(child: _buildCastSection()),
                ],
              ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title:
            _movieDetails != null
                ? Text(
                  _movieDetails!.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10.0, color: Colors.black)],
                  ),
                )
                : null,
        background:
            _movieDetails != null
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _tmdbService.getImageUrl(
                        _movieDetails!.backdropPath,
                        size: 'original',
                      ),
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.error),
                          ),
                    ),
                    // Gradient overlay for better text visibility
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                            Colors.black87,
                          ],
                          stops: [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ],
                )
                : Container(color: Colors.grey[900]),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share movie functionality
          },
        ),
      ],
    );
  }

  Widget _buildMovieOverview() {
    if (_movieDetails == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Release year and runtime
          Row(
            children: [
              Text(
                DateFormat('yyyy').format(
                  DateTime.tryParse(_movieDetails!.releaseDate) ??
                      DateTime.now(),
                ),
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(width: 16),
              Text(
                _formatRuntime(_movieDetails!.runtime),
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              RatingBar.builder(
                initialRating: _movieDetails!.voteAverage / 2,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 20,
                ignoreGestures: true,
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (_) {},
              ),
              const SizedBox(width: 8),
              Text(
                '${_movieDetails!.voteAverage.toStringAsFixed(1)}/10',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Genres
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _movieDetails!.genres.map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 24),

          // Tagline
          if (_movieDetails!.tagline.isNotEmpty) ...[
            Text(
              _movieDetails!.tagline,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Overview title
          const Text(
            'Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Overview
          Text(
            _movieDetails!.overview,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_movieDetails == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Watch trailer button
          if (_movieDetails!.videos.results.any((v) => v.type == 'Trailer'))
            ElevatedButton.icon(
              onPressed: _openTrailer,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Watch Trailer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

          const SizedBox(height: 12),

          // Watchlist and Review buttons
          Row(
            children: [
              // Watchlist button
              Expanded(
                child: PopupMenuButton<WatchStatus>(
                  onSelected: _toggleWatchlist,
                  offset: const Offset(0, 40),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: WatchStatus.unwatched,
                          child: Row(
                            children: [
                              Icon(
                                Icons.bookmark,
                                size: 18,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              const Text('Tambahkan ke Watchlist'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: WatchStatus.watched,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text('Tandai Sudah Ditonton'),
                            ],
                          ),
                        ),
                      ],
                  child: ElevatedButton.icon(
                    onPressed:
                        null, // Dikosongkan karena sudah ditangani oleh popup
                    icon: Icon(
                      _isInWatchlist
                          ? (_watchStatus == WatchStatus.watched
                              ? Icons.check_circle
                              : Icons.bookmark)
                          : Icons.bookmark_add_outlined,
                      color:
                          _isInWatchlist
                              ? Theme.of(context).colorScheme.primary
                              : null,
                    ),
                    label: Text(
                      _isInWatchlist
                          ? 'Dalam Watchlist'
                          : 'Tambah ke Watchlist',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Review button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openReviews,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Lihat Ulasan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMovieStats() {
    if (_movieDetails == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movie Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Status', _movieDetails!.status),
          _buildInfoRow('Budget', _formatCurrency(_movieDetails!.budget)),
          _buildInfoRow('Revenue', _formatCurrency(_movieDetails!.revenue)),
          _buildInfoRow(
            'Release Date',
            DateFormat.yMMMMd().format(
              DateTime.tryParse(_movieDetails!.releaseDate) ?? DateTime.now(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection() {
    if (_movieDetails == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cast',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CastList(
            cast: _movieDetails!.credits.cast.take(10).toList(),
            imageBaseUrl: _tmdbService.getImageUrl,
          ),
        ],
      ),
    );
  }
}
