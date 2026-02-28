import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum StatusBadgeType { success, error, warning, info, neutral, custom }

extension StatusBadgeTypeExt on StatusBadgeType {
  static StatusBadgeType typeForHttpCode(int code) {
    if (code >= 200 && code < 300) return StatusBadgeType.success;
    if (code >= 300 && code < 400) return StatusBadgeType.info;
    if (code >= 400 && code < 500) return StatusBadgeType.warning;
    if (code >= 500) return StatusBadgeType.error;
    return StatusBadgeType.neutral;
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;
  final Color? customColor;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.neutral,
    this.customColor,
    this.showDot = false,
  });

  Color get _color {
    if (customColor != null) return customColor!;
    switch (type) {
      case StatusBadgeType.success:
        return AppColors.success;
      case StatusBadgeType.error:
        return AppColors.danger;
      case StatusBadgeType.warning:
        return AppColors.warning;
      case StatusBadgeType.info:
        return AppColors.info;
      case StatusBadgeType.neutral:
        return AppColors.textSecondary;
      case StatusBadgeType.custom:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8, offset: Offset.zero),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
