// file: models/film_model.dart

class Film {
  final int id;
  final String title;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final double rating;
  final String releaseDate;
  final List<String> genres;
  final bool adult;
  final String originalLanguage;

  Film({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.rating,
    this.releaseDate = '',
    this.genres = const [],
    this.adult = false,
    this.originalLanguage = '',
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    List<String> genresList = [];
    if (json['genre_ids'] != null && json['genre_ids'] is List) {
      genresList =
          (json['genre_ids'] as List).map((e) => e.toString()).toList();
    } else if (json['genres'] != null && json['genres'] is List) {
      genresList =
          (json['genres'] as List).map((e) => e['name'].toString()).toList();
    }

    return Film(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Tidak ada judul',
      overview: json['overview'] ?? '',
      posterUrl:
          json['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
              : json['poster_url'] ?? '',
      backdropUrl:
          json['backdrop_path'] != null
              ? 'https://image.tmdb.org/t/p/original${json['backdrop_path']}'
              : json['backdrop_url'] ?? '',
      rating:
          (json['vote_average'] != null)
              ? (json['vote_average'] is int)
                  ? (json['vote_average'] as int).toDouble()
                  : (json['vote_average'] as num).toDouble()
              : 0.0,
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      genres: genresList,
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? '',
    );
  }

  String get year {
    if (releaseDate.isNotEmpty) {
      return releaseDate.split('-')[0];
    }
    return '';
  }
}
