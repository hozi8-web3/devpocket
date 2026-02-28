import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';

class BodyEditor extends StatefulWidget {
  final String body;
  final String bodyType;
  final ValueChanged<String> onBodyChanged;
  final ValueChanged<String> onTypeChanged;

  const BodyEditor({
    super.key,
    required this.body,
    required this.bodyType,
    required this.onBodyChanged,
    required this.onTypeChanged,
  });

  @override
  State<BodyEditor> createState() => _BodyEditorState();
}

class _BodyEditorState extends State<BodyEditor> {
  late final TextEditingController _controller;
  String? _jsonError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.body);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBodyChanged(String val) {
    widget.onBodyChanged(val);
    if (widget.bodyType == 'json') {
      setState(() {
        _jsonError = val.isEmpty || Validators.isValidJson(val) ? null : 'Invalid JSON';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: ['json', 'form', 'raw'].map((t) {
            final sel = widget.bodyType == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t.toUpperCase()),
                selected: sel,
                onSelected: (_) => widget.onTypeChanged(t),
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: AppTextStyles.labelSmall.copyWith(
                  color: sel ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          onChanged: _onBodyChanged,
          maxLines: 8,
          style: AppTextStyles.code,
          decoration: InputDecoration(
            hintText: widget.bodyType == 'json'
                ? '{\n  "key": "value"\n}'
                : 'Request body...',
            errorText: _jsonError,
            alignLabelWithHint: true,
          ),
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
