import 'package:flutter/material.dart';
import 'package:serfilm/models/review.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/pages/review_detail_page.dart';
import 'package:serfilm/pages/add_review_page.dart';
import 'package:serfilm/theme/app_theme.dart';
import 'package:serfilm/widgets/rating_indicator.dart';
import 'package:intl/intl.dart';

class ReviewsPage extends StatefulWidget {
  final int? movieId; // Optional, jika null maka tampilkan semua review
  final String? movieTitle;
  final String? moviePoster;

  const ReviewsPage({
    super.key,
    this.movieId,
    this.movieTitle,
    this.moviePoster,
  });

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  bool _isLoading = false;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implementasi dengan service asli
      await Future.delayed(const Duration(seconds: 1));

      // Dummy data
      final dummyReviews = [
        Review(
          id: '1',
          movieId: 550,
          userId: 'user1',
          userName: 'John Doe',
          rating: 4.5,
          comment:
              'Film ini sangat bagus, saya sangat menikmati alur ceritanya yang menarik. Aktor utamanya juga bermain dengan sangat baik.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Review(
          id: '2',
          movieId: 550,
          userId: 'user2',
          userName: 'Jane Smith',
          rating: 3.8,
          comment:
              'Ceritanya menarik tapi kurang di bagian akhir. Efek visual sangat mengesankan.',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Review(
          id: '3',
          movieId: 299536,
          userId: 'user3',
          userName: 'Robert Johnson',
          rating: 5.0,
          comment:
              'Sempurna! Ini adalah film terbaik yang pernah saya tonton tahun ini!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: '4',
          movieId: 299536,
          userId: 'user4',
          userName: 'Sarah Williams',
          rating: 4.2,
          comment:
              'Sangat menghibur dan penuh dengan aksi. Tidak sabar menunggu sekuelnya.',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

      setState(() {
        if (widget.movieId != null) {
          // Filter review hanya untuk film tertentu
          _reviews =
              dummyReviews.where((r) => r.movieId == widget.movieId).toList();
        } else {
          _reviews = dummyReviews;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat ulasan: $e')));
    }
  }

  Future<void> _refresh() async {
    await _loadReviews();
  }

  void _openReviewDetail(Review review) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReviewDetailPage(review: review)),
    );
  }

  Future<void> _openAddReview() async {
    if (widget.movieId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih film terlebih dahulu')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddReviewPage(
              movieId: widget.movieId!,
              movieTitle: widget.movieTitle,
              moviePoster: widget.moviePoster,
            ),
      ),
    );

    // Jika ada hasil (berhasil menambahkan review), reload ulasan
    if (result != null && result is Review) {
      setState(() {
        _reviews.insert(0, result); // Tambahkan review baru di awal list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Ulasan Film';
    if (widget.movieTitle != null) {
      title = 'Ulasan: ${widget.movieTitle}';
    }

    // Jika halaman ini dibuka langsung dari main page (bukan sebagai child)
    final bool isFullPage =
        widget.movieId == null && ModalRoute.of(context)?.settings.name == null;
    final bool isStandalone = ModalRoute.of(context)?.settings.name != null;

    if (isStandalone) {
      // Jika dibuka sebagai halaman terpisah melalui navigasi
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: 0,
          leading:
              Navigator.of(context).canPop()
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                  : null,
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddReview,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add_comment),
        ),
      );
    } else if (isFullPage) {
      // Jika dibuka sebagai tab dari MainPage
      return _buildBody();
    } else {
      // Jika sebagai bagian dari halaman detail film
      return Scaffold(
        appBar: AppBar(title: Text(title), elevation: 0),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddReview,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add_comment),
        ),
      );
    }
  }

  Widget _buildBody() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _reviews.isEmpty
        ? _buildEmptyState()
        : RefreshIndicator(
          onRefresh: _refresh,
          child: Column(
            children: [
              if (widget.movieId != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ElevatedButton.icon(
                    onPressed: _openAddReview,
                    icon: const Icon(Icons.create),
                    label: const Text('Tulis Ulasan Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder:
                      (context, index) => _buildReviewCard(_reviews[index]),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada ulasan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.movieId != null
                ? 'Jadilah yang pertama memberikan ulasan untuk film ini!'
                : 'Belum ada ulasan yang ditulis oleh pengguna.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _openAddReview,
            icon: const Icon(Icons.create),
            label: const Text('Tulis Ulasan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    final String formattedDate = formatter.format(review.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openReviewDetail(review),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      review.userName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RatingIndicator(rating: review.rating, size: 40),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review.comment,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _openReviewDetail(review),
                  child: const Text('Baca Selengkapnya'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
