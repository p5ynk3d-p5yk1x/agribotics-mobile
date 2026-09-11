import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/create_soil_job_request.dart';

class SoilDetectionPage extends ConsumerStatefulWidget {
  const SoilDetectionPage({super.key});

  @override
  ConsumerState<SoilDetectionPage> createState() => _SoilDetectionPageState();
}

class _SoilDetectionPageState extends ConsumerState<SoilDetectionPage> {
  final nitrogenController = TextEditingController();
  final phosphorusController = TextEditingController();
  final potassiumController = TextEditingController();
  final organicCarbonController = TextEditingController();
  final ironController = TextEditingController();
  final zincController = TextEditingController();
  final manganeseController = TextEditingController();
  final copperController = TextEditingController();
  final boronController = TextEditingController();
  final sulphurController = TextEditingController();
  final salinityController = TextEditingController();
  final electricalConductivityController = TextEditingController();
  final phController = TextEditingController();

  final nitrogenFocus = FocusNode();
  final phosphorusFocus = FocusNode();
  final potassiumFocus = FocusNode();
  final organicCarbonFocus = FocusNode();

  bool optionalExpanded = false;

  List<TextEditingController> get _controllers => [
    nitrogenController,
    phosphorusController,
    potassiumController,
    organicCarbonController,
    ironController,
    zincController,
    manganeseController,
    copperController,
    boronController,
    sulphurController,
    salinityController,
    electricalConductivityController,
    phController,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    nitrogenFocus.dispose();
    phosphorusFocus.dispose();
    potassiumFocus.dispose();
    organicCarbonFocus.dispose();

    super.dispose();
  }

  double? _requiredValue(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim());
    if (value == null || value < 0) return null;
    return value;
  }

  double? _optionalValue(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  bool _optionalFieldValid(TextEditingController controller,{double? max}) {
    final text = controller.text.trim();
    if (text.isEmpty) return true;

    final value = double.tryParse(text);

    if (value == null || value < 0) return false;
    if (max != null && value > max) return false;

    return true;
  }

  bool get isFormValid {
    if (_requiredValue(nitrogenController) == null) return false;
    if (_requiredValue(phosphorusController) == null) return false;
    if (_requiredValue(potassiumController) == null) return false;
    if (_requiredValue(organicCarbonController) == null) return false;
    if (!_optionalFieldValid(ironController)) return false;
    if (!_optionalFieldValid(zincController)) return false;
    if (!_optionalFieldValid(manganeseController)) return false;
    if (!_optionalFieldValid(copperController)) return false;
    if (!_optionalFieldValid(boronController)) return false;
    if (!_optionalFieldValid(sulphurController)) return false;
    if (!_optionalFieldValid(salinityController)) return false;
    if (!_optionalFieldValid(electricalConductivityController)) return false;
    if (!_optionalFieldValid(phController,max: 14)) return false;
    return true;
  }

  Future<void> analyzeSoil() async {
    FocusScope.of(context).unfocus();

    if (!isFormValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Enter valid mandatory nutrient values and check any optional readings.'),
            backgroundColor: AppTheme.primary,
          ),
        );

      return;
    }

    final request = CreateSoilJobRequest(
      nitrogenLevel: _requiredValue(nitrogenController)!,
      phosphorousLevel: _requiredValue(phosphorusController)!,
      potassiumLevel: _requiredValue(potassiumController)!,
      organicCarbonLevel: _requiredValue(organicCarbonController)!,
      ironLevel: _optionalValue(ironController),
      zincLevel: _optionalValue(zincController),
      manganeseLevel: _optionalValue(manganeseController),
      copperLevel: _optionalValue(copperController),
      boronLevel: _optionalValue(boronController),
      sulphurLevel: _optionalValue(sulphurController),
      salinityLevel: _optionalValue(salinityController),
      electricalConductivity: _optionalValue(electricalConductivityController),
      pH: _optionalValue(phController),
    );

    final success = await ref.read(soilProvider.notifier).submitAnalysis(request);

    if (!mounted) return;

    if (success) {
      ref.invalidate(soilJobsProvider);

      final state = ref.read(soilProvider);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.jobId != null
                  ? 'Soil analysis queued successfully.'
                  : 'Soil analysis submitted successfully.',
            ),
            backgroundColor: AppTheme.primary,
          ),
        );

      return;
    }

    final error = ref.read(soilProvider).error;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Unable to submit soil analysis.'),
          backgroundColor: AppTheme.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final soilState = ref.watch(soilProvider);
    final canSubmit = isFormValid && !soilState.loading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _HeroSection(textTheme: textTheme),
              const SizedBox(height: 36),
              _MandatoryNutrientCard(
                nitrogenController: nitrogenController,
                phosphorusController: phosphorusController,
                potassiumController: potassiumController,
                organicCarbonController: organicCarbonController,
                nitrogenFocus: nitrogenFocus,
                phosphorusFocus: phosphorusFocus,
                potassiumFocus: potassiumFocus,
                organicCarbonFocus: organicCarbonFocus,
                onChanged: () => setState(() {}),
              ).animate().fadeIn(delay: 250.ms,duration: 500.ms).moveY(begin: 20,end: 0),
              const SizedBox(height: 24),
              _OptionalNutrientCard(
                expanded: optionalExpanded,
                onToggle: () => setState(() => optionalExpanded = !optionalExpanded),
                ironController: ironController,
                zincController: zincController,
                manganeseController: manganeseController,
                copperController: copperController,
                boronController: boronController,
                sulphurController: sulphurController,
                salinityController: salinityController,
                electricalConductivityController: electricalConductivityController,
                phController: phController,
                onChanged: () => setState(() {}),
              ).animate().fadeIn(delay: 350.ms,duration: 500.ms).moveY(begin: 20,end: 0),
              const SizedBox(height: 24),
              const _AnalysisInfoCard().animate().fadeIn(delay: 400.ms,duration: 500.ms).moveY(begin: 20,end: 0),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: canSubmit ? analyzeSoil : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary.withValues(alpha: .15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: soilState.loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5,color: Colors.white),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.activity,
                        size: 20,
                        color: canSubmit ? Colors.white : AppTheme.primary.withValues(alpha: .35),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Analyze Soil',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: canSubmit ? Colors.white : AppTheme.primary.withValues(alpha: .35),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms,duration: 500.ms).moveY(begin: 20,end: 0),
              const SizedBox(height: 42),
              Text(
                'DIAGNOSTIC DATABASE',
                style: textTheme.labelLarge?.copyWith(
                  color: AppTheme.secondary,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 20),
              _DiagnosticRegistryCard(
                onTap: () => context.go('/soil/history'),
              ).animate().fadeIn(delay: 650.ms,duration: 500.ms).moveY(begin: 20,end: 0),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TextTheme textTheme;

  const _HeroSection({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRECISION SOIL ANALYTICS',
          style: textTheme.labelLarge?.copyWith(
            color: AppTheme.secondary,
            letterSpacing: 2.8,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 14),
        Text('Soil',style: textTheme.displayLarge).animate().fadeIn(delay: 100.ms,duration: 500.ms).moveY(begin: 18,end: 0),
        Text('Nutrients',style: textTheme.displayLarge).animate().fadeIn(delay: 180.ms,duration: 500.ms).moveY(begin: 18,end: 0),
        const SizedBox(height: 24),
        Container(
          width: 70,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(100),
          ),
        ).animate().fadeIn(delay: 280.ms),
        const SizedBox(height: 22),
        Text(
          'Enter your primary soil nutrient readings and optionally provide additional micronutrient and soil-condition measurements for a more complete analysis.',
          style: textTheme.bodyLarge?.copyWith(color: AppTheme.onSurfaceVariant),
        ).animate().fadeIn(delay: 350.ms),
      ],
    );
  }
}

