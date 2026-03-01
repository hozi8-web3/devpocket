import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:flutter/services.dart';

class ToolCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isNew;
  final String heroTag;

  const ToolCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isNew = false,
    required this.heroTag,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          _controller.forward();
          setState(() => _pressed = true);
        },
        onTapUp: (_) {
          _controller.reverse();
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () {
          _controller.reverse();
          setState(() => _pressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: context.adaptiveCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _pressed
                  ? widget.color.withValues(alpha: 0.4)
                  : context.adaptiveCardBorder,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.color.withValues(alpha: 0.25)),
                    ),
                    child: Hero(
                      tag: widget.heroTag,
                      child: Icon(widget.icon, color: widget.color, size: 22),
                    ),
                  ),
                  const Spacer(),
                  if (widget.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'NEW',
                        style: context.textStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: context.textStyles.heading3.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: context.textStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
