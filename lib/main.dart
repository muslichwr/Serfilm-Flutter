import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:serfilm/pages/use_splash_page.dart';
import 'package:serfilm/pages/login_page.dart';
import 'package:serfilm/pages/register_page.dart';
import 'package:serfilm/pages/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serfilm',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/splash': (context) => const UseSplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
