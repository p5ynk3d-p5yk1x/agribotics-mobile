import 'package:agribotics/core/localization/localized_text.dart';
import 'dart:io';

import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/features/disease/data/disease_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';

class DiseaseDetectionPage extends ConsumerStatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  ConsumerState<DiseaseDetectionPage>
  createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends ConsumerState<DiseaseDetectionPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? image;

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    setState(() {
      image = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    ref.listen<DiseaseState>(diseaseProvider, (previous, next) {
        if (next.success) {
          context.go("/disease/history");
          ref.read(diseaseProvider.notifier,).reset();
        }
        if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                trText(next.error!),
              ),
            ),
          );
        }
      });
    final diseaseState = ref.watch(diseaseProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.horizontalSpacing,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 40),

            /// Hero
            _HeroSection(
              textTheme: textTheme,
            ),

            SizedBox(height: 40),

            /// Scanner
            _ScannerCard(
              image: image,
              onUpload: pickImage,
            ),

            SizedBox(height: 36),

            /// CTA
            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: diseaseState.loading ? null : image == null ? null : () {ref.read(diseaseProvider.notifier).submitDiagnosis(File(image!.path),);},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                ),
                child: diseaseState.loading ?
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ) : Text(
                  trText('Run Diagnosis'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 36),

            /// Indicators
            _HealthIndicators()
                .animate()
                .fadeIn(delay: 450.ms)
                .moveY(begin: 20, end: 0),

            SizedBox(height: 20),

            Text(
              trText('DIAGNOSTIC DATABASE'),
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.secondary,
                letterSpacing: 2,
              ),
            ),

            SizedBox(height: 20),

            _RegistryCard(
              onTap: () => context.go('/disease/history'),
            )
                .animate()
                .fadeIn(delay: 650.ms)
                .moveY(begin: 20, end: 0),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _HealthIndicators extends StatelessWidget {
  const _HealthIndicators();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          trText('PLANT HEALTH INDICATORS'),
          style: textTheme.labelLarge?.copyWith(
            letterSpacing: 2,
            color: AppTheme.secondary,
          ),
        ),

        SizedBox(height: 22),

        Row(
          children: [

            Expanded(
              child: _IndicatorCard(
                icon: LucideIcons.microscope,
                title: 'VISUAL\nSYMPTOMS',
                description:
                'Detect lesions, discoloration, fungal spots and abnormal foliage.',
              ),
            ),

            SizedBox(width: 16),

            Expanded(
              child: _IndicatorCard(
                icon: LucideIcons.cpu,
                title: 'AI\nDIAGNOSTICS',
                description:
                'CNN-powered disease classification with confidence scoring.',
              ),
            ),

          ],
        ),
      ],
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _IndicatorCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.outline.withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 26,
            ),
          ),

          SizedBox(height: 24),

          Text(
            trText(title),
            style: textTheme.titleLarge?.copyWith(
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 16),

          Text(
            trText(description),
            style: textTheme.bodyMedium,
          ),

          SizedBox(height: 22),

          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.emerald,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TextTheme textTheme;

  const _HeroSection({
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          trText('AUTONOMOUS PLANT PATHOLOGY'),
          style: textTheme.labelLarge?.copyWith(
            color: Colors.redAccent.shade200,
            letterSpacing: 2.8,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 14),

        Text(
          trText('Disease'),
          style: textTheme.displayLarge,
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .moveY(begin: 18, end: 0),

        Text(
          trText('Detection'),
          style: textTheme.displayLarge,
        )
            .animate()
            .fadeIn(
          delay: 120.ms,
          duration: 500.ms,
        )
            .moveY(begin: 18, end: 0),

        SizedBox(height: 26),

        Container(
          width: 70,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(100),
          ),
        )
            .animate()
            .fadeIn(delay: 250.ms),

        SizedBox(height: 24),

        Text(
          trText('Scan infected foliage to identify plant diseases, estimate severity, and receive AI-powered diagnostic insights before outbreaks spread.'),
          style: textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        )
            .animate()
            .fadeIn(delay: 350.ms),

        SizedBox(height: 32),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [

              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  LucideIcons.microscope,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      trText('AI PATHOLOGY ENGINE'),
                      style: textTheme.labelLarge?.copyWith(
                        color: AppTheme.secondary,
                        letterSpacing: 1.5,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      trText('Ready for diagnostic scan'),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.emerald,
                  shape: BoxShape.circle,
                ),
              ),

            ],
          ),
        )
            .animate()
            .fadeIn(delay: 450.ms)
            .moveY(begin: 10, end: 0),

      ],
    );
  }
}

class _ScannerCard extends StatelessWidget {
  final XFile? image;
  final VoidCallback onUpload;

