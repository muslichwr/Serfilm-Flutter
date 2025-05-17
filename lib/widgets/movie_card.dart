import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/services/tmdb_service.dart';
import 'package:serfilm/widgets/rating_indicator.dart';
import 'package:provider/provider.dart';
import 'package:serfilm/providers/movie_provider.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final Function onTap;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.isWishlisted,
    required this.onWishlistToggle,
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
              color: Colors.black.withValues(alpha: 0.1),
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

                  // Wishlist button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        onWishlistToggle();
                      },
                      child: AnimatedScale(
                        scale: isWishlisted ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                          color: isWishlisted ? Colors.amber : Colors.white,
                          size: 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Personal rating (pojok kiri bawah)
                  Positioned(
                    bottom: 48,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating pribadi
                        GestureDetector(
                          onTap: () async {
                            final provider = Provider.of<MovieProvider>(
                              context,
                              listen: false,
                            );
                            final newRating =
                                await showModalBottomSheet<double>(
                                  context: context,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) {
                                    double tempRating =
                                        movie.personalRating ?? 0.0;
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Beri rating pribadi',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 16),
                                              Slider(
                                                value: tempRating,
                                                min: 0.0,
                                                max: 10.0,
                                                divisions: 100,
                                                label: tempRating
                                                    .toStringAsFixed(1),
                                                onChanged: (val) {
                                                  setState(() {
                                                    tempRating = val;
                                                  });
                                                },
                                              ),
                                              Text(
                                                tempRating.toStringAsFixed(1),
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.headlineSmall,
                                              ),
                                              const SizedBox(height: 16),
                                              ElevatedButton.icon(
                                                icon: const Icon(Icons.star),
                                                label: const Text('Simpan'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(
                                                    context,
                                                    tempRating,
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                            if (newRating != null) {
                              provider.setPersonalRating(movie, newRating);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color:
                                    movie.personalRating != null
                                        ? Colors.amber
                                        : Colors.white,
                                size: 26,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              if (movie.personalRating != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                    movie.personalRating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Visual status watched/toWatch (kiri bawah, di bawah rating pribadi)
                        Row(
                          children: [
                            // Watched
                            GestureDetector(
                              onTap: () {
                                final provider = Provider.of<MovieProvider>(
                                  context,
                                  listen: false,
                                );
                                provider.toggleWatched(movie);
                              },
                              child: Tooltip(
                                message:
                                    movie.watchStatus ==
                                            MovieWatchStatus.watched
                                        ? 'Sudah ditonton'
                                        : 'Tandai sudah ditonton',
                                child: Icon(
                                  movie.watchStatus == MovieWatchStatus.watched
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color:
                                      movie.watchStatus ==
                                              MovieWatchStatus.watched
                                          ? Colors.greenAccent
                                          : Colors.white,
                                  size: 24,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // ToWatch
                            GestureDetector(
                              onTap: () {
                                final provider = Provider.of<MovieProvider>(
                                  context,
                                  listen: false,
                                );
                                provider.toggleToWatch(movie);
                              },
                              child: Tooltip(
                                message:
                                    movie.watchStatus ==
                                            MovieWatchStatus.toWatch
                                        ? 'Masuk daftar tonton'
                                        : 'Tandai ingin ditonton',
                                child: Icon(
                                  movie.watchStatus == MovieWatchStatus.toWatch
                                      ? Icons.visibility
                                      : Icons.visibility_outlined,
                                  color:
                                      movie.watchStatus ==
                                              MovieWatchStatus.toWatch
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.white,
                                  size: 24,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
