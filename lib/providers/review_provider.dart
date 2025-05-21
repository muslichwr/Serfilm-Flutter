import 'package:flutter/material.dart';
import '../services/review_service.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();

  bool _loading = false;
  List<Review> _reviews = [];

  bool get isLoading => _loading;
  List<Review> get userReviews => _reviews;

  void setAuthToken(String token) {
    _service.setAuthToken(token);
  }

  Future<void> fetchReviews(int tmdbId) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _service.getReviewsForMovie(tmdbId);
      _reviews = result;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      debugPrint("Gagal mengambil ulasan: $e");
      notifyListeners();
      throw e;
    }
  }

  Future<void> submitReview(int tmdbId, double rating, String? comment) async {
    _loading = true;
    notifyListeners();

    try {
      final newReview = await _service.addReview(tmdbId, rating, comment);
      _reviews.insert(0, newReview);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      debugPrint("Gagal menambahkan ulasan: $e");
      notifyListeners();
      throw e;
    }
  }

  Future<void> editReview(
    int reviewId,
    double newRating,
    String? newComment,
  ) async {
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx < 0) return;

    // Simpan nilai sebelumnya untuk rollback jika gagal
    final oldReview = _reviews[idx];
    _reviews[idx] = Review(
      id: oldReview.id,
      tmdbId: oldReview.tmdbId,
      username: oldReview.username,
      rating: newRating,
      comment: newComment,
      createdAt: oldReview.createdAt,
    );
    notifyListeners();

    try {
      await _service.updateReview(reviewId, newRating, newComment);
      notifyListeners();
    } catch (e) {
      _reviews[idx] = oldReview;
      debugPrint("Gagal mengupdate ulasan: $e");
      notifyListeners();
      throw e;
    }
  }

  Future<void> removeReview(int reviewId) async {
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx < 0) return;

    final removed = _reviews.removeAt(idx);
    notifyListeners();

    try {
      await _service.deleteReview(reviewId);
    } catch (e) {
      _reviews.insert(idx, removed);
      debugPrint("Gagal menghapus ulasan: $e");
      notifyListeners();
      throw e;
    }
  }
}
