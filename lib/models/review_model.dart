class Review {
  final int id;
  final int tmdbId;
  final String username;
  final double rating;
  final String? comment;
  final String createdAt;

  Review({
    required this.id,
    required this.tmdbId,
    required this.username,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      tmdbId: json['tmdb_movie_id'] ?? 0,
      username: json['user']['name'] ?? 'Pengguna',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? 'N/A',
    );
  }
}
