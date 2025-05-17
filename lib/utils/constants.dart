class AppConstants {
  // API
  static const String tmdbApiKey = 'ce1e0471c0dfc761decbc0523d65398a';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // Image sizes
  static const String posterSizeSmall = 'w185';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';
  static const String backdropSizeSmall = 'w300';
  static const String backdropSizeLarge = 'w1280';
  static const String profileSizeSmall = 'w45';
  static const String profileSizeMedium = 'w185';

  // Shared Preferences Keys
  static const String keyWatchlist = 'watchlist';
  static const String keyFavorites = 'favorites';
  static const String keyLastVisited = 'last_visited';

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 300);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(milliseconds: 800);
}
