import 'dart:io';

import 'package:agribotics/core/theme/app_theme.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/features/weeds/data/weed_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WeedDetectionPage extends ConsumerStatefulWidget {
  const WeedDetectionPage({super.key});

  @override
  ConsumerState<WeedDetectionPage> createState() => _WeedDetectionPageState();
}

class _WeedDetectionPageState extends ConsumerState<WeedDetectionPage> {
  final ImagePicker picker = ImagePicker();

  XFile? image;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    setState(() {
      image = picked;
    });
  }

  Future<void> analyze() async {
    if (image == null) return;
    await ref.read(weedProvider.notifier).analyze(File(image!.path));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    ref.listen<WeedState>(
      weedProvider,
          (previous, next) {
        if (next is WeedQueued) {
          context.go('/weed/history');
        } else if (next is WeedError) {
          print(next.message);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next.message),
                backgroundColor: Colors.black,
              ),
            );
        }
      },
    );
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            const Text(
              'AUTONOMOUS DIAGNOSTICS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: AppTheme.secondary,
              ),
            ),

            const SizedBox(height: 12),

            Text('Weed', style: textTheme.displayLarge),
            Text('Detection', style: textTheme.displayLarge),

            const SizedBox(height: 48),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.outline.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),

                child: image == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.imagePlus,
                        size: 42,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Upload Crop Image',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Tap to choose image from gallery',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(image!.path),
                        fit: BoxFit.cover,
                      ),

                      Positioned(
                        top: 18,
                        right: 18,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              LucideIcons.refreshCcw,
                              size: 18,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: const [
                Expanded(
                  child: _FeatureCard(
                    icon: LucideIcons.leaf,
                    title: 'SPECIES',
                    subtitle: 'Identify weeds',
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: _FeatureCard(
                    icon: LucideIcons.scan,
                    title: 'ACCURATE',
                    subtitle: 'AI Detection',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _AiCard(onTap: () => context.go('/weed/history')),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: image == null ? pickImage : analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  image == null ? 'Upload Image' : 'Analyze Weed',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),

          const SizedBox(height: 24),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _AiCard({
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryContainer],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI MODEL BASED IDENTIFICATION',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Real-time weed classification',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const Icon(
                LucideIcons.archive,
                color: Colors.white24,
                size: 72,
              ),
            ],
          ),
        ),
      ),
    );
  }
}