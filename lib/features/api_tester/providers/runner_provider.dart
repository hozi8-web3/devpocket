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
  // Persisted so navigating away doesn't lose results
  final String? lastCollectionName;
  final List<RequestModel> lastRequests;

  const RunnerState({
    this.summary,
    this.isRunning = false,
    this.lastCollectionName,
    this.lastRequests = const [],
  });

  RunnerState copyWith({
    RunSummary? summary,
    bool? isRunning,
    String? lastCollectionName,
    List<RequestModel>? lastRequests,
  }) {
    return RunnerState(
      summary: summary ?? this.summary,
      isRunning: isRunning ?? this.isRunning,
      lastCollectionName: lastCollectionName ?? this.lastCollectionName,
      lastRequests: lastRequests ?? this.lastRequests,
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
      lastCollectionName: name,
      lastRequests: requests,
      summary: RunSummary(
        collectionName: name,
        results: state.summary!.results,
        startedAt: state.summary!.startedAt,
        finishedAt: DateTime.now(),
      ),
    );
  }

  /// Re-run a single request (e.g. a failed one) in place.
  Future<void> runSingle(int index) async {
    if (state.summary == null || state.isRunning) return;

    final env = _ref.read(environmentProvider).activeEnvironment;
    final variables = env?.variables ?? {};
    final timeout = _ref.read(settingsProvider).requestTimeoutSeconds;
    final req = state.summary!.results[index].request;

    _updateResult(index, state.summary!.results[index].copyWith(status: RunStatus.running));
    state = state.copyWith(isRunning: true);

    final resolvedUrl = VariableResolver.resolve(req.url, variables);
    final resolvedHeaders = VariableResolver.resolveMap(req.headers, variables);
    final resolvedBody = VariableResolver.resolve(req.body, variables);
    final resolvedReq = req.copyWith(
      url: resolvedUrl, headers: resolvedHeaders, body: resolvedBody);

    final sw = Stopwatch()..start();
    try {
      final response = await ApiService.sendRequest(resolvedReq, timeoutSeconds: timeout);
      sw.stop();
      _updateResult(index, state.summary!.results[index].copyWith(
        status: response.isError ? RunStatus.fail : RunStatus.success,
        response: response,
        duration: sw.elapsed,
      ));
    } catch (e) {
      sw.stop();
      _updateResult(index, state.summary!.results[index].copyWith(
        status: RunStatus.fail,
        error: e.toString(),
        duration: sw.elapsed,
      ));
    }
    state = state.copyWith(isRunning: false);
  }

  void clearSummary() {
    state = const RunnerState();
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
