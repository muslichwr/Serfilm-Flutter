// import 'package:flutter/material.dart';
// import 'package:serfilm/models/review.dart';
// import 'package:serfilm/models/movie.dart';
// import 'package:serfilm/services/tmdb_service.dart';
// import 'package:serfilm/widgets/rating_indicator.dart';
// import 'package:serfilm/pages/movie_detail_page.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';

// class ReviewDetailPage extends StatefulWidget {
//   final Review review;

//   const ReviewDetailPage({super.key, required this.review});

//   @override
//   State<ReviewDetailPage> createState() => _ReviewDetailPageState();
// }

// class _ReviewDetailPageState extends State<ReviewDetailPage> {
//   Movie? _movie;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadMovieDetails();
//   }

//   Future<void> _loadMovieDetails() async {
//     setState(() => _isLoading = true);

//     try {
//       // TODO: Implementasi dengan service asli
//       await Future.delayed(const Duration(seconds: 1));

//       // Dummy data
//       final dummyMovie = Movie(
//         id: widget.review.movieId,
//         title:
//             widget.review.movieId == 550
//                 ? 'Fight Club'
//                 : 'Avengers: Infinity War',
//         posterPath: '',
//         overview: 'Detail film akan dimuat dari API',
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

//   void _navigateToMovieDetail() {
//     if (_movie != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MovieDetailPage(movieId: _movie!.id),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm');
//     final String formattedDate = formatter.format(widget.review.createdAt);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_movie?.title ?? 'Detail Ulasan'),
//         elevation: 0,
//         actions: [
//           if (_movie != null)
//             IconButton(
//               icon: const Icon(Icons.movie_outlined),
//               tooltip: 'Lihat Film',
//               onPressed: _navigateToMovieDetail,
//             ),
//         ],
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header dengan info review
//                     _buildReviewHeader(formattedDate),

//                     const SizedBox(height: 24),

//                     // Review content
//                     Text(
//                       'Ulasan',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).cardColor,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         widget.review.comment,
//                         style: const TextStyle(fontSize: 16, height: 1.5),
//                       ),
//                     ),

//                     const SizedBox(height: 24),

//                     // Movie info
//                     if (_movie != null) _buildMovieInfo(),

//                     const SizedBox(height: 24),

//                     // Action buttons
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             // TODO: Implementasi fitur like
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Fitur like akan datang segera'),
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.thumb_up),
//                           label: const Text('Suka'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                           ),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             // TODO: Implementasi fitur share
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Fitur share akan datang segera'),
//                               ),
//                             );
//                           },
//                           icon: const Icon(Icons.share),
//                           label: const Text('Bagikan'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildReviewHeader(String formattedDate) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CircleAvatar(
//           radius: 30,
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           child: Text(
//             widget.review.userName[0].toUpperCase(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.review.userName,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               Text(
//                 formattedDate,
//                 style: TextStyle(color: Colors.grey[400], fontSize: 14),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   RatingIndicator(rating: widget.review.rating, size: 32),
//                   const SizedBox(width: 8),
//                   Text(
//                     widget.review.rating.toString(),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     '/5',
//                     style: TextStyle(color: Colors.grey[400], fontSize: 14),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMovieInfo() {
//     final tmdbService = TMDBService();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Tentang Film',
//           style: Theme.of(
//             context,
//           ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: _navigateToMovieDetail,
//           borderRadius: BorderRadius.circular(12),
//           child: Card(
//             clipBehavior: Clip.antiAlias,
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Movie poster
//                 SizedBox(
//                   width: 100,
//                   height: 150,
//                   child: CachedNetworkImage(
//                     imageUrl: tmdbService.getPosterUrl(
//                       _movie!.posterPath ?? '',
//                     ),
//                     fit: BoxFit.cover,
//                     placeholder:
//                         (context, url) => Container(
//                           color: Colors.grey[800],
//                           child: const Center(
//                             child: CircularProgressIndicator(),
//                           ),
//                         ),
//                     errorWidget:
//                         (context, url, error) => Container(
//                           color: Colors.grey[800],
//                           child: const Center(
//                             child: Icon(
//                               Icons.movie,
//                               color: Colors.white54,
//                               size: 40,
//                             ),
//                           ),
//                         ),
//                   ),
//                 ),
//                 // Movie details
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _movie!.title,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Rilis: ${_movie!.releaseDate}',
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Icon(Icons.star, color: Colors.amber, size: 16),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${_movie!.voteAverage}/10',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         TextButton.icon(
//                           onPressed: _navigateToMovieDetail,
//                           icon: const Icon(Icons.movie_filter),
//                           label: const Text('Lihat Detail Film'),
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             alignment: Alignment.centerLeft,
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
