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
      case 'reviews':
      case 'watchlist':
      case 'profile':
        return []; // Kategori yang menggunakan tampilan kustom
      default:
        return _trendingMovies;
    }
  }

  List<Genre> get genres => _genres;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  Genre? get selectedGenre => _selectedGenre;

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
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _selectedGenre = null;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
