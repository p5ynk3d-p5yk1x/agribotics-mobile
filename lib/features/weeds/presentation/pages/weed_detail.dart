import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class WeedDetails extends StatelessWidget {
  const WeedDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _PhotoHeader(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 48),
                  Text(
                    trText('FUNGAL IDENTIFICATION'),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
                  ),
                  SizedBox(height: 12),
                  Text(trText('Downy Mildew.'), style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                  SizedBox(height: 24),
                  Text(
                    trText('Characterized by yellow-to-pale-green patches on the upper leaf surface, with visible white-to-grayish "downy" fungal growth underneath.'),
                    style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant, height: 1.6),
                  ),
                  SizedBox(height: 48),
                  _RemedyToggleSection(),
                  SizedBox(height: 48),
                  _StrategySection(),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.network(
            'https://picsum.photos/seed/mildew/800/600',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(icon: Icon(LucideIcons.arrowLeft, color: AppTheme.primary), onPressed: () => Navigator.pop(context)),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
            child: Row(
              children: [
                Icon(LucideIcons.target, color: AppTheme.primary, size: 14),
                SizedBox(width: 8),
                Text(trText('98% CONFIDENCE'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RemedyToggleSection extends StatelessWidget {
  const _RemedyToggleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppTheme.onSurfaceVariant.withOpacity(0.05), borderRadius: BorderRadius.circular(100)),
          child: Row(
            children: [
              Expanded(
                child: _ToggleButton(label: 'ORGANIC REMEDY', isActive: true),
              ),
              Expanded(
                child: _ToggleButton(label: 'CHEMICAL SHIELD', isActive: false),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        _RemedyDetail(
          title: 'Copper-Based Fungicide',
          description: 'Apply a liquid copper fungicide to the foliage. Ensure thorough coverage of both upper and lower leaf surfaces.',
        ),
        SizedBox(height: 32),
        _RemedyDetail(
          title: 'Neem Oil Emulsion',
          description: 'Acts as a natural surfactant and antifungal. Apply during low sun exposure to prevent leaf scorch.',
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  const _ToggleButton({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
      ),
      child: Center(
        child: Text(
          trText(label),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppTheme.primary : AppTheme.outline),
        ),
      ),
    );
  }
}

class _RemedyDetail extends StatelessWidget {
  final String title;
  final String description;
  const _RemedyDetail({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LucideIcons.checkCircle2, color: AppTheme.primary, size: 20),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trText(title), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Text(trText(description), style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StrategySection extends StatelessWidget {
  const _StrategySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trText('PREVENTION STRATEGY'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.secondary)),
          SizedBox(height: 24),
          Text(trText('Canopy Thinning'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(
            trText('Improve air circulation by pruning dense foliage. Avoid overhead watering to keep leaf surfaces dry.'),
            style: TextStyle(color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
          SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(trText('Add to Care Plan'), style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
