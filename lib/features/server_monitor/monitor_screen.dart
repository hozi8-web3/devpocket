import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glowing_empty_state.dart';
import 'models/server_entry.dart';
import 'services/monitor_service.dart';
import 'providers/monitor_provider.dart';

class MonitorScreen extends ConsumerStatefulWidget {
  const MonitorScreen({super.key});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(monitorProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monitorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'hero-monitor',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('Server Monitor', style: AppTextStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(monitorProvider.notifier).checkAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Server'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.servers.isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(monitorProvider.notifier).checkAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: state.servers.length,
                    itemBuilder: (_, i) => _ServerCard(
                      server: state.servers[i],
                      onCheck: () => ref.read(monitorProvider.notifier).checkServer(state.servers[i].id),
                      onDelete: () => ref.read(monitorProvider.notifier).delete(state.servers[i].id),
                      onTap: () => context.push('/monitor/${state.servers[i].id}'),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GlowingEmptyState(
            icon: Icons.monitor_heart_outlined,
            title: 'No servers monitored',
            subtitle: 'Add a server to start tracking uptime and latency.',
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Server'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    int interval = 5;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Add Server'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', hintText: 'My API Server')),
              const SizedBox(height: 8),
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL', hintText: 'https://api.example.com/health')),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Check every:', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Expanded(child: Slider(
                  value: interval.toDouble(), min: 1, max: 60, divisions: 59,
                  label: '${interval}m',
                  onChanged: (v) => setSt(() => interval = v.round()),
                )),
                Text('${interval}m', style: AppTextStyles.code),
              ]),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                  ref.read(monitorProvider.notifier).add(
                    name: nameCtrl.text,
                    url: urlCtrl.text,
                    intervalMinutes: interval,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatelessWidget {
  final ServerEntry server;
  final VoidCallback onCheck;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ServerCard({
    required this.server,
    required this.onCheck,
    required this.onDelete,
    required this.onTap,
  });

  Color get statusColor {
    return switch (server.status) {
      ServerStatus.up => AppColors.success,
      ServerStatus.down => AppColors.danger,
      ServerStatus.degraded => AppColors.warning,
      ServerStatus.unknown => AppColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.adaptiveCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(server.name, style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
              IconButton(icon: const Icon(Icons.refresh_rounded, size: 18), onPressed: onCheck,
                color: AppColors.textMuted, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 18), onPressed: onDelete,
                color: AppColors.danger.withOpacity(0.7), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]),
            const SizedBox(height: 6),
            Text(server.url, style: AppTextStyles.codeSmall.copyWith(color: AppColors.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(children: [
              _InfoChip(label: 'Uptime', value: '${server.uptimePercent.toStringAsFixed(1)}%', color: AppColors.success),
              const SizedBox(width: 8),
              if (server.lastResponseMs != null)
                _InfoChip(label: 'Ping', value: '${server.lastResponseMs}ms', color: AppColors.primary),
              const SizedBox(width: 8),
              if (server.lastChecked != null)
                _InfoChip(label: 'Last', value: AppFormatters.timeAgo(server.lastChecked!), color: AppColors.textMuted),
            ]),
            if (server.history.isNotEmpty) ...[
              const SizedBox(height: 12),
              _UptimeBars(history: server.history.take(40).toList()),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(text: '$label: ', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          TextSpan(text: value, style: AppTextStyles.codeSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _UptimeBars extends StatelessWidget {
  final List<UptimeRecord> history;

  const _UptimeBars({required this.history});

  @override
  Widget build(BuildContext context) {
    final reversed = history.reversed.toList();
    return SizedBox(
      height: 16,
      child: Row(
        spacing: 2,
        children: reversed.map((r) => Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: r.isUp ? AppColors.success : AppColors.danger,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )).toList(),
      ),
    );
  }
}
