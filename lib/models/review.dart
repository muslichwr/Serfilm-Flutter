/// Model review film oleh user
class Review {
  final String id;
  final int movieId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  /// Membuat Review dari JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      movieId: json['movie_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  /// Konversi Review ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Membuat salinan Review dengan perubahan tertentu
  Review copyWith({
    String? id,
    int? movieId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          movieId == other.movieId &&
          userId == other.userId &&
          userName == other.userName &&
          rating == other.rating &&
          comment == other.comment &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      movieId.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      rating.hashCode ^
      comment.hashCode ^
      createdAt.hashCode ^
      (updatedAt?.hashCode ?? 0);
}
