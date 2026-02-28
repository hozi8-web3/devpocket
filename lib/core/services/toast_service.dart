import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/frosted_glass.dart';

enum ToastType { success, error, info }

class ToastService {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    _overlayEntry = _createOverlayEntry(context, message, type);
    Overlay.of(context).insert(_overlayEntry!);

    HapticFeedback.lightImpact();

    Future.delayed(duration, () {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String message,
    ToastType type,
  ) {
    Color getIconColor() {
      switch (type) {
        case ToastType.success:
          return AppColors.success;
        case ToastType.error:
          return AppColors.danger;
        case ToastType.info:
          return AppColors.primary;
      }
    }

    IconData getIcon() {
      switch (type) {
        case ToastType.success:
          return Icons.check_circle_rounded;
        case ToastType.error:
          return Icons.error_rounded;
        case ToastType.info:
          return Icons.info_rounded;
      }
    }

    return OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        iconData: getIcon(),
        iconColor: getIconColor(),
      ),
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData iconData;
  final Color iconColor;

  const _ToastWidget({
    required this.message,
    required this.iconData,
    required this.iconColor,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
        
    _slideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: FrostedGlass(
              blur: 15,
              color: AppColors.surface.withOpacity(0.85),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: widget.iconColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.iconData, color: widget.iconColor, size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: context.textStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
