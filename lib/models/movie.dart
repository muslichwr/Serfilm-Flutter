import 'package:serfilm/models/genre.dart';

class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  final double popularity;

  Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
    required this.popularity,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] as num).toDouble(),
    );
  }
}

class MovieDetails extends Movie {
  final List<Genre> genres;
  final int runtime;
  final int budget;
  final int revenue;
  final String status;
  final String tagline;
  final Credits credits;
  final Videos videos;

  MovieDetails({
    required int id,
    required String title,
    String? posterPath,
    String? backdropPath,
    required String overview,
    required String releaseDate,
    required double voteAverage,
    required double popularity,
    required this.genres,
    required this.runtime,
    required this.budget,
    required this.revenue,
    required this.status,
    required this.tagline,
    required this.credits,
    required this.videos,
  }) : super(
         id: id,
         title: title,
         posterPath: posterPath,
         backdropPath: backdropPath,
         overview: overview,
         releaseDate: releaseDate,
         voteAverage: voteAverage,
         genreIds: genres.map((genre) => genre.id).toList(),
         popularity: popularity,
       );

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'],
      title: json['title'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      popularity: (json['popularity'] as num).toDouble(),
      genres: (json['genres'] as List).map((g) => Genre.fromJson(g)).toList(),
      runtime: json['runtime'] ?? 0,
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      status: json['status'] ?? '',
      tagline: json['tagline'] ?? '',
      credits: Credits.fromJson(json['credits'] ?? {'cast': [], 'crew': []}),
      videos: Videos.fromJson(json['videos'] ?? {'results': []}),
    );
  }
}

class Credits {
  final List<Cast> cast;
  final List<Crew> crew;

  Credits({required this.cast, required this.crew});

  factory Credits.fromJson(Map<String, dynamic> json) {
    return Credits(
      cast: (json['cast'] as List).map((c) => Cast.fromJson(c)).toList(),
      crew: (json['crew'] as List).map((c) => Crew.fromJson(c)).toList(),
    );
  }
}

class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}

class Crew {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;

  Crew({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'],
      name: json['name'],
      job: json['job'] ?? '',
      department: json['department'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}

class Videos {
  final List<Video> results;

  Videos({required this.results});

  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      results: (json['results'] as List).map((v) => Video.fromJson(v)).toList(),
    );
  }
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
    );
  }
}
