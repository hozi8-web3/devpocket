import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';
import '../../core/widgets/section_header.dart';
import 'services/generator_service.dart';

class GeneratorsScreen extends StatefulWidget {
  const GeneratorsScreen({super.key});

  @override
  State<GeneratorsScreen> createState() => _GeneratorsScreenState();
}

class _GeneratorsScreenState extends State<GeneratorsScreen>
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
          tag: 'hero-generators',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('Generators', style: context.textStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'UUID'),
            Tab(text: 'Password'),
            Tab(text: 'Hash'),
            Tab(text: 'HMAC'),
            Tab(text: 'Random'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UuidTab(),
          _PasswordTab(),
          _HashTab(),
          _HmacTab(),
          _RandomStringTab(),
        ],
      ),
    );
  }
}

// --- UUID Tab ---
class _UuidTab extends StatefulWidget {
  @override
  State<_UuidTab> createState() => _UuidTabState();
}

class _UuidTabState extends State<_UuidTab> {
  List<String> _uuids = [GeneratorService.generateUuid()];
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Count:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _count.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: _count.toString(),
                  onChanged: (v) => setState(() => _count = v.round()),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(_count.toString(), style: context.textStyles.code, textAlign: TextAlign.right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => _uuids = GeneratorService.generateUuids(_count)),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Generate'),
              ),
              const SizedBox(width: 8),
              if (_uuids.length > 1)
                CopyButton(text: _uuids.join('\n'), label: 'Copy All'),
            ],
          ),
          const SizedBox(height: 16),
          ..._uuids.map((uuid) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.adaptiveCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.adaptiveCardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(uuid, style: context.textStyles.code),
                ),
                CopyButton(text: uuid, compact: true),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// --- Password Tab ---
class _PasswordTab extends StatefulWidget {
  @override
  State<_PasswordTab> createState() => _PasswordTabState();
}

class _PasswordTabState extends State<_PasswordTab> {
  int _length = 16;
  bool _upper = true, _lower = true, _digits = true, _symbols = true, _noAmbig = false;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _password = GeneratorService.generatePassword(
        length: _length,
        useUpper: _upper,
        useLower: _lower,
        useDigits: _digits,
        useSymbols: _symbols,
        excludeAmbiguous: _noAmbig,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strength = _password.isEmpty ? PasswordStrength.weak : GeneratorService.getStrength(_password);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_password.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.codeBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(_password, style: context.textStyles.code),
                      ),
                      CopyButton(text: _password, compact: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _StrengthBar(strength: strength),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(children: [
            const Text('Length:', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(value: _length.toDouble(), min: 8, max: 64, divisions: 56,
                label: _length.toString(), onChanged: (v) { setState(() => _length = v.round()); _generate(); }),
            ),
            Text('$_length', style: context.textStyles.code),
          ]),
          _Toggle('Uppercase (A-Z)', _upper, (v) { setState(() => _upper = v); _generate(); }),
          _Toggle('Lowercase (a-z)', _lower, (v) { setState(() => _lower = v); _generate(); }),
          _Toggle('Digits (0-9)', _digits, (v) { setState(() => _digits = v); _generate(); }),
          _Toggle(r'Symbols (!@#$...)', _symbols, (v) { setState(() => _symbols = v); _generate(); }),
          _Toggle('Exclude ambiguous (0, O, l, I)', _noAmbig, (v) { setState(() => _noAmbig = v); _generate(); }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final PasswordStrength strength;
  const _StrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final (label, color, count) = switch (strength) {
      PasswordStrength.weak => ('Weak', AppColors.danger, 1),
      PasswordStrength.fair => ('Fair', AppColors.warning, 2),
      PasswordStrength.strong => ('Strong', AppColors.success, 3),
      PasswordStrength.veryStrong => ('Very Strong', AppColors.secondary, 4),
    };
    return Row(
      children: [
        ...List.generate(4, (i) => Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: i < count ? color : AppColors.surface,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
        const SizedBox(width: 8),
        Text(label, style: context.textStyles.caption.copyWith(color: color)),
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) => SwitchListTile(
    title: Text(label, style: context.textStyles.body),
    value: value,
    onChanged: onChanged,
    contentPadding: EdgeInsets.zero,
  );
}

// --- Hash Tab ---
class _HashTab extends StatefulWidget {
  @override
  State<_HashTab> createState() => _HashTabState();
}

class _HashTabState extends State<_HashTab> {
  final _controller = TextEditingController();
  HashAlgorithm _algo = HashAlgorithm.sha256;
  bool _uppercase = false;
  String _result = '';

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _compute() {
    if (_controller.text.isEmpty) { setState(() => _result = ''); return; }
    setState(() => _result = GeneratorService.hash(_controller.text, _algo, uppercase: _uppercase));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            onChanged: (_) => _compute(),
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Input text to hash...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: HashAlgorithm.values.map((a) => ChoiceChip(
              label: Text(a.name.toUpperCase()),
              selected: _algo == a,
              onSelected: (_) { setState(() => _algo = a); _compute(); },
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: context.textStyles.labelSmall.copyWith(
                color: _algo == a ? AppColors.primary : AppColors.textMuted),
            )).toList(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Uppercase output', style: context.textStyles.body),
            value: _uppercase,
            onChanged: (v) { setState(() => _uppercase = v); _compute(); },
            contentPadding: EdgeInsets.zero,
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ResultCard(label: _algo.name.toUpperCase(), value: _result),
          ],
        ],
      ),
    );
  }
}

// --- HMAC Tab ---
class _HmacTab extends StatefulWidget {
  @override
  State<_HmacTab> createState() => _HmacTabState();
}

class _HmacTabState extends State<_HmacTab> {
  final _msgController = TextEditingController();
  final _keyController = TextEditingController();
  HashAlgorithm _algo = HashAlgorithm.sha256;
  String _result = '';

