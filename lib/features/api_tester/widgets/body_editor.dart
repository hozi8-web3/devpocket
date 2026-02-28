import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

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

  Future<void> _importPayload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        // Check if it's valid JSON if type is json
        if (widget.bodyType == 'json') {
          try {
            jsonDecode(content);
            _jsonError = null;
          } catch (_) {
            _jsonError = 'Imported file is not valid JSON';
          }
        }
        
        _controller.text = content;
        widget.onBodyChanged(content);
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import payload: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            ...['json', 'form', 'raw'].map((t) {
              final sel = widget.bodyType == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t.toUpperCase()),
                  selected: sel,
                  onSelected: (_) => widget.onTypeChanged(t),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: context.textStyles.labelSmall.copyWith(
                    color: sel ? AppColors.primary : context.adaptiveTextSecondary,
                  ),
                ),
              );
            }),
            const Spacer(),
            IconButton(
              onPressed: _importPayload,
              icon: const Icon(Icons.file_upload_outlined, size: 20),
              tooltip: 'Import Payload File',
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          onChanged: _onBodyChanged,
          maxLines: 8,
          style: context.textStyles.code,
          decoration: InputDecoration(
            hintText: widget.bodyType == 'json'
                ? '{\n  "key": "value"\n}'
                : 'Request body...',
            hintStyle: context.textStyles.code.copyWith(
              color: context.adaptiveTextSecondary,
            ),
            errorText: _jsonError,
            alignLabelWithHint: true,
          ),
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
