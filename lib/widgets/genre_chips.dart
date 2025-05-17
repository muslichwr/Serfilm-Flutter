import 'package:flutter/material.dart';
import 'package:serfilm/models/genre.dart';

class GenreChips extends StatelessWidget {
  final List<Genre> genres;
  final int? selectedGenreId;
  final Function(Genre) onGenreSelected;

  const GenreChips({
    super.key,
    required this.genres,
    this.selectedGenreId,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre.id == selectedGenreId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(genre.name),
              onSelected: (_) => onGenreSelected(genre),
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
              side: BorderSide(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700]!,
              ),
            ),
          );
        },
      ),
    );
  }
}
