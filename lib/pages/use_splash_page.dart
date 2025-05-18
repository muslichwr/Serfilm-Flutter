import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/primary_button.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class UseSplashPage extends StatefulWidget {
  const UseSplashPage({super.key});

  @override
  State<UseSplashPage> createState() => _UseSplashPageState();
}

class _UseSplashPageState extends State<UseSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Ubah status bar jadi transparan (opsional)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // Setup controller animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInCubic),
    );

    _animationController.forward();

    // Navigasi otomatis setelah splash
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Aplikasi
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.movie, size: 80, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 20),

            // Judul Aplikasi
            Text(
              "Movie Watchlist",
              style: AppTextStyles.heading.copyWith(fontSize: 24),
            ),

            const SizedBox(height: 10),

            // Subjudul dinamis
            DefaultTextStyle(
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Simpan film favoritmu'),
                  TyperAnimatedText('Berikan ulasan dan rekomendasikan'),
                ],
                isRepeatingAnimation: true,
                repeatForever: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
