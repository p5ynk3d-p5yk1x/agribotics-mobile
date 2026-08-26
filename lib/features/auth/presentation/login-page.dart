import 'dart:ui';

import 'package:agribotics/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool loading = false;

  Future<void> _login() async {
    try {
      setState(() => loading = true);
      await ref
          .read(authProvider.notifier)
          .signInGoogle();
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppTheme.heroGradient),

          Positioned(
            top: -140,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.emerald.withValues(alpha: .18),
              ),
            ),
          ),

          Positioned(
            bottom: -180,
            left: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .05),
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: const SizedBox.expand(),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: .08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.sprout,
                          size: 44,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn().scale(),

                      const SizedBox(height: 20),

                      Text(
                        'AGRIBOTICS',
                        textAlign: TextAlign.center,
                        style: textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 42,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: .15),

                      const SizedBox(height: 8),

                      Text(
                        'AI-powered crop intelligence for the next generation of farming.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: .75),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _pill(LucideIcons.search, 'Weed Detection'),
                          _pill(LucideIcons.leaf, 'Crop Health'),
                          _pill(LucideIcons.map, 'Field Mapping'),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 32),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.emerald.withValues(alpha: .12),
                            ),
                          ),

                          GlassContainer(
                            blur: 30,
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.white.withValues(alpha: .08),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Welcome Back',
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    'Sign in to access AI crop analytics, weed detection and agricultural insights.',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: .72),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 58,
                                    child: FilledButton(
                                      onPressed: loading ? null : _login,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                      child: loading
                                          ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                          : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFF1F1F1),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'G',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  Text(
                                    'Secure authentication powered by Google OAuth',
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: .45),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: .1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}