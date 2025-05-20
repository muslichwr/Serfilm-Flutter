import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReviewCard extends StatelessWidget {
  final String? posterUrl;
  final String? username;
  final String? title;
  final double? rating;
  final String? comment;
  final String? date;
  final bool isCurrentUser;
  final VoidCallback? onWriteReview;
  final VoidCallback? onEditReview;

  const ReviewCard({
    Key? key,
    this.posterUrl,
    this.username,
    this.title,
    this.rating,
    this.comment,
    this.date,
    this.isCurrentUser = false,
    this.onWriteReview,
    this.onEditReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasComment = comment != null && comment!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrentUser
                  ? AppColors.accent.withOpacity(0.1)
                  : AppColors.divider.withOpacity(0.05),
          width: isCurrentUser ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan avatar dan info user
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar pengguna
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  backgroundImage:
                      posterUrl != null && posterUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(posterUrl!)
                          : null,
                  child:
                      posterUrl == null || posterUrl!.isEmpty
                          ? Icon(
                            Icons.person,
                            color: AppColors.accent,
                            size: 24,
                          )
                          : null,
                ),
                const SizedBox(width: 12),

                // Info pengguna dan rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username ?? 'Pengguna',
                            style: AppTextStyles.bodyBold,
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Anda',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (rating != null) ...[
                            // Rating bintang
                            Icon(
                              Icons.star,
                              color: _getRatingColor(rating),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating!.toStringAsFixed(1),
                              style: TextStyle(
                                color: _getRatingColor(rating),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Tanggal
                          Text(
                            date ?? 'Baru saja',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit button untuk review milik user sendiri
                if (isCurrentUser && onEditReview != null)
                  IconButton(
                    onPressed: onEditReview,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    tooltip: 'Edit ulasan',
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
              ],
            ),
          ),

          // Konten ulasan
          if (hasComment)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                comment!,
                style: AppTextStyles.body.copyWith(
                  height: 1.5,
                  color: AppColors.textPrimary.withOpacity(0.9),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: TextButton.icon(
                onPressed: onWriteReview,
                icon: Icon(Icons.create, size: 16, color: AppColors.accent),
                label: Text(
                  'Tulis ulasan',
                  style: TextStyle(color: AppColors.accent, fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRatingColor(double? rating) {
    final safeRating = rating ?? 0.0;
    if (safeRating >= 7.5) return Colors.green;
    if (safeRating >= 5.0) return Colors.orange;
    return Colors.red;
  }
}
