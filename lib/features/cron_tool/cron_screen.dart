import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';

class CronScreen extends StatefulWidget {
  const CronScreen({super.key});

  @override
  State<CronScreen> createState() => _CronScreenState();
}

class _CronScreenState extends State<CronScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          tag: 'hero-cron',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('Cron Parser', style: context.textStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Parser'), Tab(text: 'Builder')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_CronParserTab(), _CronBuilderTab()],
      ),
    );
  }
}

class _CronParserTab extends StatefulWidget {
  @override
  State<_CronParserTab> createState() => _CronParserTabState();
}

class _CronParserTabState extends State<_CronParserTab> {
  final _controller = TextEditingController(text: '0 9 * * 1-5');
  String _description = '';
  List<DateTime> _nextRuns = [];
  String? _error;

  static const _presets = [
    ('Every minute', '* * * * *'),
    ('Every 5 minutes', '*/5 * * * *'),
    ('Every hour', '0 * * * *'),
    ('Every day at midnight', '0 0 * * *'),
    ('Every day at 9am', '0 9 * * *'),
    ('Every Monday 9am', '0 9 * * 1'),
    ('Weekdays at 9am', '0 9 * * 1-5'),
    ('1st of month', '0 0 1 * *'),
    ('Every Sunday 12pm', '0 12 * * 0'),
    ('Every 15 minutes', '*/15 * * * *'),
    ('Twice a day (noon & midnight)', '0 0,12 * * *'),
    ('Every quarter', '0 0 1 */3 *'),
  ];

  @override
  void initState() {
    super.initState();
    _parse(_controller.text);
  }

  void _parse(String expr) {
    setState(() => _error = null);
    try {
      final parts = expr.trim().split(RegExp(r'\s+'));
      if (parts.length != 5) {
        setState(() {
          _error = 'Cron must have 5 fields: minute hour day-of-month month day-of-week';
          _description = '';
          _nextRuns = [];
        });
        return;
      }

      final desc = _describe(parts);
      final runs = _nextExecutions(parts, count: 5);
      setState(() {
        _description = desc;
        _nextRuns = runs;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _description = ''; _nextRuns = []; });
    }
  }

  String _describe(List<String> parts) {
    final minute = parts[0];
    final hour = parts[1];
    final dom = parts[2];
    final month = parts[3];
    final dow = parts[4];

    final minutes = <String>[];
    if (minute == '*') minutes.add('every minute');
    else if (minute.startsWith('*/')) minutes.add('every ${minute.substring(2)} minutes');
    else minutes.add('at minute${minute.contains(',') ? 's' : ''} $minute');

    final hours = <String>[];
    if (hour == '*') hours.add('every hour');
    else if (hour.startsWith('*/')) hours.add('every ${hour.substring(2)} hours');
    else {
      final hParts = hour.split(',').map((h) {
        final n = int.tryParse(h) ?? 0;
        return n == 0 ? 'midnight' : n == 12 ? 'noon' : '$n:00';
      });
      hours.add('at ${hParts.join(' and ')}');
    }

    final days = <String>[];
    if (dow != '*') {
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      if (dow.contains('-')) {
        final range = dow.split('-');
        final start = int.tryParse(range[0]) ?? 0;
        final end = int.tryParse(range[1]) ?? 6;
        days.add('on ${dayNames[start]} through ${dayNames[end]}');
      } else if (dow.contains(',')) {
        final nums = dow.split(',').map((d) => dayNames[int.tryParse(d) ?? 0]);
        days.add('on ${nums.join(', ')}');
      } else {
        final n = int.tryParse(dow) ?? 0;
        days.add('on ${dayNames[n]}');
      }
    }
    if (dom != '*' && dow == '*') {
      days.add('on day $dom of the month');
    }
    if (month != '*') {
      const monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'];
      days.add('in ${monthNames[int.tryParse(month) ?? 1]}');
    }

    return [
      '${hours.join(' ')}, ${minutes.join()}',
      ...days,
    ].join(' ');
  }

  List<DateTime> _nextExecutions(List<String> parts, {int count = 5}) {
    final results = <DateTime>[];
    final minute = parts[0];
    final hour = parts[1];
    final dom = parts[2];
    final month = parts[3];
    final dow = parts[4];

    var dt = DateTime.now().add(const Duration(minutes: 1));
    dt = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);

