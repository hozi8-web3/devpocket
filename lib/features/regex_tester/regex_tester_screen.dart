import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';
import '../../core/constants/regex_patterns.dart';

class RegexTesterScreen extends StatefulWidget {
  const RegexTesterScreen({super.key});

  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends State<RegexTesterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _patternController = TextEditingController();
  final _testController = TextEditingController();

  bool _caseInsensitive = false;
  bool _multiLine = false;
  bool _dotAll = false;

  List<RegExpMatch> _matches = [];
  String? _error;

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patternController.dispose();
    _testController.dispose();
    super.dispose();
  }

  void _test() {
    if (_patternController.text.isEmpty) {
      setState(() { _matches = []; _error = null; });
      return;
    }
    try {
      final re = RegExp(
        _patternController.text,
        caseSensitive: !_caseInsensitive,
        multiLine: _multiLine,
        dotAll: _dotAll,
      );
      setState(() {
        _matches = re.allMatches(_testController.text).toList();
        _error = null;
      });
    } on FormatException catch (e) {
      setState(() { _matches = []; _error = e.message; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            leading: Hero(
              tag: 'hero-regex',
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Regex Tester', style: context.textStyles.heading2),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0, -0.2),
                  child: Icon(Icons.rule_folder_rounded, size: 60, color: AppColors.primary.withOpacity(0.5)),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Tester'), Tab(text: 'Library')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_buildTesterTab(), _buildLibraryTab()],
        ),
      ),
    );
  }

  Widget _buildTesterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pattern input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _patternController,
                  onChanged: (_) => _test(),
                  style: context.textStyles.code.copyWith(color: AppColors.secondary),
                  decoration: const InputDecoration(
                    prefixText: '/',
                    suffixText: '/gi',
                    prefixStyle: TextStyle(color: AppColors.textMuted),
                    suffixStyle: TextStyle(color: AppColors.textMuted),
                    hintText: 'regex pattern...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CopyButton(text: _patternController.text),
            ],
          ),
          const SizedBox(height: 8),

          // Flags
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('i — Case insensitive'),
                selected: _caseInsensitive,
                onSelected: (v) { setState(() => _caseInsensitive = v); _test(); },
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: context.textStyles.labelSmall.copyWith(
                  color: _caseInsensitive ? AppColors.primary : AppColors.textMuted),
              ),
              FilterChip(
                label: const Text('m — Multiline'),
                selected: _multiLine,
                onSelected: (v) { setState(() => _multiLine = v); _test(); },
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: context.textStyles.labelSmall.copyWith(
                  color: _multiLine ? AppColors.primary : AppColors.textMuted),
              ),
              FilterChip(
                label: const Text('s — Dot all'),
                selected: _dotAll,
                onSelected: (v) { setState(() => _dotAll = v); _test(); },
                selectedColor: AppColors.primary.withOpacity(0.2),
                labelStyle: context.textStyles.labelSmall.copyWith(
                  color: _dotAll ? AppColors.primary : AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Test input
          Stack(
            children: [
              TextField(
                controller: _testController,
                maxLines: 6,
                onChanged: (_) => _test(),
                style: context.textStyles.code,
                decoration: const InputDecoration(
                  hintText: 'Test string here...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Error
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Error: $_error',
                  style: context.textStyles.codeSmall.copyWith(color: AppColors.danger)),
            ),

          // Match stats
          if (_patternController.text.isNotEmpty && _error == null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _matches.isNotEmpty
                    ? AppColors.success.withOpacity(0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _matches.isNotEmpty
                        ? AppColors.success.withOpacity(0.3)
                        : context.adaptiveCardBorder),
              ),
              child: Row(children: [
                Icon(_matches.isNotEmpty ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded,
                    size: 16, color: _matches.isNotEmpty ? AppColors.success : AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  _matches.isEmpty
                      ? 'No matches found'
                      : '${_matches.length} match${_matches.length == 1 ? '' : 'es'} found',
                  style: context.textStyles.body.copyWith(
                    color: _matches.isNotEmpty ? AppColors.success : AppColors.textMuted),
                ),
              ]),
            ),
            const SizedBox(height: 16),
          ],

          // Matches list
          if (_matches.isNotEmpty) ...[
            Text('Matches', style: context.textStyles.label),
            const SizedBox(height: 8),
            ..._matches.asMap().entries.map((e) {
              final i = e.key;
              final match = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.adaptiveCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('${i + 1}', style: context.textStyles.labelSmall.copyWith(color: AppColors.primary)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText('"${match.group(0)}"',
                            style: context.textStyles.code.copyWith(color: AppColors.secondary)),
                        Text('Position: ${match.start}–${match.end}',
                            style: context.textStyles.caption),
                        if (match.groupCount > 0) ...[
                          ...List.generate(match.groupCount, (gi) => Text(
                            'Group ${gi + 1}: "${match.group(gi + 1)}"',
                            style: context.textStyles.codeSmall.copyWith(color: AppColors.textMuted),
                          )),
                        ],
                      ],
                    ),
                  ),
                  CopyButton(text: match.group(0) ?? '', compact: true),
                ]),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    final categories = ['All', ...builtInRegexPatterns.map((p) => p.category).toSet()];
    final filtered = _selectedCategory == 'All'
        ? builtInRegexPatterns
        : builtInRegexPatterns.where((p) => p.category == _selectedCategory).toList();

    return Column(
      children: [
        // Category filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((cat) {
                final sel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: context.textStyles.labelSmall.copyWith(
                        color: sel ? AppColors.primary : AppColors.textMuted),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final pattern = filtered[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.adaptiveCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.adaptiveCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(pattern.name,
                            style: context.textStyles.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(pattern.category, style: context.textStyles.labelSmall.copyWith(color: AppColors.primary)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(pattern.description, style: context.textStyles.caption),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: Text(pattern.pattern,
                            style: context.textStyles.codeSmall.copyWith(color: AppColors.secondary),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      CopyButton(text: pattern.pattern, compact: true),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(pattern.example, style: context.textStyles.codeSmall.copyWith(color: AppColors.textMuted)),
                    ]),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        _patternController.text = pattern.pattern;
                        _tabController.animateTo(0);
                        _test();
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: const Text('Use in Tester'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
