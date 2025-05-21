import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serfilm/models/film_model.dart';
import 'package:serfilm/models/cast_model.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class TMDBService {
  final String baseUrl = "http://192.168.1.21:8000/api";
  final String imageBaseUrl = "https://image.tmdb.org/t/p";
  String? _authToken;
  bool _isRetryingRequest = false; // Flag untuk mencegah retry berulang

  // Setter untuk token autentikasi
  void setAuthToken(String token) {
    _authToken = token;
    // Memastikan token dimulai dengan 'Bearer ' jika belum
    if (token.isNotEmpty && !token.startsWith('Bearer ')) {
      _authToken = 'Bearer $token';
    }
    debugPrint(
      'Token autentikasi telah diset: ${_authToken!.length > 20 ? _authToken!.substring(0, 20) + "..." : _authToken}',
    );
  }

  // Headers dengan autentikasi jika tersedia
  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = _authToken!;
      debugPrint('Menggunakan token untuk request API');
    }
    return headers;
  }

  // Headers untuk API recommendation (selalu dengan autentikasi)
  Map<String, String> get _recommendationHeaders {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = _authToken!;
      debugPrint('Menggunakan token untuk request API recommendation');
    } else {
      throw Exception('Token autentikasi diperlukan untuk API recommendation');
    }
    return headers;
  }

  // Helper method untuk retry request API
  Future<http.Response> _getWithRetry(
    Uri uri,
    Map<String, String> headers, {
    int maxRetries = 2,
  }) async {
    if (_isRetryingRequest) {
      debugPrint('Sudah melakukan retry, menghindari loop retry');
      return await http.get(uri, headers: headers);
    }

    _isRetryingRequest = true;
    int retryCount = 0;
    late http.Response response;

    try {
      while (retryCount <= maxRetries) {
        try {
          response = await http.get(uri, headers: headers);

          // Jika sukses, keluar dari loop
          if (response.statusCode == 200) {
            break;
          }

          // Jika gagal karena unauthorized (401), coba lagi dengan headers yang sama
          if (response.statusCode == 401 && _authToken != null) {
            debugPrint(
              'API Unauthorized (401), retry dengan token yang sama: ${retryCount + 1}/$maxRetries',
            );
          } else {
            // Status code lain
            debugPrint(
              'API error status code: ${response.statusCode}, retry: ${retryCount + 1}/$maxRetries',
            );
          }

          retryCount++;

          if (retryCount <= maxRetries) {
            // Tunggu sebelum retry (increasing delay)
            await Future.delayed(Duration(seconds: retryCount));
          }
        } catch (e) {
          debugPrint(
            'Exception pada request: $e, retry: ${retryCount + 1}/$maxRetries',
          );
          retryCount++;

          if (retryCount <= maxRetries) {
            await Future.delayed(Duration(seconds: retryCount));
          } else {
            rethrow; // Gagal setelah semua retry
          }
        }
      }

      _isRetryingRequest = false;
      return response;
    } finally {
      _isRetryingRequest = false;
    }
  }

  // Pencarian film
  Future<List<Film>> searchMovies(String query) async {
    debugPrint('Mencari film dengan query: $query');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tmdb/search?query=$query'),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          'Berhasil mendapatkan ${data['data']['results'].length} hasil pencarian film',
        );
        final List<dynamic> results = data['data']['results'];
        return results.map((item) => Film.fromJson(item)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Gagal mencari film: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception dalam searchMovies: $e');
      throw Exception('Error saat mencari film: $e');
    }
  }

  // Mendapatkan detail film berdasarkan ID
  Future<Film> getMovieDetails(int tmdbId) async {
    debugPrint('Mengambil detail film ID: $tmdbId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tmdb/movie/$tmdbId'),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final item = jsonDecode(response.body)['data'];
        debugPrint('Berhasil mendapatkan detail film: ${item['title']}');
        return Film.fromJson(item);
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Gagal mengambil detail film: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception dalam getMovieDetails: $e');
      throw Exception('Error saat mengambil detail film: $e');
    }
  }

  // Mendapatkan film trending
  Future<List<Film>> getTrendingMovies() async {
    debugPrint('Mengambil film trending');
    try {
      final uri = Uri.parse('$baseUrl/recommendation/trending');
      debugPrint('URI request: $uri');
      final response = await _getWithRetry(uri, _headers);

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['results'] == null) {
          debugPrint(
            'Data trending tidak valid: ${response.body.substring(0, 100)}...',
          );
          throw Exception('Format data trending tidak valid');
        }
        debugPrint(
          'Berhasil mendapatkan ${data['data']['results'].length} film trending',
        );
        final List<dynamic> results = data['data']['results'];
        return results.map((item) => Film.fromJson(item)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception(
          'Gagal mengambil film trending: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception dalam getTrendingMovies: $e');
      throw Exception('Error saat mengambil film trending: $e');
    }
  }

  // Mendapatkan film populer
  Future<List<Film>> getPopularMovies() async {
    debugPrint('Mengambil film populer');
    try {
      final uri = Uri.parse('$baseUrl/recommendation/popular');
      debugPrint('URI request: $uri');
      final response = await _getWithRetry(uri, _headers);

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['results'] == null) {
          debugPrint(
            'Data populer tidak valid: ${response.body.substring(0, 100)}...',
          );
          throw Exception('Format data populer tidak valid');
        }
        debugPrint(
          'Berhasil mendapatkan ${data['data']['results'].length} film populer',
        );
        final List<dynamic> results = data['data']['results'];
        return results.map((item) => Film.fromJson(item)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Gagal mengambil film populer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception dalam getPopularMovies: $e');
      throw Exception('Error saat mengambil film populer: $e');
    }
  }

  // Mendapatkan film dengan rating tertinggi
  Future<List<Film>> getTopRatedMovies() async {
    debugPrint('Mengambil film top rated');
    try {
      final uri = Uri.parse('$baseUrl/recommendation/top-rated');
      debugPrint('URI request: $uri');
      final response = await _getWithRetry(uri, _headers);

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] == null || data['data']['results'] == null) {
          debugPrint(
            'Data top rated tidak valid: ${response.body.substring(0, 100)}...',
          );
          throw Exception('Format data top rated tidak valid');
        }
        debugPrint(
          'Berhasil mendapatkan ${data['data']['results'].length} film top rated',
        );
        final List<dynamic> results = data['data']['results'];
        return results.map((item) => Film.fromJson(item)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception(
          'Gagal mengambil film top rated: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception dalam getTopRatedMovies: $e');
      throw Exception('Error saat mengambil film top rated: $e');
    }
  }

  // Mendapatkan film serupa
  Future<List<Film>> getSimilarMovies(int tmdbId) async {
    debugPrint('Mengambil film serupa untuk ID: $tmdbId');
    try {
      // Memeriksa apakah token autentikasi tersedia
      if (_authToken == null) {
        debugPrint(
          'Token autentikasi tidak tersedia, menggunakan fallback data',
        );
        // Gunakan film populer sebagai fallback jika tidak ada token auth
        return await getPopularMovies();
      }

      // Menggunakan metode GET dengan query parameter
      final uri = Uri.parse(
        '$baseUrl/recommendation/similar?tmdb_movie_id=$tmdbId',
      );
      debugPrint('URI request: $uri');

      // Pastikan menggunakan header dengan autentikasi
      final response = await _getWithRetry(uri, _recommendationHeaders);

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Log struktur data untuk debugging
        debugPrint('Struktur data similar: ${data.runtimeType}');

        // Menangani berbagai kemungkinan struktur respons
        List<dynamic> results;

        if (data['data'] != null) {
          if (data['data']['results'] != null &&
              data['data']['results'] is List) {
            results = data['data']['results'];
            debugPrint('Menggunakan data.results: ${results.length} items');
          } else if (data['data'] is List) {
            results = data['data'];
            debugPrint('Menggunakan data langsung: ${results.length} items');
          } else {
            debugPrint(
              'Format data tidak dikenali: ${data['data'].runtimeType}',
            );
            // Gunakan film populer sebagai fallback
            return await getPopularMovies();
          }
        } else if (data['results'] != null && data['results'] is List) {
          results = data['results'];
          debugPrint('Menggunakan results langsung: ${results.length} items');
        } else {
          debugPrint('Tidak ada hasil yang valid dalam respons');
          // Gunakan film populer sebagai fallback
          return await getPopularMovies();
        }

        // Parse hasil menjadi objek Film
        return results.map((item) => Film.fromJson(item)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        // Gunakan film populer sebagai fallback
        return await getPopularMovies();
      }
    } catch (e) {
      debugPrint('Exception dalam getSimilarMovies: $e');
      // Gunakan film populer sebagai fallback
      return await getPopularMovies();
    }
  }

  // Mendapatkan rekomendasi berdasarkan watchlist pengguna
  Future<List<Film>> getRecommendationsBasedOnWatchlist() async {
    debugPrint('Mengambil rekomendasi berdasarkan watchlist');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommendation'),
        headers: _recommendationHeaders,
      );

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']['results'] != null) {
          debugPrint(
            'Berhasil mendapatkan ${data['data']['results'].length} rekomendasi film',
          );
          final List<dynamic> results = data['data']['results'];
          return results.map((item) => Film.fromJson(item)).toList();
        } else if (data['data'] is List) {
          debugPrint(
            'Berhasil mendapatkan ${data['data'].length} rekomendasi film',
          );
          final List<dynamic> results = data['data'];
          return results.map((item) => Film.fromJson(item)).toList();
        } else {
          debugPrint('Tidak ada rekomendasi yang ditemukan');
          return [];
        }
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Gagal mengambil rekomendasi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception dalam getRecommendationsBasedOnWatchlist: $e');
      throw Exception('Error saat mengambil rekomendasi: $e');
    }
  }

  // Mendapatkan daftar genre
  Future<List<Map<String, dynamic>>> getGenres() async {
    debugPrint('Mengambil daftar genre');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tmdb/genres'),
        headers: _headers,
      );

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Berhasil mendapatkan daftar genre');
        final List<dynamic> results = data['data']['genres'];
        return results.map((item) => item as Map<String, dynamic>).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Gagal mengambil daftar genre: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception dalam getGenres: $e');
      throw Exception('Error saat mengambil daftar genre: $e');
    }
  }

  // Mendapatkan data cast film berdasarkan ID film
  Future<List<CastMember>> getMovieCast(int movieId) async {
    debugPrint('Mengambil data cast untuk film ID: $movieId');
    try {
      final uri = Uri.parse('$baseUrl/movies/$movieId/credits');
      debugPrint('URI request: $uri');
      final response = await _getWithRetry(uri, _headers);

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Log respons untuk debug
        debugPrint('Struktur respons cast: ${data.runtimeType}');

        // Cek struktur data yang diterima
        if (data['data'] == null) {
          debugPrint(
            'Data cast tidak valid: ${response.body.substring(0, 100)}...',
          );
          throw Exception('Format data cast tidak valid - data is null');
        }

        List<dynamic> castData;

        // Handle kedua kemungkinan: data['data'] bisa jadi List atau Map
        if (data['data'] is List) {
          // Jika data['data'] sudah berupa List, gunakan langsung
          castData = data['data'];
        } else if (data['data'] is Map) {
          // Jika data['data'] berupa Map, periksa apakah ada kunci 'cast'
          final mapData = data['data'] as Map<String, dynamic>;

          if (mapData.containsKey('cast') && mapData['cast'] is List) {
            castData = mapData['cast'];
          } else if (mapData.containsKey('results') &&
              mapData['results'] is List) {
            castData = mapData['results'];
          } else {
            // Jika tidak menemukan struktur yang diharapkan, log lebih detail
            debugPrint('Struktur data tidak sesuai: $mapData');
            throw Exception(
              'Format data cast tidak valid - unexpected structure',
            );
          }
        } else {
          debugPrint('Tipe data tidak didukung: ${data['data'].runtimeType}');
          throw Exception(
            'Format data cast tidak valid - unsupported data type',
          );
        }

        debugPrint('Berhasil mendapatkan ${castData.length} anggota cast');

        return castData.map((item) => CastMember.fromJson(item)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception('Gagal mengambil data cast: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception dalam getMovieCast: $e');
      throw Exception('Error saat mengambil data cast: $e');
    }
  }
}
