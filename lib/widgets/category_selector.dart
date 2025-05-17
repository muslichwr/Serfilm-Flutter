import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final TabController controller;
  final Function(int) onCategoryChanged;

  const CategorySelector({
    super.key,
    required this.controller,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      onTap: onCategoryChanged,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).colorScheme.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(icon: Icon(Icons.trending_up), text: 'Trending'),
        Tab(icon: Icon(Icons.favorite), text: 'Popular'),
        Tab(icon: Icon(Icons.star), text: 'Top Rated'),
        Tab(icon: Icon(Icons.rate_review), text: 'Reviews'),
        Tab(icon: Icon(Icons.bookmark), text: 'Watchlist'),
        Tab(icon: Icon(Icons.person), text: 'Profile'),
      ],
    );
  }
}
