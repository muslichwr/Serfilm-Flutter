import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '../models/watchlist_model.dart';

class WatchlistService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'https://your-api.com/api ';
  late String? _token;

  void setAuthToken(String token) {
    _token = token;
  }

  Future<List<WatchlistModel>> getWatchlist({int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/watchlist'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['data'];
      return results.map((item) => WatchlistModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data watchlist: ${response.body}');
    }
  }

  Future<WatchlistModel> addFilmToWatchlist(int tmdbId, String status) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/watchlist'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
      body: jsonEncode({'tmdb_movie_id': tmdbId, 'status': status}),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body)['data'];
      return WatchlistModel.fromJson(json);
    } else {
      final error = jsonDecode(response.body)['meta']['message'];
      throw Exception(error);
    }
  }

  Future<void> updateStatus(int watchlistId, String newStatus) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/watchlist/$watchlistId'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['meta']['message'];
      throw Exception(error);
    }
  }

  Future<void> removeFilmFromWatchlist(int watchlistId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/watchlist/$watchlistId'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['meta']['message'];
      throw Exception(error);
    }
  }
}
