import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serfilm/models/genre.dart';
import 'package:serfilm/models/movie.dart';
// import 'package:serfilm/utils/constants.dart';

class TMDBService {
  // You should store your API key in a secure place and not hardcode it
  final String _apiKey = 'ce1e0471c0dfc761decbc0523d65398a';
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _imageBaseUrl = 'https://image.tmdb.org/t/p';

  String getImageUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    return '$_imageBaseUrl/$size$path';
  }

  Future<List<Movie>> fetchTrending() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/trending/movie/day?api_key=$_apiKey&language=en-US',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        throw Exception('Failed to load trending movies');
      }
    } catch (e) {
      print('Error fetching trending movies: $e');
      return [];
    }
  }

  Future<List<Movie>> fetchPopular() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        throw Exception('Failed to load popular movies');
      }
    } catch (e) {
      print('Error fetching popular movies: $e');
      return [];
    }
  }

  Future<List<Movie>> fetchTopRated() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=en-US&page=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        throw Exception('Failed to load top rated movies');
      }
    } catch (e) {
      print('Error fetching top rated movies: $e');
      return [];
    }
  }

  Future<List<Genre>> fetchGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=en-US'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['genres'] as List)
            .map((genre) => Genre.fromJson(genre))
            .toList();
      } else {
        throw Exception('Failed to load genres');
      }
    } catch (e) {
      print('Error fetching genres: $e');
      return [];
    }
  }

  Future<MovieDetails?> fetchMovieDetails(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=credits,videos',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MovieDetails.fromJson(data);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      print('Error fetching movie details: $e');
      return null;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=${Uri.encodeComponent(query)}&page=1&include_adult=false',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=en-US&sort_by=popularity.desc&with_genres=$genreId&page=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['results'] as List)
            .map((movie) => Movie.fromJson(movie))
            .toList();
      } else {
        throw Exception('Failed to load movies by genre');
      }
    } catch (e) {
      print('Error fetching movies by genre: $e');
      return [];
    }
  }
}
