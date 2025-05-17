import 'package:flutter/material.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/models/watchlist.dart';
import 'package:serfilm/services/tmdb_service.dart';
import 'package:serfilm/widgets/movie_card.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final TMDBService _tmdbService = TMDBService();
  WatchStatus _selectedFilter = WatchStatus.unwatched;
  bool _isLoading = false;
  List<WatchlistItem> _watchlist = [];
  Map<int, Movie> _movies = {};

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() => _isLoading = true);

    try {
      // Dummy data
      await Future.delayed(const Duration(seconds: 1));
      final dummy = [
        WatchlistItem(
          id: '1',
          movieId: 101,
          userId: 'u1',
          status: WatchStatus.unwatched,
          addedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        WatchlistItem(
          id: '2',
          movieId: 102,
          userId: 'u1',
          status: WatchStatus.watched,
          addedAt: DateTime.now().subtract(const Duration(days: 5)),
          watchedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      // Dummy movie
      final dummyMovies = {
        101: Movie(
          id: 101,
          title: 'Dummy Movie 1',
          posterPath: '',
          overview: 'Overview 1',
          releaseDate: '2023-01-01',
          voteAverage: 7.5,
          genreIds: const [1, 2],
          popularity: 100.0,
        ),
        102: Movie(
          id: 102,
          title: 'Dummy Movie 2',
          posterPath: '',
          overview: 'Overview 2',
          releaseDate: '2023-02-01',
          voteAverage: 8.2,
          genreIds: const [2, 3],
          popularity: 80.0,
        ),
      };
      setState(() {
        _isLoading = false;
        _watchlist = dummy;
        _movies = dummyMovies;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat watchlist: $e')));
    }
  }

  void _handleStatusChange(WatchlistItem item, WatchStatus newStatus) {
    setState(() {
      _watchlist =
          _watchlist.map((w) {
            if (w.id == item.id) {
              return w.copyWith(
                status: newStatus,
                watchedAt:
                    newStatus == WatchStatus.watched ? DateTime.now() : null,
              );
            }
            return w;
          }).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Status diubah menjadi ${newStatus == WatchStatus.watched ? 'Watched' : 'Unwatched'}',
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await _loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _watchlist.where((w) => w.status == _selectedFilter).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Watchlist')),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                FilterChip(
                  selected: _selectedFilter == WatchStatus.unwatched,
                  label: const Text('Unwatched'),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = WatchStatus.unwatched;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  selected: _selectedFilter == WatchStatus.watched,
                  label: const Text('Watched'),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = WatchStatus.watched;
                    });
                  },
                ),
              ],
            ),
          ),

          // Watchlist grid
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _refresh,
                      child:
                          filtered.isEmpty
                              ? ListView(
                                children: [
                                  SizedBox(
                                    height: 300,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bookmark_border,
                                            size: 64,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Watchlist kosong',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.7,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final movie = _movies[item.movieId];

                                  if (movie == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return Stack(
                                    children: [
                                      MovieCard(
                                        movie: movie,
                                        onTap: () {
                                          // TODO: Navigate to movie detail
                                        },
                                        isWishlisted: true,
                                        onWishlistToggle: () {},
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: PopupMenuButton<WatchStatus>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Colors.white,
                                          ),
                                          onSelected:
                                              (status) => _handleStatusChange(
                                                item,
                                                status,
                                              ),
                                          itemBuilder:
                                              (context) => [
                                                const PopupMenuItem(
                                                  value: WatchStatus.unwatched,
                                                  child: Text(
                                                    'Mark as Unwatched',
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: WatchStatus.watched,
                                                  child: Text(
                                                    'Mark as Watched',
                                                  ),
                                                ),
                                              ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                    ),
          ),
        ],
      ),
    );
  }
}
