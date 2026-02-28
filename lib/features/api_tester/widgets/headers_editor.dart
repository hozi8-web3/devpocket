import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HeadersEditor extends StatefulWidget {
  final Map<String, String> pairs;
  final ValueChanged<Map<String, String>> onChanged;
  final String keyHint;
  final String valueHint;

  const HeadersEditor({
    super.key,
    required this.pairs,
    required this.onChanged,
    this.keyHint = 'Key',
    this.valueHint = 'Value',
  });

  @override
  State<HeadersEditor> createState() => _HeadersEditorState();
}

class _HeadersEditorState extends State<HeadersEditor> {
  late List<MapEntry<String, String>> _entries;
  List<TextEditingController> _keyControllers = [];
  List<TextEditingController> _valControllers = [];
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _entries = widget.pairs.entries.toList();
    _initControllers();
  }

  @override
  void didUpdateWidget(HeadersEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pairs != oldWidget.pairs) {
      _entries = widget.pairs.entries.toList();
      _initControllers();
    }
  }

  void _initControllers() {
    // Dispose old controllers before creating new ones
    if (_controllersInitialized) {
      for (final c in _keyControllers) c.dispose();
      for (final c in _valControllers) c.dispose();
    }
    _keyControllers =
        _entries.map((e) => TextEditingController(text: e.key)).toList();
    _valControllers =
        _entries.map((e) => TextEditingController(text: e.value)).toList();
    _controllersInitialized = true;
  }

  void _notify() {
    final map = <String, String>{};
    for (int i = 0; i < _keyControllers.length; i++) {
      final k = _keyControllers[i].text.trim();
      final v = _valControllers[i].text.trim();
      if (k.isNotEmpty) map[k] = v;
    }
    widget.onChanged(map);
  }

  void _add() {
    setState(() {
      _keyControllers.add(TextEditingController());
      _valControllers.add(TextEditingController());
    });
  }

  void _remove(int i) {
    setState(() {
      _keyControllers[i].dispose();
      _valControllers[i].dispose();
      _keyControllers.removeAt(i);
      _valControllers.removeAt(i);
    });
    _notify();
  }

  @override
  void dispose() {
    for (final c in _keyControllers) c.dispose();
    for (final c in _valControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Empty state hint
          if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'No ${widget.keyHint.toLowerCase()}s yet — tap + to add',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ...List.generate(_keyControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keyControllers[i],
                      onChanged: (_) => _notify(),
                      style: context.textStyles.codeSmall.copyWith(color: AppColors.primary),
                      decoration: InputDecoration(
                        hintText: widget.keyHint,
                        hintStyle: context.textStyles.codeSmall.copyWith(
                          color: context.adaptiveTextSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      ':',
                      style: context.textStyles.codeMedium.copyWith(
                        color: context.adaptiveTextSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _valControllers[i],
                      onChanged: (_) => _notify(),
                      style: context.textStyles.codeSmall.copyWith(
                        color: context.adaptiveTextPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.valueHint,
                        hintStyle: context.textStyles.codeSmall.copyWith(
                          color: context.adaptiveTextSecondary,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                    color: context.adaptiveTextSecondary,
                    onPressed: () => _remove(i),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('Add ${widget.keyHint}'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: context.textStyles.label,
            ),
          ),
        ],
      ),
    );
  }
}
