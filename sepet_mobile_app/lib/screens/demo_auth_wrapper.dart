import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';
import '../services/demo_auth_service.dart';
import 'demo_home_screen.dart';
import 'demo_login_screen.dart';

class DemoAuthWrapper extends StatelessWidget {
  const DemoAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DemoUser?>(
      stream: context.read<DemoAuthService>().authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: SpinKitWave(
                color: AppColors.primaryBlue,
                size: 50.0,
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.errorRed,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bir hata oluştu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lütfen uygulamayı yeniden başlatın',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // App restart logic burada olacak
                    },
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            ),
          );
        }

        // Authentication state
        final user = snapshot.data;

        if (user != null) {
          // User is logged in
          return const DemoHomeScreen();
        } else {
          // User is not logged in
          return const DemoLoginScreen();
        }
      },
    );
  }
}
