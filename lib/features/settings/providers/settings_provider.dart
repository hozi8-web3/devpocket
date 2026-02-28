import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

class SettingsState {
  final AppThemeMode themeMode;
  final int requestTimeoutSeconds; // 5, 10, 30, 60
  final bool monitoringEnabled;
  final bool notifyOnDown;
  final bool notifyOnRecover;

  const SettingsState({
    this.themeMode = AppThemeMode.dark,
    this.requestTimeoutSeconds = 30,
    this.monitoringEnabled = true,
    this.notifyOnDown = true,
    this.notifyOnRecover = true,
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    int? requestTimeoutSeconds,
    bool? monitoringEnabled,
    bool? notifyOnDown,
    bool? notifyOnRecover,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      requestTimeoutSeconds: requestTimeoutSeconds ?? this.requestTimeoutSeconds,
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
      notifyOnDown: notifyOnDown ?? this.notifyOnDown,
      notifyOnRecover: notifyOnRecover ?? this.notifyOnRecover,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  static const _keyTheme = 'theme_mode';
  static const _keyTimeout = 'request_timeout';
  static const _keyMonitoring = 'monitoring_enabled';
  static const _keyNotifyDown = 'notify_down';
  static const _keyNotifyRecover = 'notify_recover';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIdx = prefs.getInt(_keyTheme) ?? 0;
    state = state.copyWith(
      themeMode: AppThemeMode.values[themeIdx.clamp(0, 2)],
      requestTimeoutSeconds: prefs.getInt(_keyTimeout) ?? 30,
      monitoringEnabled: prefs.getBool(_keyMonitoring) ?? true,
      notifyOnDown: prefs.getBool(_keyNotifyDown) ?? true,
      notifyOnRecover: prefs.getBool(_keyNotifyRecover) ?? true,
    );
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
  }

  Future<void> setTimeout(int seconds) async {
    state = state.copyWith(requestTimeoutSeconds: seconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTimeout, seconds);
  }

  Future<void> setMonitoringEnabled(bool v) async {
    state = state.copyWith(monitoringEnabled: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMonitoring, v);
  }

  Future<void> setNotifyOnDown(bool v) async {
    state = state.copyWith(notifyOnDown: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyDown, v);
  }

  Future<void> setNotifyOnRecover(bool v) async {
    state = state.copyWith(notifyOnRecover: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyRecover, v);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
