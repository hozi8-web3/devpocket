import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/utils/formatters.dart';
import '../../../core/constants/http_headers.dart' as ref;
import 'services/network_services.dart';

class NetworkToolsScreen extends StatefulWidget {
  const NetworkToolsScreen({super.key});

  @override
  State<NetworkToolsScreen> createState() => _NetworkToolsScreenState();
}

class _NetworkToolsScreenState extends State<NetworkToolsScreen>
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
          tag: 'hero-network-tools',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('Network Tools', style: context.textStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Ping'),
            Tab(text: 'DNS'),
            Tab(text: 'SSL'),
            Tab(text: 'Headers'),
            Tab(text: 'IP Lookup'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PingTab(),
          _DnsTab(),
          _SslTab(),
          _HeadersTab(),
          _IpTab(),
        ],
      ),
    );
  }
}

// --- Ping Tab ---
class _PingTab extends StatefulWidget {
  @override
  State<_PingTab> createState() => _PingTabState();
}

class _PingTabState extends State<_PingTab> {
  final _controller = TextEditingController();
  bool _loading = false;
  PingResult? _result;

  Future<void> _ping() async {
    if (_controller.text.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    final r = await NetworkServices.ping(_controller.text);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HostInput(controller: _controller, hint: 'example.com or 1.2.3.4', onSubmit: _ping, isLoading: _loading),
          const SizedBox(height: 16),
          if (_loading) const _NetworkSkeleton(),
          if (_result != null && !_loading) ...[
            // Stats row
            Row(children: [
              _StatCard('Avg', _result!.avgMs != null ? '${_result!.avgMs}ms' : 'N/A', AppColors.primary),
              const SizedBox(width: 8),
              _StatCard('Min', _result!.minMs != null ? '${_result!.minMs}ms' : 'N/A', AppColors.success),
              const SizedBox(width: 8),
              _StatCard('Max', _result!.maxMs != null ? '${_result!.maxMs}ms' : 'N/A', AppColors.warning),
              const SizedBox(width: 8),
              _StatCard('Loss', AppFormatters.percentage(_result!.packetLoss), AppColors.danger),
            ]),
            const SizedBox(height: 16),
            // Individual pings
            ...List.generate(_result!.responseTimes.length, (i) {
              final t = _result!.responseTimes[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.adaptiveCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t != null ? AppColors.success.withOpacity(0.3) : AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(t != null ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 16, color: t != null ? AppColors.success : AppColors.danger),
                    const SizedBox(width: 10),
                    Text('Ping ${i + 1}', style: context.textStyles.body),
                    const Spacer(),
                    Text(t != null ? '${t}ms' : 'Timeout', style: context.textStyles.code.copyWith(
                      color: t != null ? context.adaptiveTextPrimary : AppColors.danger)),
                  ],
                ),
              );
            }),
            // Bar chart
            if (_result!.responseTimes.any((t) => t != null)) ...[
              const SizedBox(height: 16),
              SectionHeader(title: 'Response Times'),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: BarChart(BarChartData(
                  barGroups: List.generate(_result!.responseTimes.length, (i) {
                    final t = _result!.responseTimes[i];
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: t?.toDouble() ?? 0,
                        color: t != null ? AppColors.primary : AppColors.danger.withOpacity(0.5),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]);
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20,
                      getTitlesWidget: (v, _) => Text('${v.toInt() + 1}', style: context.textStyles.caption))),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                )),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// --- DNS Tab ---
class _DnsTab extends StatefulWidget {
  @override
  State<_DnsTab> createState() => _DnsTabState();
}

class _DnsTabState extends State<_DnsTab> {
  final _controller = TextEditingController();
  bool _loading = false;
  DnsResult? _result;
  final _selectedTypes = {'A': true, 'AAAA': false, 'MX': true, 'TXT': false, 'CNAME': true, 'NS': false};

