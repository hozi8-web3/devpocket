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
  late List<TextEditingController> _keyControllers;
  late List<TextEditingController> _valControllers;

  @override
  void initState() {
    super.initState();
    _entries = widget.pairs.entries.toList();
    _initControllers();
  }

  void _initControllers() {
    _keyControllers = _entries.map((e) => TextEditingController(text: e.key)).toList();
    _valControllers = _entries.map((e) => TextEditingController(text: e.value)).toList();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(':', style: context.textStyles.codeMedium.copyWith(color: AppColors.textMuted)),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _valControllers[i],
                    onChanged: (_) => _notify(),
                    style: context.textStyles.codeSmall.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: widget.valueHint,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
                  color: AppColors.textMuted,
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
    );
  }
}