  const _ScannerCard({
    required this.image,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: image == null ? onUpload : null,
      child: Container(
        height: 430,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary,
              AppTheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(36),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            fit: StackFit.expand,
            children: [

              ///
              /// Background Image
              ///
              if (image != null)
                Image.file(
                  File(image!.path),
                  fit: BoxFit.cover,
                ),

              ///
              /// Dark Overlay
              ///
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                color: image == null
                    ? Colors.transparent
                    : Colors.black.withValues(alpha: .35),
              ),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.emerald.withValues(alpha: .12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                  begin: Offset(.96, .96),
                  end: Offset(1.04, 1.04),
                  duration: 2200.ms,
                ),
              ),
              _ScannerOverlay(),

              ///
              /// Empty State
              ///
              if (image == null)
                _EmptyScannerState(
                  onUpload: onUpload,
                ),

              ///
              /// Image Loaded State
              ///
              if (image != null)
                _ImageLoadedState(
                  onReplace: onUpload,
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0);
  }
}

class _ImageLoadedState extends StatelessWidget {
  final VoidCallback onReplace;

  const _ImageLoadedState({
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned(
          top: 22,
          left: 22,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.emerald,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 14,
                ),

                SizedBox(width: 6),

                Text(
                  trText("SCAN READY"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),

              ],
            ),
          ),
        ),

        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: onReplace,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                LucideIcons.refreshCcw,
                color: AppTheme.primary,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 26,
          left: 26,
          right: 26,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [

                Icon(
                  LucideIcons.microscope,
                  color: Colors.white,
                ),

                SizedBox(width: 14),

                Expanded(
                  child: Text(
                    trText('Image loaded. Ready to begin disease diagnosis.'),
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyScannerState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyScannerState({
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.scan,
                color: Colors.white,
                size: 42,
              ),
            ),

            SizedBox(height: 32),

            Text(
              trText('Plant Scan'),
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),

            SizedBox(height: 14),

            Text(
              trText('Upload a close photograph of infected foliage for AI pathology analysis.'),
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 36),

            FilledButton.icon(
              onPressed: onUpload,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: Icon(LucideIcons.imagePlus),
              label: Text(trText("Choose Image")),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [

          /// Corner brackets
          Positioned(
            top: 26,
            left: 26,
            child: _CornerBracket(
              top: true,
              left: true,
            ),
          ),

          Positioned(
            top: 26,
            right: 26,
            child: _CornerBracket(
              top: true,
              left: false,
            ),
          ),

          Positioned(
            bottom: 26,
            left: 26,
            child: _CornerBracket(
              top: false,
              left: true,
            ),
          ),

          Positioned(
            bottom: 26,
            right: 26,
            child: _CornerBracket(
              top: false,
              left: false,
            ),
          ),

          /// Center Scan Window
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .22),
                  width: 1,
                ),
              ),
            ),
          ),

          /// Animated Scan Line
          _ScanningLine(),

          /// Subtle Grid
          _ScannerGrid(),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool top;
  final bool left;

  const _CornerBracket({
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _CornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  const _CornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (top && left) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    }

    if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }

    if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    }

    if (!top && !left) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _ScanningLine extends StatelessWidget {
  const _ScanningLine();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: .15,
        end: .85,
      ),
      duration: Duration(seconds: 3),
      curve: Curves.easeInOut,
      onEnd: () {},
      builder: (context, value, child) {
        return Align(
          alignment: Alignment(0, value * 2 - 1),
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 48),
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppTheme.emerald,
              Colors.white,
              AppTheme.emerald,
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.emerald.withValues(alpha: .8),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat());
  }
}

class _ScannerGrid extends StatelessWidget {
  const _ScannerGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .03)
      ..strokeWidth = .8;

    double gap = 28.0;

    for (double x = gap; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _RegistryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RegistryCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(34),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(34),
          ),
          child: Stack(
            children: [

              ///
              /// Decorative Icon
              ///
              Positioned(
                right: -18,
                top: -18,
                child: Icon(
                  LucideIcons.bookOpen,
                  size: 150,
                  color: Colors.white.withValues(alpha: .05),
                ),
              ),

              ///
              /// Decorative Circle
              ///
              Positioned(
                bottom: -70,
                right: -50,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .04),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      trText('DISEASE REGISTRY'),
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: 22),

                    Text(
                      trText('Diagnostic'),
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    Text(
                      trText('History'),
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: 250,
                      child: Text(
                        trText('Browse previous AI diagnoses, confidence scores, disease progression and treatment recommendations.'),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ),

                    SizedBox(height: 34),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        Row(
                          children: [

                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: Icon(
                                LucideIcons.archive,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 16),

                            Text(
                              trText('View Registry'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                          ],
                        ),

                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(18),
                          ),
                          child: Icon(
                            LucideIcons.arrowRight,
                            color: AppTheme.primary,
                          ),
                        ),

                      ],
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