  Future<void> _lookup() async {
    final types = _selectedTypes.entries.where((e) => e.value).map((e) => e.key).toList();
    setState(() { _loading = true; _result = null; });
    final r = await NetworkServices.dnsLookup(_controller.text, types);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HostInput(controller: _controller, hint: 'example.com', onSubmit: _lookup, isLoading: _loading),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _selectedTypes.keys.map((t) => FilterChip(
              label: Text(t),
              selected: _selectedTypes[t]!,
              onSelected: (v) => setState(() => _selectedTypes[t] = v),
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: context.textStyles.labelSmall.copyWith(
                color: _selectedTypes[t]! ? AppColors.primary : AppColors.textMuted),
            )).toList(),
          ),
          const SizedBox(height: 16),
          if (_loading) const _NetworkSkeleton(),
          if (_result != null && !_loading)
            if (_result!.records.isEmpty)
              const _EmptyState(message: 'No DNS records found')
            else
              ..._result!.records.entries.map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: e.key),
                  const SizedBox(height: 4),
                  ...e.value.map((v) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.adaptiveCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.adaptiveCardBorder),
                    ),
                    child: Text(v, style: context.textStyles.codeSmall),
                  )),
                  const SizedBox(height: 8),
                ],
              )),
        ],
      ),
    );
  }
}

// --- SSL Tab ---
class _SslTab extends StatefulWidget {
  @override
  State<_SslTab> createState() => _SslTabState();
}

class _SslTabState extends State<_SslTab> {
  final _controller = TextEditingController();
  bool _loading = false;
  SslResult? _result;

  Future<void> _check() async {
    setState(() { _loading = true; _result = null; });
    final r = await NetworkServices.checkSsl(_controller.text);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HostInput(controller: _controller, hint: 'example.com', onSubmit: _check, isLoading: _loading),
          const SizedBox(height: 16),
          if (_loading) const _NetworkSkeleton(),
          if (_result != null && !_loading) ...[
            Row(children: [
              if (_result!.isExpired)
                const StatusBadge(label: 'EXPIRED', type: StatusBadgeType.error, showDot: true)
              else if (_result!.isValid)
                const StatusBadge(label: 'VALID', type: StatusBadgeType.success, showDot: true)
              else
                StatusBadge(label: _result!.errorMessage ?? 'INVALID', type: StatusBadgeType.error, showDot: true),
            ]),
            if (_result!.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_result!.errorMessage!, style: context.textStyles.body.copyWith(color: AppColors.textMuted)),
            ] else ...[
              const SizedBox(height: 16),
              if (_result!.daysRemaining != null)
                _InfoTile('Days Remaining', '${_result!.daysRemaining} days'),
              if (_result!.expiryDate != null)
                _InfoTile('Expiry Date', AppFormatters.dateTime(_result!.expiryDate!)),
              if (_result!.issuer != null)
                _InfoTile('Issuer', _result!.issuer!),
              if (_result!.subject != null)
                _InfoTile('Subject', _result!.subject!),
            ],
          ],
        ],
      ),
    );
  }
}

// --- Headers Tab ---
class _HeadersTab extends StatefulWidget {
  @override
  State<_HeadersTab> createState() => _HeadersTabState();
}

class _HeadersTabState extends State<_HeadersTab> {
  final _controller = TextEditingController();
  bool _loading = false;
  HeadersResult? _result;

  Future<void> _fetch() async {
    setState(() { _loading = true; _result = null; });
    final r = await NetworkServices.fetchHeaders(_controller.text);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HostInput(controller: _controller, hint: 'https://example.com', onSubmit: _fetch, isLoading: _loading),
          const SizedBox(height: 16),
          if (_loading) const _NetworkSkeleton(),
          if (_result != null && !_loading) ...[
            if (_result!.error != null)
              _EmptyState(message: _result!.error!)
            else ...[
              Row(children: [
                StatusBadge(
                  label: '${_result!.statusCode} ${_httpPhrase(_result!.statusCode)}',
                  type: StatusBadgeTypeExt.typeForHttpCode(_result!.statusCode),
                  showDot: true,
                ),
              ]),
              const SizedBox(height: 16),
              // Security headers analysis
              SectionHeader(title: 'Security Analysis'),
              const SizedBox(height: 8),
              ...ref.securityHeaders.map((h) {
                final present = _result!.headers.keys.any((k) => k.toLowerCase() == h.toLowerCase());
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (present ? AppColors.success : AppColors.danger).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: (present ? AppColors.success : AppColors.danger).withOpacity(0.25)),
                  ),
                  child: Row(children: [
                    Icon(present ? Icons.check_circle_rounded : Icons.warning_rounded,
                      size: 16, color: present ? AppColors.success : AppColors.danger),
                    const SizedBox(width: 8),
                    Text(h, style: context.textStyles.codeSmall.copyWith(
                      color: present ? context.adaptiveTextPrimary : context.adaptiveTextSecondary)),
                  ]),
                );
              }),
              const SizedBox(height: 16),
              SectionHeader(title: 'All Headers'),
              const SizedBox(height: 8),
              ..._result!.headers.entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.adaptiveCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.adaptiveCardBorder),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 130, child: Text(e.key, style: context.textStyles.codeSmall.copyWith(color: AppColors.syntaxKey))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value, style: context.textStyles.codeSmall)),
                ]),
              )),
            ],
          ],
        ],
      ),
    );
  }

  String _httpPhrase(int code) {
    const phrases = {200: 'OK', 201: 'Created', 204: 'No Content', 301: 'Moved', 302: 'Found',
      400: 'Bad Request', 401: 'Unauthorized', 403: 'Forbidden', 404: 'Not Found', 500: 'Server Error'};
    return phrases[code] ?? '';
  }
}

