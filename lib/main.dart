import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:serfilm/pages/use_splash_page.dart';
import 'package:serfilm/pages/login_page.dart';
import 'package:serfilm/pages/register_page.dart';
import 'package:serfilm/providers/auth_provider.dart';
import 'package:serfilm/pages/detail_film_page.dart';
import 'package:serfilm/pages/home/main_page.dart';
import 'package:serfilm/pages/home/explore_page.dart';
import 'package:serfilm/pages/home/search_page.dart';
import 'package:serfilm/pages/home/watchlist_page.dart';
import 'package:serfilm/pages/home/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: MaterialApp(
        title: 'Serfilm',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const UseSplashPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MainPage(),
          '/detail_film': (context) => const DetailFilmPage(),
          '/explore': (context) => const ExplorePage(),
          '/search': (context) => const SearchPage(),
          '/watchlist': (context) => const WatchlistPage(),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}