  @override
  void dispose() { _msgController.dispose(); _keyController.dispose(); super.dispose(); }

  void _compute() {
    if (_msgController.text.isEmpty || _keyController.text.isEmpty) return;
    setState(() => _result = GeneratorService.hmac(_msgController.text, _keyController.text, _algo));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: _msgController, onChanged: (_) => _compute(),
            maxLines: 3, decoration: const InputDecoration(hintText: 'Message...', alignLabelWithHint: true)),
          const SizedBox(height: 12),
          TextField(controller: _keyController, onChanged: (_) => _compute(),
            decoration: const InputDecoration(hintText: 'Secret key...')),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: HashAlgorithm.values.map((a) => ChoiceChip(
            label: Text(a.name.toUpperCase()), selected: _algo == a,
            onSelected: (_) { setState(() => _algo = a); _compute(); },
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: context.textStyles.labelSmall.copyWith(
              color: _algo == a ? AppColors.primary : AppColors.textMuted),
          )).toList()),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ResultCard(label: 'HMAC-${_algo.name.toUpperCase()}', value: _result),
          ],
        ],
      ),
    );
  }
}

// --- Random String Tab ---
class _RandomStringTab extends StatefulWidget {
  @override
  State<_RandomStringTab> createState() => _RandomStringTabState();
}

class _RandomStringTabState extends State<_RandomStringTab> {
  int _length = 32;
  String _charset = 'alphanumeric';
  final _customController = TextEditingController(text: 'abc123');
  List<String> _results = [];
  int _count = 1;

  void _generate() {
    setState(() {
      _results = List.generate(_count, (_) => GeneratorService.randomString(
        _length, _charset, _customController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Length:', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Expanded(child: Slider(value: _length.toDouble(), min: 4, max: 128, divisions: 124,
              label: _length.toString(), onChanged: (v) => setState(() => _length = v.round()))),
            Text('$_length', style: context.textStyles.code),
          ]),
          Wrap(spacing: 8, children: ['alphanumeric', 'alpha', 'numeric', 'hex', 'custom'].map((c) =>
            ChoiceChip(label: Text(c), selected: _charset == c,
              onSelected: (_) => setState(() => _charset = c),
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: context.textStyles.labelSmall.copyWith(
                color: _charset == c ? AppColors.primary : AppColors.textMuted),
            )).toList()),
          if (_charset == 'custom') ...[
            const SizedBox(height: 8),
            TextField(controller: _customController, decoration: const InputDecoration(hintText: 'Custom charset...')),
          ],
          const SizedBox(height: 12),
          Row(children: [
            const Text('Count:', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Expanded(child: Slider(value: _count.toDouble(), min: 1, max: 10, divisions: 9,
              label: _count.toString(), onChanged: (v) => setState(() => _count = v.round()))),
            Text('$_count', style: context.textStyles.code),
          ]),
          ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Generate'),
          ),
          const SizedBox(height: 16),
          ..._results.map((r) => _ResultCard(label: '', value: r)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  const _ResultCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.adaptiveCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: context.textStyles.caption.copyWith(color: AppColors.primary)),
          ),
          Row(
            children: [
              Expanded(child: SelectableText(value, style: context.textStyles.codeSmall)),
              CopyButton(text: value, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}
