import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieSkeleton extends StatelessWidget {
  const MovieSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[850]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster placeholder
            Expanded(child: Container(color: Colors.grey[900])),
          ],
        ),
      ),
    );
  }
}