class _MandatoryNutrientCard extends StatelessWidget {
  final TextEditingController nitrogenController;
  final TextEditingController phosphorusController;
  final TextEditingController potassiumController;
  final TextEditingController organicCarbonController;
  final FocusNode nitrogenFocus;
  final FocusNode phosphorusFocus;
  final FocusNode potassiumFocus;
  final FocusNode organicCarbonFocus;
  final VoidCallback onChanged;

  const _MandatoryNutrientCard({
    required this.nitrogenController,
    required this.phosphorusController,
    required this.potassiumController,
    required this.organicCarbonController,
    required this.nitrogenFocus,
    required this.phosphorusFocus,
    required this.potassiumFocus,
    required this.organicCarbonFocus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _CardContainer(
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
                child: const Icon(LucideIcons.layers,color: AppTheme.primary,size: 25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRIMARY PROFILE',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppTheme.secondary,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Required readings',
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              _RequirementBadge(text: 'REQUIRED'),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'ENTER SOIL VALUES',
            style: textTheme.labelLarge?.copyWith(
              color: AppTheme.secondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          _NutrientField(
            controller: nitrogenController,
            focusNode: nitrogenFocus,
            nextFocusNode: phosphorusFocus,
            label: 'NITROGEN',
            symbol: 'N',
            hint: 'Enter nitrogen level',
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          _NutrientField(
            controller: phosphorusController,
            focusNode: phosphorusFocus,
            nextFocusNode: potassiumFocus,
            label: 'PHOSPHOROUS',
            symbol: 'P',
            hint: 'Enter phosphorous level',
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          _NutrientField(
            controller: potassiumController,
            focusNode: potassiumFocus,
            nextFocusNode: organicCarbonFocus,
            label: 'POTASSIUM',
            symbol: 'K',
            hint: 'Enter potassium level',
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          _NutrientField(
            controller: organicCarbonController,
            focusNode: organicCarbonFocus,
            label: 'ORGANIC CARBON',
            symbol: 'OC',
            hint: 'Enter organic carbon level',
            onChanged: onChanged,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _OptionalNutrientCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final TextEditingController ironController;
  final TextEditingController zincController;
  final TextEditingController manganeseController;
  final TextEditingController copperController;
  final TextEditingController boronController;
  final TextEditingController sulphurController;
  final TextEditingController salinityController;
  final TextEditingController electricalConductivityController;
  final TextEditingController phController;
  final VoidCallback onChanged;

  const _OptionalNutrientCard({
    required this.expanded,
    required this.onToggle,
    required this.ironController,
    required this.zincController,
    required this.manganeseController,
    required this.copperController,
    required this.boronController,
    required this.sulphurController,
    required this.salinityController,
    required this.electricalConductivityController,
    required this.phController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.emerald.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(LucideIcons.flaskConical,color: AppTheme.primary,size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXTENDED PROFILE',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppTheme.secondary,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Optional readings',
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  _RequirementBadge(text: 'OPTIONAL'),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 220),
                    turns: expanded ? .5 : 0,
                    child: const Icon(LucideIcons.chevronDown,color: AppTheme.secondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Text(
                  'ADDITIONAL SOIL PARAMETERS',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppTheme.secondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Leave any unavailable reading empty.',
                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                _OptionalField(
                  controller: ironController,
                  label: 'IRON',
                  symbol: 'Fe',
                  hint: 'Enter iron level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: zincController,
                  label: 'ZINC',
                  symbol: 'Zn',
                  hint: 'Enter zinc level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: manganeseController,
                  label: 'MANGANESE',
                  symbol: 'Mn',
                  hint: 'Enter manganese level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: copperController,
                  label: 'COPPER',
                  symbol: 'Cu',
                  hint: 'Enter copper level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: boronController,
                  label: 'BORON',
                  symbol: 'B',
                  hint: 'Enter boron level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: sulphurController,
                  label: 'SULPHUR',
                  symbol: 'S',
                  hint: 'Enter sulphur level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: salinityController,
                  label: 'SALINITY',
                  symbol: 'SAL',
                  hint: 'Enter salinity level',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: electricalConductivityController,
                  label: 'ELECTRICAL CONDUCTIVITY',
                  symbol: 'EC',
                  hint: 'Enter conductivity value',
                  onChanged: onChanged,
                ),
                const SizedBox(height: 14),
                _OptionalField(
                  controller: phController,
                  label: 'PH',
                  symbol: 'pH',
                  hint: 'Enter pH from 0 to 14',
                  onChanged: onChanged,
                  trailing: '0–14',
                ),
              ],
            ),
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
    return _InputShell(
      controller: controller,
      focusNode: focusNode,
      nextFocusNode: nextFocusNode,
      label: label,
      symbol: symbol,
      hint: hint,
      onChanged: onChanged,
      isLast: isLast,
      trailing: 'VALUE',
    );
  }
}

class _OptionalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String symbol;
  final String hint;
  final String trailing;
  final VoidCallback onChanged;

  const _OptionalField({
    required this.controller,
    required this.label,
    required this.symbol,
    required this.hint,
    required this.onChanged,
    this.trailing = 'OPTIONAL',
  });

  @override
  Widget build(BuildContext context) {
    return _InputShell(
      controller: controller,
      label: label,
      symbol: symbol,
      hint: hint,
      onChanged: onChanged,
      isLast: true,
      trailing: trailing,
    );
  }
}

class _InputShell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String label;
  final String symbol;
  final String hint;
  final String trailing;
  final VoidCallback onChanged;
  final bool isLast;

  const _InputShell({
    required this.controller,
    this.focusNode,
    this.nextFocusNode,
    required this.label,
    required this.symbol,
    required this.hint,
    required this.trailing,
    required this.onChanged,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16,14,16,14),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  symbol,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 3),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (_) => onChanged(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                  onSubmitted: (_) {
                    if (nextFocusNode != null) {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    } else {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trailing,
              style: const TextStyle(
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

class _RequirementBadge extends StatelessWidget {
  final String text;

  const _RequirementBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.outline.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: const Offset(0,10),
          ),
        ],
      ),
      child: child,
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
      padding: const EdgeInsets.all(24),
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
            child: const Icon(LucideIcons.info,color: AppTheme.primary,size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRECISION INPUT',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppTheme.secondary,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nitrogen, phosphorous, potassium and organic carbon are required. Additional soil readings can improve the completeness of the analysis.',
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
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

  const _DiagnosticRegistryCard({required this.onTap});

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
            gradient: const LinearGradient(
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
              Positioned(
                right: -20,
                top: -22,
                child: Icon(
                  LucideIcons.database,
                  size: 155,
                  color: Colors.white.withValues(alpha: .05),
                ),
              ),
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
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NUTRIENT DATABASE',
                      style: textTheme.labelLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Analysis',
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'History',
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 270,
                      child: Text(
                        'Browse previous soil analyses, nutrient readings, fertility assessments and recommendations.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(LucideIcons.archive,color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'View History',
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
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(LucideIcons.arrowRight,color: AppTheme.primary),
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