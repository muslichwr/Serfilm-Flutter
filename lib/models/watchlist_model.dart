// file: lib/models/watchlist_model.dart

class WatchlistModel {
  final int id;
  final int tmdbId;
  final String title;
  final String? posterUrl;
  final String status;
  final String? overview;
  final String? releaseDate;
  final double rating;

  WatchlistModel({
    required this.id,
    required this.tmdbId,
    required this.title,
    this.posterUrl,
    required this.status,
    this.overview,
    this.releaseDate,
    required this.rating,
  });

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      id: json['id'],
      tmdbId: json['tmdb_movie_id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      posterUrl: json['poster_url'],
      status: json['status'] ?? 'to_watch',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
