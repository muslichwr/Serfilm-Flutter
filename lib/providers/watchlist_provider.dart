import 'package:flutter/foundation.dart';
import '../models/watchlist_model.dart';
import '../services/watchlist_service.dart';

class WatchlistProvider with ChangeNotifier {
  final WatchlistService _service = WatchlistService();

  bool _loading = false;
  List<WatchlistModel> _films = [];

  bool get isLoading => _loading;
  List<WatchlistModel> get watchlist => _films;

  void setAuthToken(String token) {
    _service.setAuthToken(token);
  }

  Future<void> fetchWatchlist() async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _service.getWatchlist();
      _films = result;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      debugPrint("Gagal mengambil watchlist: $e");
      notifyListeners();
      throw e;
    }
  }

  Future<void> addToWatchlist(int tmdbId, String status) async {
    _loading = true;
    notifyListeners();

    try {
      final film = await _service.addFilmToWatchlist(tmdbId, status);
      _films.insert(0, film);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      debugPrint("Gagal menambahkan ke watchlist: $e");
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateStatus(int watchlistId, String newStatus) async {
    final int index = _films.indexWhere((f) => f.id == watchlistId);
    if (index == -1) return;

    final WatchlistModel oldFilm = _films[index];
    final String oldStatus = oldFilm.status;

    // Buat instance baru dengan status yang diperbarui
    final WatchlistModel updatedFilm = WatchlistModel(
      id: oldFilm.id,
      tmdbId: oldFilm.tmdbId,
      title: oldFilm.title,
      posterUrl: oldFilm.posterUrl,
      status: newStatus,
      overview: oldFilm.overview,
      releaseDate: oldFilm.releaseDate,
      rating: oldFilm.rating,
    );

    // Update model dalam daftar
    _films[index] = updatedFilm;
    notifyListeners();

    // Kirim ke backend
    try {
      await _service.updateStatus(watchlistId, newStatus);
    } catch (e) {
      // Kembalikan ke status sebelumnya jika gagal
      final WatchlistModel revertedFilm = WatchlistModel(
        id: oldFilm.id,
        tmdbId: oldFilm.tmdbId,
        title: oldFilm.title,
        posterUrl: oldFilm.posterUrl,
        status: oldStatus,
        overview: oldFilm.overview,
        releaseDate: oldFilm.releaseDate,
        rating: oldFilm.rating,
      );

      _films[index] = revertedFilm;
      debugPrint("Gagal update status: $e");
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int watchlistId) async {
    final oldList = List<WatchlistModel>.from(_films);
    final idx = _films.indexWhere((film) => film.id == watchlistId);

    if (idx >= 0) {
      _films.removeAt(idx);
      notifyListeners();

      try {
        await _service.removeFilmFromWatchlist(watchlistId);
      } catch (e) {
        _films = oldList;
        debugPrint("Gagal menghapus dari watchlist: $e");
        notifyListeners();
      }
    }
  }
}
