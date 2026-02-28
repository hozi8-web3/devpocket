import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request_model.dart';
import '../models/runner_models.dart';
import '../services/api_service.dart';
import '../utils/variable_resolver.dart';
import 'environment_provider.dart';
import '../../settings/providers/settings_provider.dart';

class RunnerState {
  final RunSummary? summary;
  final bool isRunning;

  const RunnerState({
    this.summary,
    this.isRunning = false,
  });

  RunnerState copyWith({
    RunSummary? summary,
    bool? isRunning,
  }) {
    return RunnerState(
      summary: summary ?? this.summary,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class RunnerNotifier extends StateNotifier<RunnerState> {
  final Ref _ref;

  RunnerNotifier(this._ref) : super(const RunnerState());

  Future<void> runCollection(String name, List<RequestModel> requests) async {
    if (state.isRunning) return;

    final env = _ref.read(environmentProvider).activeEnvironment;
    final variables = env?.variables ?? {};
    final timeout = _ref.read(settingsProvider).requestTimeoutSeconds;

    final results = requests.map((req) => RunnerResult(
      request: req,
      startTime: DateTime.now(),
    )).toList();

    state = RunnerState(
      isRunning: true,
      summary: RunSummary(
        collectionName: name,
        results: results,
        startedAt: DateTime.now(),
      ),
    );

    for (int i = 0; i < requests.length; i++) {
      if (!state.isRunning) break; // User cancelled

      // Update status to running
      _updateResult(i, results[i].copyWith(status: RunStatus.running));

      final req = requests[i];
      
      // Resolve variables
      final resolvedUrl = VariableResolver.resolve(req.url, variables);
      final resolvedHeaders = VariableResolver.resolveMap(req.headers, variables);
      final resolvedBody = VariableResolver.resolve(req.body, variables);
      
      final resolvedReq = req.copyWith(
        url: resolvedUrl,
        headers: resolvedHeaders,
        body: resolvedBody,
      );

      final stopwatch = Stopwatch()..start();
      try {
        final response = await ApiService.sendRequest(resolvedReq, timeoutSeconds: timeout);
        stopwatch.stop();

        _updateResult(i, results[i].copyWith(
          status: response.isError ? RunStatus.fail : RunStatus.success,
          response: response,
          duration: stopwatch.elapsed,
        ));
      } catch (e) {
        stopwatch.stop();
        _updateResult(i, results[i].copyWith(
          status: RunStatus.fail,
          error: e.toString(),
          duration: stopwatch.elapsed,
        ));
      }

      // Small delay between requests to prevent UI freezing and respect server
      await Future.delayed(const Duration(milliseconds: 300));
    }

    state = state.copyWith(
      isRunning: false,
      summary: RunSummary(
        collectionName: name,
        results: state.summary!.results,
        startedAt: state.summary!.startedAt,
        finishedAt: DateTime.now(),
      ),
    );
  }

  void _updateResult(int index, RunnerResult result) {
    if (state.summary == null) return;
    
    final newResults = [...state.summary!.results];
    newResults[index] = result;
    
    state = state.copyWith(
      summary: RunSummary(
        collectionName: state.summary!.collectionName,
        results: newResults,
        startedAt: state.summary!.startedAt,
        finishedAt: state.summary!.finishedAt,
      ),
    );
  }

  void cancelRun() {
    state = state.copyWith(isRunning: false);
  }
}

final runnerProvider = StateNotifierProvider<RunnerNotifier, RunnerState>((ref) {
  return RunnerNotifier(ref);
});
