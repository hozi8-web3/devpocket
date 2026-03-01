import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';
import '../../core/widgets/code_display.dart';
import '../../core/widgets/section_header.dart';
import '../json_tools/services/json_service.dart';

class JsonToolsScreen extends StatefulWidget {
  const JsonToolsScreen({super.key});

  @override
  State<JsonToolsScreen> createState() => _JsonToolsScreenState();
}

class _JsonToolsScreenState extends State<JsonToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _inputController = TextEditingController();
  final _input2Controller = TextEditingController();
  final _jsonPathController = TextEditingController();
  String _output = '';
  String _error = '';
  List<JsonDiffEntry> _diffs = [];
  dynamic _jsonPathResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _input2Controller.dispose();
    _jsonPathController.dispose();
    super.dispose();
  }

  void _process(String type) {
    setState(() {
      _error = '';
      _output = '';
    });
    try {
      switch (type) {
        case 'format':
          setState(() => _output = JsonService.format(_inputController.text));
          break;
        case 'minify':
          setState(() => _output = JsonService.minify(_inputController.text));
          break;
        case 'yaml':
          setState(() => _output = JsonService.toYaml(_inputController.text));
          break;
        case 'validate':
          final r = JsonService.validate(_inputController.text);
          setState(() {
            _output = r.isValid
                ? '✓ Valid JSON'
                : '✗ ${r.error}${r.line != null ? '\nLine ${r.line}, Column ${r.column}' : ''}';
            _error = r.isValid ? '' : _output;
          });
          break;
        case 'diff':
          setState(() => _diffs =
              JsonService.diff(_inputController.text, _input2Controller.text));
          break;
        case 'path':
          final result = JsonService.jsonPathQuery(
              _inputController.text, _jsonPathController.text);
          setState(() => _jsonPathResult = result);
          break;
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  static const _tabs = ['Format', 'Minify', 'Validate', 'Diff', 'JSONPath'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('JSON Tools', style: context.textStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormatTab(),
          _buildMinifyTab(),
          _buildValidateTab(),
          _buildDiffTab(),
          _buildJsonPathTab(),
        ],
      ),
    );
  }

  Widget _buildFormatTab() {
    return _SingleInputTab(
      inputController: _inputController,
      output: _output,
      error: _error,
      actions: [
        _ActionButton(
            label: 'Format',
            icon: Icons.format_align_left_rounded,
            onTap: () => _process('format')),
        _ActionButton(
            label: 'To YAML',
            icon: Icons.transform_rounded,
            onTap: () => _process('yaml')),
      ],
      outputLang: _tabController.index == 0 ? 'json' : 'yaml',
    );
  }

  Widget _buildMinifyTab() {
    return _SingleInputTab(
      inputController: _inputController,
      output: _output,
      error: _error,
      actions: [
        _ActionButton(
            label: 'Minify',
            icon: Icons.compress_rounded,
            onTap: () => _process('minify')),
      ],
    );
  }

  Widget _buildValidateTab() {
    return _SingleInputTab(
      inputController: _inputController,
      output: _output,
      error: _error,
      isValidate: true,
      actions: [
        _ActionButton(
            label: 'Validate',
            icon: Icons.check_circle_outline_rounded,
            onTap: () => _process('validate')),
      ],
    );
  }

  Widget _buildDiffTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            maxLines: 5,
            style: context.textStyles.code,
            decoration: const InputDecoration(
                hintText: 'First JSON...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _input2Controller,
            maxLines: 5,
            style: context.textStyles.code,
            decoration: const InputDecoration(
                hintText: 'Second JSON...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _process('diff');
              },
              child: const Text('Compare'),
            ),
          ),
          const SizedBox(height: 16),
          if (_diffs.isEmpty && _inputController.text.isNotEmpty)
            const Text('No differences found ✓',
                style: TextStyle(color: AppColors.success))
          else
            ..._diffs.map((d) => _DiffRow(entry: d)),
        ],
      ),
    );
  }

  Widget _buildJsonPathTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _inputController,
            maxLines: 6,
            style: context.textStyles.code,
            decoration: const InputDecoration(
                hintText: 'Paste JSON here...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _jsonPathController,
                  style: context.textStyles.code,
                  decoration: const InputDecoration(
                    hintText: r'$.users[0].name',
                    prefixText: r'path: ',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _process('path');
                },
                child: const Text('Query'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_jsonPathResult != null) ...[
            const SectionHeader(title: 'Result'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.codeBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _jsonPathResult.toString(),
                    style: context.textStyles.code,
                  ),
                  const SizedBox(height: 8),
                  CopyButton(text: _jsonPathResult.toString()),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SingleInputTab extends StatelessWidget {
  final TextEditingController inputController;
  final String output;
  final String error;
  final List<Widget> actions;
  final bool isValidate;
  final String outputLang;

  const _SingleInputTab({
    required this.inputController,
    required this.output,
    required this.error,
    required this.actions,
    this.isValidate = false,
    this.outputLang = 'json',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: inputController,
            maxLines: 8,
            style: context.textStyles.code,
            decoration: const InputDecoration(
              hintText: 'Paste JSON here...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
              children: actions
                  .map((a) => Padding(
                      padding: const EdgeInsets.only(right: 8), child: a))
                  .toList()),
          const SizedBox(height: 16),
          if (error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Text(error,
                  style: context.textStyles.codeSmall
                      .copyWith(color: AppColors.danger)),
            )
          else if (output.isNotEmpty)
            isValidate
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Text(output,
                        style: context.textStyles.code
                            .copyWith(color: AppColors.success)),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Output', style: context.textStyles.label),
                          CopyButton(text: output),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CodeDisplay(code: output, language: outputLang),
                    ],
                  ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: context.textStyles.button.copyWith(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _DiffRow extends StatelessWidget {
  final JsonDiffEntry entry;

  const _DiffRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    Color color;
    String prefix;
    switch (entry.type) {
      case DiffType.added:
        color = AppColors.success;
        prefix = '+';
        break;
      case DiffType.removed:
        color = AppColors.danger;
        prefix = '-';
        break;
      case DiffType.changed:
        color = AppColors.warning;
        prefix = '~';
        break;
      default:
        color = context.adaptiveTextSecondary;
        prefix = ' ';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prefix,
              style: context.textStyles.codeBold.copyWith(color: color)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key,
                    style: context.textStyles.codeSmall.copyWith(color: color)),
                if (entry.oldValue != null)
                  Text('- ${entry.oldValue}',
                      style: context.textStyles.codeSmall
                          .copyWith(color: AppColors.danger)),
                Text(
                  '  ${entry.value}',
                  style: context.textStyles.codeSmall.copyWith(
                    color: context.adaptiveTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
