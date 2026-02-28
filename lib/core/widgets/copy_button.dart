import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../services/toast_service.dart';

class CopyButton extends StatefulWidget {
  final String text;
  final String? label;
  final bool compact;

  const CopyButton({
    super.key,
    required this.text,
    this.label,
    this.compact = false,
  });

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton>
    with SingleTickerProviderStateMixin {
  bool _copied = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: widget.text));
    
    if (mounted) {
      ToastService.show(
        context,
        message: 'Copied to clipboard!',
        type: ToastType.success,
        duration: const Duration(seconds: 2),
      );
    }
    
    _controller.forward().then((_) => _controller.reverse());
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: _copy,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
              key: ValueKey(_copied),
              size: 18,
              color: _copied ? AppColors.success : context.adaptiveTextSecondary,
            ),
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _copy,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _copied
                ? AppColors.success.withOpacity(0.15)
                : context.adaptiveSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _copied
                  ? AppColors.success.withOpacity(0.4)
                  : context.adaptiveCardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _copied ? Icons.check_rounded : Icons.copy_rounded,
                  key: ValueKey(_copied),
                  size: 14,
                  color: _copied ? AppColors.success : context.adaptiveTextSecondary,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _copied ? 'Copied!' : (widget.label ?? 'Copy'),
                  key: ValueKey(_copied),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _copied ? AppColors.success : context.adaptiveTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
