import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:serfilm/models/movie.dart';

typedef ImageUrlBuilder = String Function(String?, {String size});

class CastList extends StatelessWidget {
  final List<Cast> cast;
  final ImageUrlBuilder imageBaseUrl;

  const CastList({super.key, required this.cast, required this.imageBaseUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = cast[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                // Actor image
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[800],
                  child: ClipOval(
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child:
                          actor.profilePath != null
                              ? CachedNetworkImage(
                                imageUrl: imageBaseUrl(
                                  actor.profilePath,
                                  size: 'w185',
                                ),
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                              )
                              : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Actor name
                SizedBox(
                  width: 90,
                  child: Text(
                    actor.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Character name
                SizedBox(
                  width: 90,
                  child: Text(
                    actor.character,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
