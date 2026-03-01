import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GlowingEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const GlowingEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<GlowingEmptyState> createState() => _GlowingEmptyStateState();
}

class _GlowingEmptyStateState extends State<GlowingEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15 * _pulse.value),
                      blurRadius: 30 * _pulse.value,
                      spreadRadius: 5 * _pulse.value,
                    )
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(widget.title, style: context.textStyles.heading2),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: context.textStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
