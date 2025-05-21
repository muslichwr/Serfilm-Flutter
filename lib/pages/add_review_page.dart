// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:serfilm/models/movie.dart';
// import 'package:serfilm/models/review.dart';
// import 'package:serfilm/services/tmdb_service.dart';
// import 'package:serfilm/theme/app_theme.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class AddReviewPage extends StatefulWidget {
//   final int movieId;
//   final String? movieTitle;
//   final String? moviePoster;

//   const AddReviewPage({
//     super.key,
//     required this.movieId,
//     this.movieTitle,
//     this.moviePoster,
//   });

//   @override
//   State<AddReviewPage> createState() => _AddReviewPageState();
// }

// class _AddReviewPageState extends State<AddReviewPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _commentController = TextEditingController();

//   double _rating = 3.0;
//   bool _isLoading = false;
//   bool _isSubmitting = false;
//   Movie? _movie;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.movieTitle == null) {
//       _loadMovieDetails();
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadMovieDetails() async {
//     setState(() => _isLoading = true);

//     try {
//       // TODO: Implementasi dengan service asli
//       await Future.delayed(const Duration(seconds: 1));

//       // Dummy data
//       final dummyMovie = Movie(
//         id: widget.movieId,
//         title: widget.movieId == 550 ? 'Fight Club' : 'Avengers: Infinity War',
//         posterPath: '',
//         overview: 'Overview film',
//         releaseDate: '2019-01-01',
//         voteAverage: 8.5,
//         genreIds: const [1, 2],
//         popularity: 100,
//       );

//       setState(() {
//         _movie = dummyMovie;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Gagal memuat detail film: $e')));
//     }
//   }

//   void _submitReview() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       // TODO: Implementasi dengan service asli
//       await Future.delayed(const Duration(seconds: 1));

//       // Simulasi submit review
//       final newReview = Review(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         movieId: widget.movieId,
//         userId: 'current_user_id',
//         userName: 'Current User',
//         rating: _rating,
//         comment: _commentController.text,
//         createdAt: DateTime.now(),
//       );

//       setState(() => _isSubmitting = false);

//       // Memberikan feedback ke user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ulasan berhasil ditambahkan')),
//         );

//         // Kembali ke halaman sebelumnya
//         Navigator.pop(context, newReview);
//       }
//     } catch (e) {
//       setState(() => _isSubmitting = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Gagal menambahkan ulasan: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String movieTitle = widget.movieTitle ?? _movie?.title ?? 'Film';

//     return Scaffold(
//       appBar: AppBar(title: Text('Tulis Ulasan'), elevation: 0),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Movie info section
//                       _buildMovieInfoSection(movieTitle),

//                       const SizedBox(height: 24),

//                       // Rating section
//                       Text(
//                         'Beri Rating',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Center(
//                         child: Column(
//                           children: [
//                             RatingBar.builder(
//                               initialRating: _rating,
//                               minRating: 1,
//                               direction: Axis.horizontal,
//                               allowHalfRating: true,
//                               itemCount: 5,
//                               itemSize: 40,
//                               itemBuilder:
//                                   (context, _) =>
//                                       Icon(Icons.star, color: Colors.amber),
//                               onRatingUpdate: (rating) {
//                                 setState(() {
//                                   _rating = rating;
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               '${_rating.toStringAsFixed(1)}/5.0',
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Review section
//                       Text(
//                         'Tuliskan Ulasan Anda',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextFormField(
//                         controller: _commentController,
//                         decoration: InputDecoration(
//                           hintText: 'Bagikan pendapat Anda tentang film ini...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Theme.of(context).cardColor,
//                         ),
//                         maxLines: 5,
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Ulasan tidak boleh kosong';
//                           }
//                           if (value.trim().length < 10) {
//                             return 'Ulasan terlalu pendek (min. 10 karakter)';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 32),

//                       // Submit button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _isSubmitting ? null : _submitReview,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppTheme.primaryColor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child:
//                               _isSubmitting
//                                   ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                   : const Text(
//                                     'Kirim Ulasan',
//                                     style: TextStyle(fontSize: 16),
//                                   ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildMovieInfoSection(String movieTitle) {
//     final tmdbService = TMDBService();
//     final posterPath = widget.moviePoster ?? _movie?.posterPath;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Movie poster
//           if (posterPath != null && posterPath.isNotEmpty)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: SizedBox(
//                 width: 80,
//                 height: 120,
//                 child: CachedNetworkImage(
//                   imageUrl: tmdbService.getPosterUrl(posterPath),
//                   fit: BoxFit.cover,
//                   placeholder:
//                       (context, url) => Container(
//                         color: Colors.grey[800],
//                         child: const Center(child: CircularProgressIndicator()),
//                       ),
//                   errorWidget:
//                       (context, url, error) => Container(
//                         color: Colors.grey[800],
//                         child: const Icon(Icons.movie, color: Colors.white54),
//                       ),
//                 ),
//               ),
//             )
//           else
//             Container(
//               width: 80,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(Icons.movie, size: 40, color: Colors.white54),
//             ),

//           const SizedBox(width: 16),

//           // Movie info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   movieTitle,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (_movie != null) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     'Tanggal rilis: ${_movie!.releaseDate}',
//                     style: TextStyle(fontSize: 14, color: Colors.grey[400]),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.amber, size: 16),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${_movie!.voteAverage}/10',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
