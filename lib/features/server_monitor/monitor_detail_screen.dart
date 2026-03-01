import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import 'models/server_entry.dart';
import 'providers/monitor_provider.dart';

class MonitorDetailScreen extends ConsumerWidget {
  final String serverId;
  const MonitorDetailScreen({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monitorProvider);
    final serverMaybe = state.servers.where((s) => s.id == serverId).toList();

    if (serverMaybe.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: Text('Server not found')),
      );
    }
    final server = serverMaybe.first;

    final color = switch (server.status) {
      ServerStatus.up => AppColors.success,
      ServerStatus.down => AppColors.danger,
      ServerStatus.degraded => AppColors.warning,
      ServerStatus.unknown => AppColors.textMuted,
    };

    final history = server.history.reversed.take(30).toList().reversed.toList();
    final responseTimes = history
        .where((r) => r.responseMs != null && r.isUp)
        .map((r) => r.responseMs!.toDouble())
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop()),
        title: Text(server.name, style: context.textStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(monitorProvider.notifier).checkServer(serverId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 8)
                        ]),
                  ),
                  const SizedBox(width: 14),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(server.status.name.toUpperCase(),
                            style: context.textStyles.heading2
                                .copyWith(color: color)),
                        if (server.lastChecked != null)
                          Text(
                              'Checked ${AppFormatters.timeAgo(server.lastChecked!)}',
                              style: context.textStyles.caption),
                      ]),
                  const Spacer(),
                  if (server.lastResponseMs != null)
                    Column(children: [
                      Text(
                        '${server.lastResponseMs}ms',
                        style: context.textStyles.codeBold.copyWith(
                          color: context.adaptiveTextPrimary,
                          fontSize: 22,
                        ),
                      ),
                      Text('Response', style: context.textStyles.caption),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(children: [
              _StatBox('Uptime', '${server.uptimePercent.toStringAsFixed(2)}%',
                  AppColors.success),
              const SizedBox(width: 10),
              _StatBox('Checks', '${server.history.length}', AppColors.primary),
              const SizedBox(width: 10),
              _StatBox('Down', '${server.history.where((r) => !r.isUp).length}',
                  AppColors.danger),
            ]),
            const SizedBox(height: 16),

            // URL
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.adaptiveCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Row(children: [
                Icon(Icons.link_rounded,
                    size: 16, color: context.adaptiveTextSecondary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(server.url,
                        style: context.textStyles.codeSmall,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
            const SizedBox(height: 16),

            // Response time chart
            if (responseTimes.length >= 2) ...[
              Text('Response Times', style: context.textStyles.label),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: LineChart(LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: responseTimes
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (event is FlPanDownEvent ||
                          event is FlPanUpdateEvent ||
                          event is FlTapDownEvent) {
                        HapticFeedback.selectionClick();
                      }
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          context.adaptiveOverlaySurface,
                      tooltipBorder: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.5)),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()}ms\n',
                            context.textStyles.codeBold.copyWith(
                                color: AppColors.primary, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Response',
                                style: context.textStyles.caption.copyWith(
                                    color: context.adaptiveTextSecondary),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (_) => FlLine(
                        color: context.adaptiveGlassBorder, strokeWidth: 0.5),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}ms',
                          style: context.textStyles.caption),
                    )),
                    bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                )),
              ),
              const SizedBox(height: 16),
            ],

            // Uptime bar
            Text('Uptime History (recent 30)', style: context.textStyles.label),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Row(
                spacing: 2,
                children: history
                    .map((r) => Expanded(
                          child: Tooltip(
                            message:
                                '${r.isUp ? "UP" : "DOWN"} — ${AppFormatters.dateTime(r.timestamp)}',
                            child: Container(
                              decoration: BoxDecoration(
                                color: r.isUp
                                    ? AppColors.success
                                    : AppColors.danger,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Recent events
            Text('Recent Events', style: context.textStyles.label),
            const SizedBox(height: 8),
            ...server.history.reversed.take(20).map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: context.adaptiveCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: r.isUp
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.danger.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Icon(
                        r.isUp
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 16,
                        color: r.isUp ? AppColors.success : AppColors.danger),
                    const SizedBox(width: 10),
                    Text(AppFormatters.dateTime(r.timestamp),
                        style: context.textStyles.codeSmall),
                    const Spacer(),
                    if (r.responseMs != null)
                      Text('${r.responseMs}ms',
                          style: context.textStyles.codeSmall
                              .copyWith(color: AppColors.primary)),
                    if (r.statusCode != null) ...[
                      const SizedBox(width: 8),
                      Text('${r.statusCode}',
                          style: context.textStyles.codeSmall
                              .copyWith(color: AppColors.textMuted)),
                    ],
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: context.textStyles.heading2.copyWith(color: color)),
            Text(label, style: context.textStyles.caption),
          ],
        ),
      ),
    );
  }
}
