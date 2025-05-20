import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReviewCard extends StatelessWidget {
  final String? posterUrl;
  final String? title;
  final double? rating;
  final String? comment;
  final String? username;
  final String? date;
  final VoidCallback? onWriteReview;

  const ReviewCard({
    super.key,
    this.posterUrl,
    this.title,
    this.rating,
    this.comment,
    this.username,
    this.date,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    // Format rating to one decimal place
    final formattedRating =
        (rating != null && rating! >= 0 && rating! <= 10)
            ? rating!.toStringAsFixed(1).replaceAll('.', ',')
            : "0,0";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pengguna dengan fallback jika gambar tidak ada
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildUserAvatar(),
            ),
          ),
          const SizedBox(width: 12),
          // Konten ulasan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama pengguna dan tanggal
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        username ?? "Anonim",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Rating dalam format desimal
                    if (rating != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRatingColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          formattedRating,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getRatingColor(),
                          ),
                        ),
                      ),
                  ],
                ),

                // Tanggal posting
                if (date != null && date!.isNotEmpty)
                  Text(
                    date!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),

                const SizedBox(height: 8),

                // Isi ulasan
                if (comment != null && comment!.isNotEmpty)
                  Text(
                    comment!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textPrimary.withOpacity(0.9),
                    ),
                  )
                else
                  Text(
                    "Tidak ada komentar",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mendapatkan warna berdasarkan nilai rating
  Color _getRatingColor() {
    final safeRating = rating ?? 0.0;
    if (safeRating >= 7.5) return Colors.green;
    if (safeRating >= 5.0) return Colors.orange;
    return Colors.red;
  }

  // Widget untuk avatar pengguna dengan fallback
  Widget _buildUserAvatar() {
    if (posterUrl == null || posterUrl!.isEmpty) {
      // Fallback avatar jika URL kosong
      return Container(
        color: AppColors.surface,
        child: Icon(Icons.person, size: 24, color: AppColors.textSecondary),
      );
    }

    return CachedNetworkImage(
      imageUrl: posterUrl!,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: AppColors.surface,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: AppColors.surface,
            child: Icon(Icons.person, size: 24, color: AppColors.textSecondary),
          ),
    );
  }
}
