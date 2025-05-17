/// Status tontonan pada watchlist
enum WatchStatus { unwatched, watched }

extension WatchStatusExt on WatchStatus {
  String get asString => toString().split('.').last;
  static WatchStatus fromString(String value) {
    return WatchStatus.values.firstWhere(
      (e) => e.asString == value,
      orElse: () => WatchStatus.unwatched,
    );
  }
}

/// Model item watchlist
class WatchlistItem {
  final String id;
  final int movieId;
  final String userId;
  final WatchStatus status;
  final DateTime addedAt;
  final DateTime? watchedAt;

  WatchlistItem({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.status,
    required this.addedAt,
    this.watchedAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'],
      movieId: json['movie_id'],
      userId: json['user_id'],
      status: WatchStatusExt.fromString(json['status'] ?? ''),
      addedAt: DateTime.parse(json['added_at']),
      watchedAt:
          json['watched_at'] != null
              ? DateTime.parse(json['watched_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'user_id': userId,
      'status': status.asString,
      'added_at': addedAt.toIso8601String(),
      'watched_at': watchedAt?.toIso8601String(),
    };
  }

  /// Membuat salinan dengan perubahan tertentu
  WatchlistItem copyWith({
    String? id,
    int? movieId,
    String? userId,
    WatchStatus? status,
    DateTime? addedAt,
    DateTime? watchedAt,
  }) {
    return WatchlistItem(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      watchedAt: watchedAt ?? this.watchedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          movieId == other.movieId &&
          userId == other.userId &&
          status == other.status &&
          addedAt == other.addedAt &&
          watchedAt == other.watchedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      movieId.hashCode ^
      userId.hashCode ^
      status.hashCode ^
      addedAt.hashCode ^
      (watchedAt?.hashCode ?? 0);
}
