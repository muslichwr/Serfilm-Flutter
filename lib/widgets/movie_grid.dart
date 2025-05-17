import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/widgets/movie_card.dart';
import 'package:serfilm/widgets/movie_skeleton.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoading;
  final Function(Movie) onMovieTap;

  const MovieGrid({
    super.key,
    required this.movies,
    required this.isLoading,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate grid items based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 150).floor().clamp(2, 5);

    if (isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 10,
        itemBuilder: (context, index) => const MovieSkeleton(),
      );
    }

    if (movies.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_outlined,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No movies found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: MovieCard(
                  movie: movies[index],
                  onTap: () => onMovieTap(movies[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
