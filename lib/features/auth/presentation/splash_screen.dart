import 'package:agribotics/core/auth/auth_state.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openApp());
  }

  Future<void> _openApp() async {
    await Future.wait([
      ref.read(authProvider.notifier).ensureInitialized(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);

    if (!mounted) return;
    final authState = ref.read(authProvider);
    context.go(authState is AuthAuthenticated ? '/dashboard' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: AppTheme.heroGradient,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _Glow(
                size: 320,
                color: AppTheme.secondary.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -180,
              left: -130,
              child: _Glow(
                size: 420,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 156,
                      height: 156,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.onSurface.withValues(alpha: 0.16),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(
                          begin: const Offset(0.88, 0.88),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 28),
                    Text(
                      'AGRIBOTICS',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                    const SizedBox(height: 10),
                    Text(
                      'Smarter farming, rooted in data',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 44),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 550.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
