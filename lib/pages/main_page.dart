import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:serfilm/models/genre.dart';
import 'package:serfilm/models/movie.dart';
import 'package:serfilm/pages/movie_detail_page.dart';
import 'package:serfilm/providers/movie_provider.dart';
import 'package:serfilm/widgets/category_selector.dart';
import 'package:serfilm/widgets/genre_chips.dart';
import 'package:serfilm/widgets/hero_slider.dart';
import 'package:serfilm/widgets/movie_grid.dart';
import 'package:serfilm/widgets/search_box.dart';
import 'package:serfilm/pages/watchlist_page.dart';
import 'package:serfilm/pages/profile_page.dart';
import 'package:serfilm/models/user.dart';
import 'package:serfilm/pages/reviews_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  double _appBarElevation = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController.addListener(_onScroll);

    // Initialize data
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MovieProvider>(context, listen: false);
      provider.loadInitialData();
    });
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 120;
    final showElevation = _scrollController.offset > 10;

    if (showTitle != _showAppBarTitle ||
        (showElevation && _appBarElevation == 0) ||
        (!showElevation && _appBarElevation > 0)) {
      setState(() {
        _showAppBarTitle = showTitle;
        _appBarElevation = showElevation ? 4 : 0;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movieId: movie.id),
      ),
    );
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
    }
  }

  void _handleCategoryChange(int index) {
    final provider = Provider.of<MovieProvider>(context, listen: false);
    _tabController.animateTo(index);

    switch (index) {
      case 0:
        provider.selectCategory('trending');
        break;
      case 1:
        provider.selectCategory('popular');
        break;
      case 2:
        provider.selectCategory('top_rated');
        break;
      case 3:
        provider.selectCategory('reviews');
        break;
      case 4:
        provider.selectCategory('watchlist');
        break;
      case 5:
        provider.selectCategory('profile');
        break;
    }
  }

  void _handleGenreSelect(Genre genre) {
    Provider.of<MovieProvider>(
      context,
      listen: false,
    ).fetchMoviesByGenre(genre.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MovieProvider>(context);
    final movies = provider.movies;
    final isLoading = provider.isLoading;
    final genres = provider.genres;
    final selectedCategory = provider.selectedCategory;

    String appBarTitle;
    switch (selectedCategory) {
      case 'trending':
        appBarTitle = 'Trending Movies';
        break;
      case 'popular':
        appBarTitle = 'Popular Movies';
        break;
      case 'top_rated':
        appBarTitle = 'Top Rated Movies';
        break;
      case 'search':
        appBarTitle = 'Search Results';
        break;
      case 'genre':
        final selectedGenre = provider.selectedGenre;
        appBarTitle = selectedGenre?.name ?? 'Genre Movies';
        break;
      case 'reviews':
        appBarTitle = 'Ulasan Film';
        break;
      case 'watchlist':
        appBarTitle = 'Watchlist';
        break;
      case 'profile':
        appBarTitle = 'Profile';
        break;
      default:
        appBarTitle = 'TMDB Movies';
    }

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              elevation: _appBarElevation,
              expandedHeight: 80,
              floating: true,
              pinned: true,
              title: AnimatedOpacity(
                opacity: _showAppBarTitle ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(appBarTitle),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => DraggableScrollableSheet(
                            initialChildSize: 0.9,
                            minChildSize: 0.5,
                            maxChildSize: 0.9,
                            builder:
                                (context, scrollController) => SearchBox(
                                  onSearch: _handleSearch,
                                  scrollController: scrollController,
                                ),
                          ),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(75),
                child: CategorySelector(
                  controller: _tabController,
                  onCategoryChanged: _handleCategoryChange,
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await provider.refreshData();
          },
          child: AnimationLimiter(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (selectedCategory == 'watchlist')
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: WatchlistPage(),
                    ),
                  )
                else if (selectedCategory == 'profile')
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ProfilePage(
                        user: User(
                          id: '1',
                          name: 'Guest User',
                          email: 'guest@example.com',
                          photoUrl: null,
                          createdAt: DateTime.now(),
                        ),
                      ),
                    ),
                  )
                else if (selectedCategory == 'reviews')
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 180,
                        child: ReviewsPage(),
                      ),
                    ),
                  )
                else ...[
                  // Hero Slider with featured movies
                  if (selectedCategory != 'search' && movies.isNotEmpty)
                    SliverToBoxAdapter(
                      child: HeroSlider(
                        movies: movies.take(5).toList(),
                        onMovieTap: _navigateToDetail,
                      ),
                    ),
                  // Genre filtering chips
                  if (selectedCategory != 'search')
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      sliver: SliverToBoxAdapter(
                        child: GenreChips(
                          genres: genres,
                          selectedGenreId: provider.selectedGenre?.id,
                          onGenreSelected: _handleGenreSelect,
                        ),
                      ),
                    ),
                  // Movie Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: MovieGrid(
                        movies: movies,
                        isLoading: isLoading,
                        onMovieTap: _navigateToDetail,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
