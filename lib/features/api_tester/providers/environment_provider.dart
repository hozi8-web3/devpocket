import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/environment_model.dart';

class EnvironmentState {
  final List<EnvironmentModel> environments;
  final String? activeEnvironmentId;
  final bool isLoading;

  const EnvironmentState({
    this.environments = const [],
    this.activeEnvironmentId,
    this.isLoading = false,
  });

  EnvironmentModel? get activeEnvironment {
    if (activeEnvironmentId == null) return null;
    return environments.cast<EnvironmentModel?>().firstWhere(
          (e) => e?.id == activeEnvironmentId,
          orElse: () => null,
        );
  }

  EnvironmentState copyWith({
    List<EnvironmentModel>? environments,
    String? activeEnvironmentId,
    bool? isLoading,
    bool clearActiveId = false,
  }) {
    return EnvironmentState(
      environments: environments ?? this.environments,
      activeEnvironmentId: clearActiveId ? null : (activeEnvironmentId ?? this.activeEnvironmentId),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EnvironmentNotifier extends StateNotifier<EnvironmentState> {
  static const _boxName = 'api_environments';
  static const _activeIdKey = 'active_environment_id';

  EnvironmentNotifier() : super(const EnvironmentState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    final box = await Hive.openBox<String>(_boxName);
    final settingsBox = await Hive.openBox<String>('settings');

    final envs = box.values.map((v) {
      try {
        return EnvironmentModel.fromJson(jsonDecode(v));
      } catch (_) {
        return null;
      }
    }).whereType<EnvironmentModel>().toList();

    final activeId = settingsBox.get(_activeIdKey);

    state = state.copyWith(
      environments: envs,
      activeEnvironmentId: activeId,
      isLoading: false,
    );
  }

  Future<void> createEnvironment(String name) async {
    final env = EnvironmentModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      variables: {},
    );
    await _saveEnvironment(env);
    if (state.activeEnvironmentId == null) {
      await setActiveEnvironment(env.id);
    }
  }

  Future<void> updateEnvironment(EnvironmentModel env) async {
    await _saveEnvironment(env);
  }

  Future<void> deleteEnvironment(String id) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.delete(id);
    
    String? newActiveId = state.activeEnvironmentId;
    if (newActiveId == id) {
      newActiveId = null;
      final settingsBox = await Hive.openBox<String>('settings');
      await settingsBox.delete(_activeIdKey);
    }

    state = state.copyWith(
      environments: state.environments.where((e) => e.id != id).toList(),
      activeEnvironmentId: newActiveId,
      clearActiveId: newActiveId == null,
    );
  }

  Future<void> setActiveEnvironment(String? id) async {
    final settingsBox = await Hive.openBox<String>('settings');
    if (id == null) {
      await settingsBox.delete(_activeIdKey);
    } else {
      await settingsBox.put(_activeIdKey, id);
    }
    state = state.copyWith(activeEnvironmentId: id, clearActiveId: id == null);
  }

  Future<void> _saveEnvironment(EnvironmentModel env) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.put(env.id, jsonEncode(env.toJson()));
    
    final newList = [...state.environments];
    final index = newList.indexWhere((e) => e.id == env.id);
    if (index >= 0) {
      newList[index] = env;
    } else {
      newList.add(env);
    }
    
    state = state.copyWith(environments: newList);
  }
}

final environmentProvider =
    StateNotifierProvider<EnvironmentNotifier, EnvironmentState>(
  (ref) => EnvironmentNotifier(),
);
