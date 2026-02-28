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

  static const methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS'];

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
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: methods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final method = methods[i];
          final isSelected = selected == method;
          final color = _colorFor(method);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(method);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : AppColors.glassSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.5) : AppColors.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)]
                    : null,
              ),
              child: Text(
                method,
                style: AppTextStyles.buttonSmall.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
