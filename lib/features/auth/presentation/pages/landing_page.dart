import 'package:flutter/material.dart';
import 'package:smart_agri_price_tracker/core/routing/app_router.dart';
import 'package:smart_agri_price_tracker/core/theme/app_theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Section: Logo and App Name
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.agriculture_rounded,
                              size: 80,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Smart Agricultural\nPrice Tracker',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Real-time crop prices for every farmer',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      // Middle Section: Optional Illustration or decorative element
                      // (Leaving space for a clean modern look)
                      const SizedBox(height: 40),

                      // Bottom Section: Actions
                      Column(
                        children: [
                          // Login Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.login);
                            },
                            child: const Text('Login'),
                          ),
                          const SizedBox(height: 16),
                          // Register Button
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.register);
                            },
                            child: const Text('Register'),
                          ),
                          const SizedBox(height: 16),
                          // Continue as Guest
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.home);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
