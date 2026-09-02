import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';

class SoilDetectionPage extends StatefulWidget {
  const SoilDetectionPage({super.key});

  @override
  State<SoilDetectionPage> createState() => _SoilDetectionPageState();
}

class _SoilDetectionPageState extends State<SoilDetectionPage> {
  final TextEditingController nitrogenController =
  TextEditingController();

  final TextEditingController phosphorusController =
  TextEditingController();

  final TextEditingController potassiumController =
  TextEditingController();

  final FocusNode nitrogenFocus = FocusNode();
  final FocusNode phosphorusFocus = FocusNode();
  final FocusNode potassiumFocus = FocusNode();

  @override
  void dispose() {
    nitrogenController.dispose();
    phosphorusController.dispose();
    potassiumController.dispose();

    nitrogenFocus.dispose();
    phosphorusFocus.dispose();
    potassiumFocus.dispose();

    super.dispose();
  }

  bool get isFormValid {
    return nitrogenController.text.trim().isNotEmpty &&
        phosphorusController.text.trim().isNotEmpty &&
        potassiumController.text.trim().isNotEmpty;
  }

  void analyzeSoil() {
    FocusScope.of(context).unfocus();

    if (!isFormValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              trText('Please enter all three nutrient values.'),
            ),
            backgroundColor: AppTheme.primary,
          ),
        );

      return;
    }

    final nitrogen = double.tryParse(
      nitrogenController.text.trim(),
    );

    final phosphorus = double.tryParse(
      phosphorusController.text.trim(),
    );

    final potassium = double.tryParse(
      potassiumController.text.trim(),
    );

    if (nitrogen == null ||
        phosphorus == null ||
        potassium == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              trText('Please enter valid numeric values.'),
            ),
            backgroundColor: AppTheme.primary,
          ),
        );

      return;
    }

    // TODO:
    // Connect this to your nutrient analysis provider/API.

    debugPrint('Nitrogen: $nitrogen');
    debugPrint('Phosphorus: $phosphorus');
    debugPrint('Potassium: $potassium');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            trText('Nutrient data ready for analysis.'),
          ),
          backgroundColor: AppTheme.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.horizontalSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 32),

              _HeroSection(
                textTheme: textTheme,
              ),

              SizedBox(height: 36),

              _NutrientInputCard(
                nitrogenController: nitrogenController,
                phosphorusController: phosphorusController,
                potassiumController: potassiumController,
                nitrogenFocus: nitrogenFocus,
                phosphorusFocus: phosphorusFocus,
                potassiumFocus: potassiumFocus,
                onChanged: () {
                  setState(() {});
                },
              )
                  .animate()
                  .fadeIn(
                delay: 250.ms,
                duration: 500.ms,
              )
                  .moveY(
                begin: 20,
                end: 0,
              ),

              SizedBox(height: 24),

              _AnalysisInfoCard()
                  .animate()
                  .fadeIn(
                delay: 400.ms,
                duration: 500.ms,
              )
                  .moveY(
                begin: 20,
                end: 0,
              ),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: isFormValid ? analyzeSoil : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor:
                    AppTheme.primary.withValues(alpha: .15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Icon(
                        LucideIcons.activity,
                        size: 20,
                        color: isFormValid
                            ? Colors.white
                            : AppTheme.primary.withValues(alpha: .35),
                      ),

                      SizedBox(width: 12),

                      Text(
                        trText('Analyze Soil'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isFormValid
                              ? Colors.white
                              : AppTheme.primary.withValues(alpha: .35),
                        ),
                      ),

                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                delay: 500.ms,
                duration: 500.ms,
              )
                  .moveY(
                begin: 20,
                end: 0,
              ),

              SizedBox(height: 42),

              /// DIAGNOSTIC DATABASE
              Text(
                trText('DIAGNOSTIC DATABASE'),
                style: textTheme.labelLarge?.copyWith(
                  color: AppTheme.secondary,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .fadeIn(
                delay: 600.ms,
              ),

              SizedBox(height: 20),

              _DiagnosticRegistryCard(
                onTap: () => context.go('/soil/history'),
              )
                  .animate()
                  .fadeIn(
                delay: 650.ms,
                duration: 500.ms,
              )
                  .moveY(
                begin: 20,
                end: 0,
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
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
          trText('PRECISION SOIL ANALYTICS'),
          style: textTheme.labelLarge?.copyWith(
            color: AppTheme.secondary,
            letterSpacing: 2.8,
            fontWeight: FontWeight.w700,
          ),
        )
            .animate()
            .fadeIn(
          duration: 400.ms,
        ),

        SizedBox(height: 14),

        Text(
          trText('Soil'),
          style: textTheme.displayLarge,
        )
            .animate()
            .fadeIn(
          delay: 100.ms,
          duration: 500.ms,
        )
            .moveY(
          begin: 18,
          end: 0,
        ),

        Text(
          trText('Nutrients'),
          style: textTheme.displayLarge,
        )
            .animate()
            .fadeIn(
          delay: 180.ms,
          duration: 500.ms,
        )
            .moveY(
          begin: 18,
          end: 0,
        ),

        SizedBox(height: 24),

        Container(
          width: 70,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(100),
          ),
        )
            .animate()
            .fadeIn(
          delay: 280.ms,
        ),

        SizedBox(height: 22),

        Text(
          trText('Enter your soil nutrient readings to evaluate nitrogen, phosphorus and potassium levels and understand the nutritional condition of your soil.'),
          style: textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceVariant,
          ),
        )
            .animate()
            .fadeIn(
          delay: 350.ms,
        ),
      ],
    );
  }
}

