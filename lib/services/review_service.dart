// lib/services/review_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/review_model.dart';

class ReviewService {
  String _baseUrl = 'http://192.168.1.21:8000/api';
  late String? _token;

  void setAuthToken(String token) {
    _token = 'Bearer $token';
  }

  Future<List<Review>> getReviewsForMovie(int tmdbId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/reviews?tmdb_movie_id=$tmdbId'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['data'];
      return results.map((item) => Review.fromJson(item)).toList();
    } else {
      throw Exception("Gagal mengambil ulasan");
    }
  }

  Future<Review> addReview(int tmdbId, double rating, String? comment) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reviews'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
      body: jsonEncode({
        'tmdb_movie_id': tmdbId,
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body)['data'];
      return Review.fromJson(json);
    } else {
      final error = jsonDecode(response.body)['meta']['message'];
      throw Exception(error);
    }
  }

  Future<void> updateReview(
    int reviewId,
    double newRating,
    String? newComment,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/reviews/$reviewId'),
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': _token!,
      },
      body: jsonEncode({'rating': newRating, 'comment': newComment ?? ''}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body)['meta']['message'];
      throw Exception(error);
    }
  }

  Future<void> deleteReview(int reviewId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/reviews/$reviewId'),
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
