import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CodeDisplay extends StatelessWidget {
  final String code;
  final String language;
  final bool showLineNumbers;
  final bool showCopyButton;
  final double? maxHeight;

  const CodeDisplay({
    super.key,
    required this.code,
    this.language = 'json',
    this.showLineNumbers = true,
    this.showCopyButton = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');

    return Container(
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.adaptiveCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    language.toUpperCase(),
                    style: context.textStyles.codeSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                if (showCopyButton)
                  _CopyIconButton(code: code),
              ],
            ),
          ),
          // Code body
          Flexible(
            child: SingleChildScrollView(
              child: showLineNumbers
                  ? _buildWithLineNumbers(context, lines)
                  : _buildHighlight(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithLineNumbers(BuildContext context, List<String> lines) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line numbers column
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              lines.length,
              (i) => SizedBox(
                height: 20.8, // line height
                child: Text(
                  '${i + 1}',
                  style: context.textStyles.lineNumber,
                ),
              ),
            ),
          ),
        ),
        // Highlighted code
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: HighlightView(
              code,
              language: language,
              theme: atomOneDarkTheme,
              textStyle: context.textStyles.code,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlight(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: HighlightView(
        code,
        language: language,
        theme: atomOneDarkTheme,
        textStyle: context.textStyles.code,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _CopyIconButton extends StatefulWidget {
  final String code;
  const _CopyIconButton({required this.code});

  @override
  State<_CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<_CopyIconButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await ClipboardHelper.copy(widget.code);
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        key: ValueKey(_copied),
        onTap: _copy,
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          size: 16,
          color: _copied ? AppColors.success : AppColors.textMuted,
        ),
      ),
    );
  }
}

// Needed import — placed here to avoid circular imports
class ClipboardHelper {
  static Future<void> copy(String text) async {
    final data = ClipboardData(text: text);
    await Clipboard.setData(data);
  }
}