class _NutrientInputCard extends StatelessWidget {
  final TextEditingController nitrogenController;
  final TextEditingController phosphorusController;
  final TextEditingController potassiumController;

  final FocusNode nitrogenFocus;
  final FocusNode phosphorusFocus;
  final FocusNode potassiumFocus;

  final VoidCallback onChanged;

  const _NutrientInputCard({
    required this.nitrogenController,
    required this.phosphorusController,
    required this.potassiumController,
    required this.nitrogenFocus,
    required this.phosphorusFocus,
    required this.potassiumFocus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.outline.withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  LucideIcons.layers,
                  color: AppTheme.primary,
                  size: 25,
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      trText('NPK PROFILE'),
                      style: textTheme.labelLarge?.copyWith(
                        color: AppTheme.secondary,
                        letterSpacing: 1.8,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      trText('Nutrient readings'),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),

          SizedBox(height: 28),

          Text(
            trText('ENTER SOIL VALUES'),
            style: textTheme.labelLarge?.copyWith(
              color: AppTheme.secondary,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 18),

          _NutrientField(
            controller: nitrogenController,
            focusNode: nitrogenFocus,
            nextFocusNode: phosphorusFocus,
            label: 'NITROGEN',
            symbol: 'N',
            hint: 'Enter nitrogen level',
            onChanged: onChanged,
          ),

          SizedBox(height: 16),

          _NutrientField(
            controller: phosphorusController,
            focusNode: phosphorusFocus,
            nextFocusNode: potassiumFocus,
            label: 'PHOSPHORUS',
            symbol: 'P',
            hint: 'Enter phosphorus level',
            onChanged: onChanged,
          ),

          SizedBox(height: 16),

          _NutrientField(
            controller: potassiumController,
            focusNode: potassiumFocus,
            label: 'POTASSIUM',
            symbol: 'K',
            hint: 'Enter potassium level',
            onChanged: onChanged,
            isLast: true,
          ),

        ],
      ),
    );
  }
}

class _NutrientField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;

  final String label;
  final String symbol;
  final String hint;

  final VoidCallback onChanged;
  final bool isLast;

  const _NutrientField({
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    required this.label,
    required this.symbol,
    required this.hint,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              trText(symbol),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  trText(label),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.secondary,
                  ),
                ),

                SizedBox(height: 3),

                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (_) => onChanged(),
                  keyboardType:
                  TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: isLast
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) {
                    if (nextFocusNode != null) {
                      FocusScope.of(context).requestFocus(
                        nextFocusNode,
                      );
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.outline,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

              ],
            ),
          ),

          SizedBox(width: 10),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trText('VALUE'),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppTheme.primary,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _AnalysisInfoCard extends StatelessWidget {
  const _AnalysisInfoCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.emerald.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              LucideIcons.info,
              color: AppTheme.primary,
              size: 22,
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  trText('PRECISION INPUT'),
                  style: textTheme.labelLarge?.copyWith(
                    color: AppTheme.secondary,
                    letterSpacing: 1.6,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  trText('Use the values from your latest soil test for the most reliable nutrient analysis.'),
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}

class _DiagnosticRegistryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DiagnosticRegistryCard({
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

              /// Decorative icon
              Positioned(
                right: -20,
                top: -22,
                child: Icon(
                  LucideIcons.database,
                  size: 155,
                  color: Colors.white.withValues(alpha: .05),
                ),
              ),

              /// Decorative circle
              Positioned(
                right: -55,
                bottom: -70,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .04),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      trText('NUTRIENT DATABASE'),
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: 22),

                    Text(
                      trText('Analysis'),
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
                      width: 270,
                      child: Text(
                        trText('Browse previous soil analyses, nutrient readings, fertility assessments and recommendations.'),
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
                              trText('View History'),
                              style: TextStyle(
                                fontFamily: 'Inter',
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