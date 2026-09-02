import 'package:agribotics/core/localization/localized_text.dart';
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
                content: Text(trText(next.message)),
                backgroundColor: Colors.black,
              ),
            );
        }
      },
    );
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),

            Text(
              trText('AUTONOMOUS DIAGNOSTICS'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: AppTheme.secondary,
              ),
            ),

            SizedBox(height: 12),

            Text(trText('Weed'), style: textTheme.displayLarge),
            Text(trText('Detection'), style: textTheme.displayLarge),

            SizedBox(height: 48),

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
                      padding: EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.imagePlus,
                        size: 42,
                        color: AppTheme.primary,
                      ),
                    ),

                    SizedBox(height: 28),

                    Text(
                      trText('Upload Crop Image'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      trText('Tap to choose image from gallery'),
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
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
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

            SizedBox(height: 40),

            Row(
              children: [
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

            SizedBox(height: 16),

            _AiCard(onTap: () => context.go('/weed/history')),

            SizedBox(height: 48),

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
                  trText(image == null ? 'Upload Image' : 'Analyze Weed'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 120),
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),

          SizedBox(height: 24),

          Text(
            trText(title),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 8),

          Text(
            trText(subtitle),
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
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryContainer],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trText('AI MODEL BASED IDENTIFICATION'),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 18),

                  Text(
                    trText('History'),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    trText('Real-time weed classification'),
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              Icon(
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