// --- IP Tab ---
class _IpTab extends StatefulWidget {
  @override
  State<_IpTab> createState() => _IpTabState();
}

class _IpTabState extends State<_IpTab> {
  final _controller = TextEditingController();
  bool _loading = false;
  IpResult? _result;

  Future<void> _lookup() async {
    setState(() { _loading = true; _result = null; });
    final r = await NetworkServices.lookupIp(_controller.text);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HostInput(controller: _controller, hint: '8.8.8.8 (Leave empty for own IP)', onSubmit: _lookup, isLoading: _loading),
          const SizedBox(height: 16),
          if (_loading) const _NetworkSkeleton(),
          if (_result != null && !_loading) ...[
            if (_result!.error != null)
              _EmptyState(message: _result!.error!)
            else ...[
              if (_result!.ip.isNotEmpty) _InfoTile('IP', _result!.ip),
              if (_result!.country != null) _InfoTile('Country', '${_result!.country} (${_result!.countryCode})'),
              if (_result!.region != null) _InfoTile('Region', _result!.region!),
              if (_result!.city != null) _InfoTile('City', _result!.city!),
              if (_result!.isp != null) _InfoTile('ISP', _result!.isp!),
              if (_result!.org != null) _InfoTile('Org', _result!.org!),
              if (_result!.asn != null) _InfoTile('ASN', _result!.asn!),
              if (_result!.timezone != null) _InfoTile('Timezone', _result!.timezone!),
              if (_result!.lat != null && _result!.lon != null)
                _InfoTile('Coordinates', '${_result!.lat?.toStringAsFixed(4)}, ${_result!.lon?.toStringAsFixed(4)}'),
            ],
          ],
        ],
      ),
    );
  }
}

// --- Shared Widgets ---
class _HostInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _HostInput({required this.controller, required this.hint, required this.onSubmit, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: controller,
          onSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(hintText: hint),
          style: context.textStyles.code,
          keyboardType: TextInputType.url,
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        child: isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Go'),
      ),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(label, style: context.textStyles.caption.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textStyles.code.copyWith(
              fontSize: 13,
              color: context.adaptiveTextPrimary,
            ),
          ),
        ]),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.adaptiveCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.adaptiveCardBorder),
        ),
        child: Row(children: [
          SizedBox(width: 100, child: Text(label, style: context.textStyles.caption)),
          Expanded(child: Text(value, style: context.textStyles.body.copyWith(color: context.adaptiveTextPrimary))),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          Text(message, style: context.textStyles.body, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _NetworkSkeleton extends StatelessWidget {
  const _NetworkSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: ShimmerLoader(width: double.infinity, height: 60, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 8),
            Expanded(child: ShimmerLoader(width: double.infinity, height: 60, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 8),
            Expanded(child: ShimmerLoader(width: double.infinity, height: 60, borderRadius: BorderRadius.circular(10))),
          ],
        ),
        const SizedBox(height: 24),
        ShimmerLoader(width: 140, height: 20, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 16),
        ...List.generate(4, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoader(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.circular(10),
          ),
        )),
      ],
    );
  }
}
