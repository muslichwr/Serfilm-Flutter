import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewFilmPage extends StatefulWidget {
  final Map<String, dynamic> filmData;
  final Map<String, dynamic>? existingReview;

  const ReviewFilmPage({Key? key, required this.filmData, this.existingReview})
    : super(key: key);

  @override
  _ReviewFilmPageState createState() => _ReviewFilmPageState();
}

class _ReviewFilmPageState extends State<ReviewFilmPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 7.0;
  bool _isSubmitting = false;
  bool _isWatched = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi status dan isi review jika ada review yang sudah dibuat sebelumnya
    if (widget.existingReview != null) {
      _rating = widget.existingReview!['rating'] as double? ?? 7.0;
      _reviewController.text =
          widget.existingReview!['comment'] as String? ?? '';
    }
    // Set status watched berdasarkan data film
    _isWatched = widget.filmData['status'] == 'watched';
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingReview != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Ulasan' : 'Tulis Ulasan',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildFilmHeader(),

            // Form Ulasan
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle status film
                    _buildWatchedToggle(),

                    const SizedBox(height: 24),

                    // Rating Bintang
                    _buildRatingSection(),

                    const SizedBox(height: 24),

                    // Text Field Ulasan
                    _buildReviewTextField(),

                    if (isEditing) ...[
                      const SizedBox(height: 24),
                      _buildDeleteButton(),
                    ],
                  ],
                ),
              ),
            ),

            // Tombol Simpan
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchedToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Film',
          style: AppTextStyles.heading.copyWith(
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SwitchListTile.adaptive(
            value: _isWatched,
            onChanged: (value) {
              setState(() {
                _isWatched = value;
              });
            },
            title: Text('Sudah Ditonton', style: AppTextStyles.bodyBold),
            subtitle: Text(
              _isWatched
                  ? 'Film ini sudah Anda tonton'
                  : 'Film ini belum Anda tonton',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            activeColor: Colors.green,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilmHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Poster Film
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl:
                  widget.filmData['poster'] ??
                  "https://via.placeholder.com/400x250.png?text=Movie+Poster",
              width: 60,
              height: 80,
              fit: BoxFit.cover,
              placeholder:
                  (_, __) => Container(
                    width: 60,
                    height: 80,
                    color: AppColors.surface.withOpacity(0.8),
                  ),
            ),
          ),
          const SizedBox(width: 16),

          // Info Film
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.filmData['title'] ?? "Judul Tidak Tersedia",
                  style: AppTextStyles.heading.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.filmData['year']} • ${widget.filmData['type'] == 'movie' ? 'Film' : 'Serial TV'}",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (widget.existingReview != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Mengubah Ulasan',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating Film',
          style: AppTextStyles.heading.copyWith(
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 10,
                    itemSize: 28,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder:
                        (context, _) =>
                            Icon(Icons.star, color: AppColors.accent),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRatingColor(_rating).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: _getRatingColor(_rating)),
                    const SizedBox(width: 4),
                    Text(
                      _rating.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(_rating),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ulasan',
          style: AppTextStyles.heading.copyWith(
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _reviewController,
            maxLines: 7,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Tulis ulasan Anda tentang film ini...',
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return TextButton.icon(
      onPressed: () {
        // Konfirmasi hapus ulasan
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Hapus Ulasan'),
                content: Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog

                      // Kembali ke halaman detail film dengan info hapus
                      Navigator.pop(context, {'action': 'delete'});

                      // Tampilkan snackbar sukses
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ulasan berhasil dihapus!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    },
                    child: Text('Hapus'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
        );
      },
      icon: Icon(Icons.delete_outline, color: Colors.red),
      label: Text(
        'Hapus Ulasan',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool isEditing = widget.existingReview != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            _isSubmitting
                ? null
                : () {
                  setState(() {
                    _isSubmitting = true;
                  });

                  // Simulasi pengiriman data
                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      _isSubmitting = false;
                    });

                    // Buat objek data ulasan
                    final reviewData = {
                      'filmId': widget.filmData['id'],
                      'rating': _rating,
                      'comment': _reviewController.text,
                      'status': _isWatched ? 'watched' : 'not_watched',
                      'action': isEditing ? 'update' : 'create',
                    };

                    // TODO: Kirim data ulasan ke API
                    print('Submitting review: $reviewData');

                    // Kembali ke halaman detail film
                    Navigator.pop(context, reviewData);

                    // Tampilkan snackbar sukses
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Ulasan berhasil diperbarui!'
                              : 'Ulasan berhasil disimpan!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  });
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: isEditing ? Colors.blue.shade700 : AppColors.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isSubmitting
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  isEditing ? 'Perbarui Ulasan' : 'Simpan Ulasan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
