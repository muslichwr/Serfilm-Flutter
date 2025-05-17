import 'package:flutter/material.dart';
import 'package:serfilm/models/genre.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/services/tmdb_service.dart';

class MovieProvider extends ChangeNotifier {
  final TMDBService _tmdbService;

  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _genreMovies = [];
  List<Genre> _genres = [];
  List<Movie> _wishlist = [];

  String _selectedCategory = 'trending';
  Genre? _selectedGenre;
  bool _isLoading = false;
  String? _error;

  MovieProvider(this._tmdbService);

  List<Movie> get movies {
    switch (_selectedCategory) {
      case 'trending':
        return _trendingMovies;
      case 'popular':
        return _popularMovies;
      case 'top_rated':
        return _topRatedMovies;
      case 'search':
        return _searchResults;
      case 'genre':
        return _genreMovies;
      case 'wishlist':
        return _wishlist;
      default:
        return _trendingMovies;
    }
  }

  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  Genre? get selectedGenre => _selectedGenre;
  List<Movie> get wishlist => _wishlist;

  Future<void> loadInitialData() async {
    _setLoading(true);
    try {
      await Future.wait([
        _fetchTrending(),
        _fetchPopular(),
        _fetchTopRated(),
        _fetchGenres(),
      ]);
    } catch (e) {
      _setError('Failed to load initial data');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    _setLoading(true);
    try {
      switch (_selectedCategory) {
        case 'trending':
          await _fetchTrending();
          break;
        case 'popular':
          await _fetchPopular();
          break;
        case 'top_rated':
          await _fetchTopRated();
          break;
        case 'genre':
          if (_selectedGenre != null) {
            await fetchMoviesByGenre(_selectedGenre!.id);
          }
          break;
      }
    } catch (e) {
      _setError('Failed to refresh data');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchTrending() async {
    try {
      final movies = await _tmdbService.fetchTrending();
      _trendingMovies = movies;
      if (_selectedCategory == 'trending') {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to fetch trending movies');
    }
  }

  Future<void> _fetchPopular() async {
    try {
      final movies = await _tmdbService.fetchPopular();
      _popularMovies = movies;
      if (_selectedCategory == 'popular') {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to fetch popular movies');
    }
  }

  Future<void> _fetchTopRated() async {
    try {
      final movies = await _tmdbService.fetchTopRated();
      _topRatedMovies = movies;
      if (_selectedCategory == 'top_rated') {
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to fetch top rated movies');
    }
  }

  Future<void> _fetchGenres() async {
    try {
      final genres = await _tmdbService.fetchGenres();
      _genres = genres;
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch genres');
    }
  }

  Future<void> searchMovies(String query) async {
    _setLoading(true);
    _selectedCategory = 'search';
    try {
      final movies = await _tmdbService.searchMovies(query);
      _searchResults = movies;
    } catch (e) {
      _setError('Failed to search movies');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMoviesByGenre(int genreId) async {
    _setLoading(true);
    _selectedCategory = 'genre';
    _selectedGenre = _genres.firstWhere((genre) => genre.id == genreId);
    try {
      final movies = await _tmdbService.fetchMoviesByGenre(genreId);
      _genreMovies = movies;
    } catch (e) {
      _setError('Failed to fetch movies by genre');
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _selectedGenre = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void addToWishlist(Movie movie) {
    if (!_wishlist.any((m) => m.id == movie.id)) {
      _wishlist.add(movie);
      notifyListeners();
    }
  }

  void removeFromWishlist(Movie movie) {
    _wishlist.removeWhere((m) => m.id == movie.id);
    notifyListeners();
  }

  // Toggle status sudah ditonton (watched/none)
  void toggleWatched(Movie movie) {
    final idx = _findMovieIndex(movie);
    if (idx != null) {
      final newStatus =
          movie.watchStatus == MovieWatchStatus.watched
              ? MovieWatchStatus.none
              : MovieWatchStatus.watched;
      _updateMovie(idx, movie.copyWith(watchStatus: newStatus));
      notifyListeners();
    }
  }

  // Toggle status ingin ditonton (toWatch/none)
  void toggleToWatch(Movie movie) {
    final idx = _findMovieIndex(movie);
    if (idx != null) {
      final newStatus =
          movie.watchStatus == MovieWatchStatus.toWatch
              ? MovieWatchStatus.none
              : MovieWatchStatus.toWatch;
      _updateMovie(idx, movie.copyWith(watchStatus: newStatus));
      notifyListeners();
    }
  }

  // Set rating pribadi
  void setPersonalRating(Movie movie, double rating) {
    final idx = _findMovieIndex(movie);
    if (idx != null) {
      _updateMovie(idx, movie.copyWith(personalRating: rating));
      notifyListeners();
    }
  }

  // Helper untuk mencari index movie di semua list
  int? _findMovieIndex(Movie movie) {
    final lists = [
      _trendingMovies,
      _popularMovies,
      _topRatedMovies,
      _genreMovies,
      _wishlist,
    ];
    for (final list in lists) {
      final idx = list.indexWhere((m) => m.id == movie.id);
      if (idx != -1) return idx;
    }
    return null;
  }

  // Helper update movie di semua list
  void _updateMovie(int idx, Movie newMovie) {
    final lists = [
      _trendingMovies,
      _popularMovies,
      _topRatedMovies,
      _genreMovies,
      _wishlist,
    ];
    for (final list in lists) {
      final i = list.indexWhere((m) => m.id == newMovie.id);
      if (i != -1) list[i] = newMovie;
    }
  }
}
