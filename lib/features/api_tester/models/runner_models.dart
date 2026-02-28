import '../models/request_model.dart';
import '../models/response_model.dart';

enum RunStatus { pending, running, success, fail }

class RunnerResult {
  final RequestModel request;
  final ResponseModel? response;
  final RunStatus status;
  final DateTime startTime;
  final Duration? duration;
  final String? error;

  const RunnerResult({
    required this.request,
    this.response,
    this.status = RunStatus.pending,
    required this.startTime,
    this.duration,
    this.error,
  });

  RunnerResult copyWith({
    ResponseModel? response,
    RunStatus? status,
    Duration? duration,
    String? error,
  }) =>
      RunnerResult(
        request: request,
        response: response ?? this.response,
        status: status ?? this.status,
        startTime: startTime,
        duration: duration ?? this.duration,
        error: error ?? this.error,
      );
}

class RunSummary {
  final String collectionName;
  final List<RunnerResult> results;
  final DateTime startedAt;
  final DateTime? finishedAt;

  const RunSummary({
    required this.collectionName,
    required this.results,
    required this.startedAt,
    this.finishedAt,
  });

  int get total => results.length;
  int get successCount => results.where((r) => r.status == RunStatus.success).length;
  int get failCount => results.where((r) => r.status == RunStatus.fail).length;
  int get pendingCount => results.where((r) => r.status == RunStatus.pending).length;
  
  double get progress => total == 0 ? 0 : (total - pendingCount) / total;
  
  Duration get totalDuration => finishedAt?.difference(startedAt) ?? Duration.zero;
  
  Duration get averageResponseTime {
    final list = results.where((r) => r.response != null).map((r) => r.response!.responseTime);
    if (list.isEmpty) return Duration.zero;
    return list.reduce((a, b) => a + b) ~/ list.length;
  }
}
