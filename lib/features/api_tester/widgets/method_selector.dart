import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

class MethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const MethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const methods = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS'
  ];

  Color _colorFor(String method) {
    return switch (method) {
      'GET' => AppColors.methodGet,
      'POST' => AppColors.methodPost,
      'PUT' => AppColors.methodPut,
      'PATCH' => AppColors.methodPatch,
      'DELETE' => AppColors.methodDelete,
      'HEAD' => AppColors.methodHead,
      _ => AppColors.methodOptions,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(selected);
    return PopupMenuButton<String>(
      initialValue: selected,
      tooltip: 'Change Method',
      offset: const Offset(0, 40),
      color: context.adaptiveSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.adaptiveGlassBorder),
      ),
      onSelected: (method) {
        HapticFeedback.lightImpact();
        onChanged(method);
      },
      itemBuilder: (context) {
        return methods.map((method) {
          final mColor = _colorFor(method);
          return PopupMenuItem<String>(
            value: method,
            child: Text(
              method,
              style: context.textStyles.buttonSmall.copyWith(
                color: mColor,
                fontSize: 12,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: context.textStyles.buttonSmall.copyWith(
                color: color,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
