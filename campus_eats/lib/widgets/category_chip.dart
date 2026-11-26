import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CategoryChipWidget extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChipWidget({
    super.key,
    required this.label,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: (color ?? AppTheme.primary).withOpacity(0.2),
        checkmarkColor: color ?? AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? (color ?? AppTheme.primary) : AppTheme.onSurfaceDim,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        backgroundColor: AppTheme.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? (color ?? AppTheme.primary).withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
      ),
    );
  }
}
