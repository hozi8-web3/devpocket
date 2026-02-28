import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/server_entry.dart';
import '../services/monitor_service.dart';

class MonitorState {
  final List<ServerEntry> servers;
  final bool isLoading;
  final String? message;

  const MonitorState({
    this.servers = const [],
    this.isLoading = false,
    this.message,
  });

  MonitorState copyWith({
    List<ServerEntry>? servers,
    bool? isLoading,
    String? message,
  }) =>
      MonitorState(
        servers: servers ?? this.servers,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );
}

class MonitorNotifier extends StateNotifier<MonitorState> {
  MonitorNotifier() : super(const MonitorState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final servers = await MonitorService.loadAll();
    state = state.copyWith(servers: servers, isLoading: false);
  }

  Future<void> add({
    required String name,
    required String url,
    int intervalMinutes = 5,
  }) async {
    final server = ServerEntry(
      id: const Uuid().v4(),
      name: name,
      url: url,
      intervalMinutes: intervalMinutes,
    );
    await MonitorService.save(server);
    await load();
    // Immediately check
    await checkServer(server.id);
  }

  Future<void> delete(String id) async {
    await MonitorService.delete(id);
    await load();
  }

  Future<void> checkServer(String id) async {
    final idx = state.servers.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    final updated = await MonitorService.checkNow(state.servers[idx]);
    final list = List<ServerEntry>.from(state.servers);
    list[idx] = updated;
    state = state.copyWith(servers: list);
  }

  Future<void> checkAll() async {
    state = state.copyWith(isLoading: true);
    final list = List<ServerEntry>.from(state.servers);
    for (int i = 0; i < list.length; i++) {
      if (list[i].enabled) {
        list[i] = await MonitorService.checkNow(list[i]);
      }
    }
    state = state.copyWith(servers: list, isLoading: false);
  }

  Future<void> toggle(String id) async {
    final idx = state.servers.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    final server = state.servers[idx];
    server.enabled = !server.enabled;
    await MonitorService.save(server);
    await load();
  }
}

final monitorProvider =
    StateNotifierProvider<MonitorNotifier, MonitorState>(
  (ref) => MonitorNotifier(),
);
