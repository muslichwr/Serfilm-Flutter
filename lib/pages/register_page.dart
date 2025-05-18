import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/primary_button.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("🎬 Serfilm", style: AppTextStyles.heading),
                const SizedBox(height: 40),

                Text(
                  "Daftar Akun Baru",
                  style: AppTextStyles.heading.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 20),

                CustomTextField(label: "Nama Lengkap"),
                const SizedBox(height: 16),
                CustomTextField(label: "Email"),
                const SizedBox(height: 16),
                CustomTextField(label: "Password", obscureText: true),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Konfirmasi Password",
                  obscureText: true,
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 16),

                PrimaryButton(text: "Daftar", onPressed: () {}),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sudah punya akun? ", style: AppTextStyles.body),
                      Text(
                        "Masuk",
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
      ),
    );
  }
}
