import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/frosted_glass.dart';
import 'models/runner_models.dart';
import 'providers/runner_provider.dart';
import 'providers/api_tester_provider.dart';

class CollectionRunnerScreen extends ConsumerStatefulWidget {
  final String collectionId;

  const CollectionRunnerScreen({super.key, required this.collectionId});

  @override
  ConsumerState<CollectionRunnerScreen> createState() => _CollectionRunnerScreenState();
}

class _CollectionRunnerScreenState extends ConsumerState<CollectionRunnerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRun();
    });
  }

  void _startRun() {
    final apiState = ref.read(apiTesterProvider);
    final collection = apiState.collections.firstWhere((c) => c.id == widget.collectionId);
    final requests = apiState.savedRequests.where((r) => r.collectionId == widget.collectionId).toList();
    
    ref.read(runnerProvider.notifier).runCollection(collection.name, requests);
  }

  @override
  Widget build(BuildContext context) {
    final runnerState = ref.watch(runnerProvider);
    final summary = runnerState.summary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Collection Runner', style: context.textStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'How to use',
            onPressed: () => context.push('/api-help'),
          ),
          if (runnerState.isRunning)
            TextButton(
              onPressed: () => ref.read(runnerProvider.notifier).cancelRun(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.danger)),
            ),
        ],
      ),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(summary),
                _buildProgressBar(summary),
                Expanded(child: _buildResultsList(summary)),
                if (!runnerState.isRunning) _buildSummaryFooter(summary),
              ],
            ),
    );
  }

  Widget _buildHeader(RunSummary summary) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary.collectionName, style: context.textStyles.heading3),
          const SizedBox(height: 4),
          Text(
            summary.finishedAt == null ? 'Running batch tests...' : 'Run completed',
            style: context.textStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(RunSummary summary) {
    return Container(
      width: double.infinity,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.adaptiveCardBorder,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: summary.progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(RunSummary summary) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: summary.results.length,
      itemBuilder: (context, index) {
        final result = summary.results[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          color: context.adaptiveCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: context.adaptiveCardBorder),
          ),
          child: ListTile(
            dense: true,
            leading: _buildStatusIcon(result.status),
            title: Text(
              result.request.name ?? result.request.url,
              style: context.textStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.status == RunStatus.success
                  ? '${result.response?.statusCode} OK • ${result.duration?.inMilliseconds}ms'
                  : result.status == RunStatus.fail
                      ? (result.error ?? 'Failed with status ${result.response?.statusCode}')
                      : 'Pending',
              style: context.textStyles.caption,
            ),
            trailing: result.status == RunStatus.running
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : null,
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(RunStatus status) {
    switch (status) {
      case RunStatus.success:
        return const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20);
      case RunStatus.fail:
        return const Icon(Icons.error_rounded, color: AppColors.danger, size: 20);
      case RunStatus.running:
        return const Icon(Icons.play_circle_filled_rounded, color: AppColors.primary, size: 20);
      case RunStatus.pending:
        return const Icon(Icons.circle_outlined, color: Colors.grey, size: 20);
    }
  }

  Widget _buildSummaryFooter(RunSummary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.adaptiveCard,
        border: Border(top: BorderSide(color: context.adaptiveCardBorder)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Passed', '${summary.successCount}', AppColors.success),
              _buildMetric('Failed', '${summary.failCount}', AppColors.danger),
              _buildMetric('Avg Time', '${summary.averageResponseTime.inMilliseconds}ms', AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startRun(),
              child: const Text('Run Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: context.textStyles.heading2.copyWith(color: color)),
        Text(label, style: context.textStyles.caption),
      ],
    );
  }
}
