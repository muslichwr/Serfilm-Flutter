import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/models/watchlist.dart';
import 'package:serfilm/services/tmdb_service.dart';
import 'package:serfilm/widgets/rating_indicator.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final Function onTap;
  final Function(int, WatchStatus)? onWatchlistChanged;
  final bool? isInWatchlist;
  final WatchStatus? watchStatus;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.onWatchlistChanged,
    this.isInWatchlist,
    this.watchStatus,
  });

  @override
  Widget build(BuildContext context) {
    final tmdbService = TMDBService();

    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'movie-poster-${movie.id}',
                    child: CachedNetworkImage(
                      imageUrl: tmdbService.getImageUrl(movie.posterPath),
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RatingIndicator(rating: movie.voteAverage, size: 40),
                  ),

                  // Watchlist button
                  if (onWatchlistChanged != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PopupMenuButton<WatchStatus>(
                          icon: Icon(
                            isInWatchlist == true
                                ? (watchStatus == WatchStatus.watched
                                    ? Icons.check_circle
                                    : Icons.bookmark)
                                : Icons.bookmark_add_outlined,
                            color:
                                isInWatchlist == true
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Tambahkan ke Watchlist',
                          onSelected:
                              (status) => onWatchlistChanged!(movie.id, status),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: WatchStatus.unwatched,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bookmark,
                                        size: 18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Tambahkan ke Watchlist'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: WatchStatus.watched,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Tandai Sudah Ditonton'),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
                    ),

                  // Gradient overlay for bottom title
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                  ),

                  // Movie title
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