    for (int attempts = 0; attempts < 50000 && results.length < count; attempts++) {
      if (_matchesCron(dt, minute, hour, dom, month, dow)) {
        results.add(dt);
        dt = dt.add(const Duration(minutes: 1));
      } else {
        dt = dt.add(const Duration(minutes: 1));
      }
    }
    return results;
  }

  bool _matchesCron(DateTime dt, String minute, String hour, String dom, String month, String dow) {
    return _matchField(dt.minute, minute, 0, 59) &&
        _matchField(dt.hour, hour, 0, 23) &&
        _matchField(dt.day, dom, 1, 31) &&
        _matchField(dt.month, month, 1, 12) &&
        _matchField(dt.weekday % 7, dow, 0, 6);
  }

  bool _matchField(int value, String field, int min, int max) {
    if (field == '*') return true;
    if (field.startsWith('*/')) {
      final step = int.tryParse(field.substring(2)) ?? 1;
      return value % step == 0;
    }
    if (field.contains('-')) {
      final parts = field.split('-');
      final start = int.tryParse(parts[0]) ?? min;
      final end = int.tryParse(parts[1]) ?? max;
      return value >= start && value <= end;
    }
    if (field.contains(',')) {
      return field.split(',').any((f) => _matchField(value, f.trim(), min, max));
    }
    return value == (int.tryParse(field) ?? -1);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expression input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.codeBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary, width: 1.5),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 12)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CRON EXPRESSION', style: context.textStyles.caption.copyWith(color: AppColors.primary, letterSpacing: 1)),
                    CopyButton(text: _controller.text),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  onChanged: _parse,
                  style: context.textStyles.codeMedium.copyWith(color: AppColors.secondary, fontSize: 22, letterSpacing: 6),
                  decoration: const InputDecoration(border: InputBorder.none, filled: false),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MIN', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text('HOUR', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text('DAY', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text('MONTH', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    Text('DOW', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    SizedBox(width: 0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_error!, style: context.textStyles.body.copyWith(color: AppColors.danger)),
            )
          else if (_description.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.adaptiveCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Row(children: [
                const Icon(Icons.translate_rounded, size: 18, color: AppColors.secondary),
                const SizedBox(width: 10),
                Expanded(child: Text(_description, style: context.textStyles.body)),
              ]),
            ),

          const SizedBox(height: 16),

          // Next runs
          if (_nextRuns.isNotEmpty) ...[
            Text('Next ${_nextRuns.length} Executions', style: context.textStyles.label),
            const SizedBox(height: 8),
            ..._nextRuns.map((dt) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.adaptiveCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Row(children: [
                const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(_formatDateTime(dt), style: context.textStyles.code),
              ]),
            )),
          ],

          const SizedBox(height: 24),

          // Presets
          Text('Common Presets', style: context.textStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) => OutlinedButton(
              onPressed: () {
                _controller.text = p.$2;
                _parse(p.$2);
              },
              child: Text(p.$1, style: context.textStyles.codeSmall),
            )).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} ${dt.year} — ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _CronBuilderTab extends StatefulWidget {
  @override
  State<_CronBuilderTab> createState() => _CronBuilderTabState();
}

class _CronBuilderTabState extends State<_CronBuilderTab> {
  String _minute = '0';
  String _hour = '9';
  String _dom = '*';
  String _month = '*';
  String _dow = '*';

  String get _expression => '$_minute $_hour $_dom $_month $_dow';

  Widget _fieldGroup(String label, String value, String hint, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.caption),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value),
          onChanged: onChanged,
          style: context.textStyles.code,
          decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(10)),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldGroup('Minute (0–59)', _minute, '0, */5, 0-30', (v) => setState(() => _minute = v)),
          _fieldGroup('Hour (0–23)', _hour, '0, 9, */2, 8-17', (v) => setState(() => _hour = v)),
          _fieldGroup('Day of Month (1–31)', _dom, '*, 1, 15, 1-15', (v) => setState(() => _dom = v)),
          _fieldGroup('Month (1–12)', _month, '*, 1, */3, 1-6', (v) => setState(() => _month = v)),
          _fieldGroup('Day of Week (0=Sun, 6=Sat)', _dow, '*, 0, 1-5, 1,3,5', (v) => setState(() => _dow = v)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.codeBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(children: [
              Expanded(
                child: Text(_expression, style: context.textStyles.codeMedium.copyWith(
                  color: AppColors.secondary, letterSpacing: 4)),
              ),
              CopyButton(text: _expression),
            ]),
          ),
        ],
      ),
    );
  }
}
