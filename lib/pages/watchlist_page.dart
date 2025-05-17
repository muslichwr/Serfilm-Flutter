import 'package:flutter/material.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/models/watchlist.dart';
import 'package:serfilm/services/tmdb_service.dart';
import 'package:serfilm/widgets/movie_card.dart';
import 'package:serfilm/widgets/watchlist_grid.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header watchlist
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          width: double.infinity,
          child: Text(
            'My Watchlist',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Filter chips untuk memilih status film dengan tema yang sesuai
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
                backgroundColor: Theme.of(context).cardColor,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color:
                      _selectedFilter == WatchStatus.unwatched
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                  fontWeight:
                      _selectedFilter == WatchStatus.unwatched
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                selected: _selectedFilter == WatchStatus.watched,
                label: const Text('Watched'),
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = WatchStatus.watched;
                  });
                },
                backgroundColor: Theme.of(context).cardColor,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(
                  color:
                      _selectedFilter == WatchStatus.watched
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                  fontWeight:
                      _selectedFilter == WatchStatus.watched
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        // Grid watchlist
        Container(
          height: 600, // Lebih tinggi agar bisa menampung lebih banyak film
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _refresh,
                    color: Theme.of(context).colorScheme.primary,
                    child: WatchlistGrid(
                      filtered: filtered,
                      movies: _movies,
                      onStatusChange: _handleStatusChange,
                    ),
                  ),
        ),
      ],
    );
  }
}
