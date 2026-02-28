import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';
import '../../core/widgets/section_header.dart';

class EncodersScreen extends StatefulWidget {
  const EncodersScreen({super.key});

  @override
  State<EncodersScreen> createState() => _EncodersScreenState();
}

class _EncodersScreenState extends State<EncodersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'hero-encoders',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('Encoders & Decoders', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Base64'),
            Tab(text: 'URL'),
            Tab(text: 'HTML'),
            Tab(text: 'Hex'),
            Tab(text: 'Unicode'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EncoderTab(
            label: 'Base64',
            encode: (s) => base64Encode(utf8.encode(s)),
            decode: (s) {
              try {
                final padded = s.padRight((s.length + 3) ~/ 4 * 4, '=');
                return utf8.decode(base64Decode(padded));
              } catch (_) { return null; }
            },
          ),
          _EncoderTab(
            label: 'URL',
            encode: Uri.encodeComponent,
            decode: (s) { try { return Uri.decodeComponent(s); } catch (_) { return null; } },
          ),
          _EncoderTab(
            label: 'HTML',
            encode: (s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;')
                .replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;'),
            decode: (s) => s.replaceAll('&amp;', '&').replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('&#39;', "'"),
          ),
          _EncoderTab(
            label: 'Hex',
            encode: (s) => utf8.encode(s).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '),
            decode: (s) {
              try {
                final bytes = s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty)
                    .map((h) => int.parse(h, radix: 16)).toList();
                return utf8.decode(bytes);
              } catch (_) { return null; }
            },
          ),
          _EncoderTab(
            label: 'Unicode',
            encode: (s) => s.runes.map((r) => '\\u${r.toRadixString(16).padLeft(4, '0')}').join(),
            decode: (s) {
              try {
                return s.replaceAllMapped(
                  RegExp(r'\\u([0-9a-fA-F]{4})'),
                  (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
                );
              } catch (_) { return null; }
            },
          ),
        ],
      ),
    );
  }
}

class _EncoderTab extends StatefulWidget {
  final String label;
  final String Function(String) encode;
  final String? Function(String) decode;

  const _EncoderTab({
    required this.label,
    required this.encode,
    required this.decode,
  });

  @override
  State<_EncoderTab> createState() => _EncoderTabState();
}

class _EncoderTabState extends State<_EncoderTab> {
  final _inputController = TextEditingController();
  String _output = '';
  String? _error;
  bool _isEncoding = true;

  void _process() {
    setState(() { _error = null; });
    if (_inputController.text.isEmpty) {
      setState(() => _output = '');
      return;
    }
    if (_isEncoding) {
      try {
        setState(() => _output = widget.encode(_inputController.text));
      } catch (e) {
        setState(() { _error = e.toString(); _output = ''; });
      }
    } else {
      final result = widget.decode(_inputController.text);
      if (result == null) {
        setState(() { _error = 'Invalid ${widget.label} input'; _output = ''; });
      } else {
        setState(() => _output = result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode toggle
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: context.adaptiveCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.adaptiveCardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() => _isEncoding = true); _process(); },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isEncoding ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Text('Encode', style: AppTextStyles.button.copyWith(
                        color: _isEncoding ? Colors.white : AppColors.textMuted,
                        fontSize: 13,
                      )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () { setState(() => _isEncoding = false); _process(); },
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_isEncoding ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Text('Decode', style: AppTextStyles.button.copyWith(
                        color: !_isEncoding ? Colors.white : AppColors.textMuted,
                        fontSize: 13,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Input
          TextField(
            controller: _inputController,
            maxLines: 5,
            style: AppTextStyles.code,
            onChanged: (_) => _process(),
            decoration: InputDecoration(
              hintText: _isEncoding ? 'Input text to encode...' : 'Input ${widget.label} to decode...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          // Output
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.danger)),
            )
          else if (_output.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.codeBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_isEncoding ? 'Encoded' : 'Decoded', style: AppTextStyles.label),
                      CopyButton(text: _output),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(_output, style: AppTextStyles.codeSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
