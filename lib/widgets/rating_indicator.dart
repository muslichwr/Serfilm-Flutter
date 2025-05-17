import 'package:flutter/material.dart';

class RatingIndicator extends StatelessWidget {
  final double rating;
  final double size;

  const RatingIndicator({super.key, required this.rating, this.size = 50});

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) {
      return Colors.green;
    } else if (rating >= 6.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor(rating);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.3,
          ),
        ),
      ),
    );
  }
}
