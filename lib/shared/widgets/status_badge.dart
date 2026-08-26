import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? AppTheme.tertiaryFixed,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: textColor ?? AppTheme.onSurface,
        ),
      ),
    );
  }
}
