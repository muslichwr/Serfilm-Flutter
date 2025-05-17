import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/services/tmdb_service.dart';

class HeroSlider extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onMovieTap;

  const HeroSlider({super.key, required this.movies, required this.onMovieTap});

  @override
  State<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends State<HeroSlider> {
  final TMDBService _tmdbService = TMDBService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.movies.isNotEmpty) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.movies.length > 1) {
        final nextPage = (_currentPage + 1) % widget.movies.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return GestureDetector(
                onTap: () => widget.onMovieTap(movie),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Movie backdrop image
                    CachedNetworkImage(
                      imageUrl: _tmdbService.getImageUrl(
                        movie.backdropPath,
                        size: 'original',
                      ),
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
                            child: const Icon(Icons.error),
                          ),
                    ),

                    // Gradient overlay for better text visibility
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54,
                            Colors.black87,
                          ],
                          stops: [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // Movie details
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 10.0, color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie.overview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[300],
                              shadows: const [
                                Shadow(blurRadius: 8.0, color: Colors.black),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => widget.onMovieTap(movie),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('More Info'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Pagination indicators
          if (widget.movies.length > 1)
            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                children: List.generate(
                  widget.movies.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:
                          _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
