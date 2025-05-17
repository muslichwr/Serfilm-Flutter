import 'package:flutter/material.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/models/watchlist.dart';
import 'package:serfilm/widgets/movie_card.dart';

/// Widget grid untuk menampilkan daftar film di watchlist
class WatchlistGrid extends StatelessWidget {
  final List<WatchlistItem> filtered;
  final Map<int, Movie> movies;
  final void Function(WatchlistItem, WatchStatus) onStatusChange;

  const WatchlistGrid({
    super.key,
    required this.filtered,
    required this.movies,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    if (filtered.isEmpty) {
      // Tampilkan pesan jika watchlist kosong
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Watchlist kamu masih kosong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan film favoritmu ke watchlist!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Arahkan ke halaman pencarian/film
              },
              icon: const Icon(Icons.search),
              label: const Text('Cari Film'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Tampilkan grid film
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final movie = movies[item.movieId];
        if (movie == null) {
          return const SizedBox.shrink();
        }
        return MovieCard(
          movie: movie,
          onTap: () {
            // TODO: Navigate to movie detail
          },
          isInWatchlist: true,
          watchStatus: item.status,
          onWatchlistChanged: (movieId, status) {
            onStatusChange(item, status);
          },
        );
      },
    );
  }
}
