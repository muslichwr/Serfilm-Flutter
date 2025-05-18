import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/primary_button.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🎬 Movie Watchlist",
                style: AppTextStyles.heading.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 40),
              Text("Masuk", style: AppTextStyles.heading),
              const SizedBox(height: 20),

              CustomTextField(label: "Email"),
              const SizedBox(height: 16),
              CustomTextField(label: "Password", obscureText: true),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Lupa Password?",
                  style: AppTextStyles.body.copyWith(color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 30),

              PrimaryButton(text: "Masuk", onPressed: () {}),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun? ", style: AppTextStyles.body),
                    Text(
                      "Daftar",
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
