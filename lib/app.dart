import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/home/home_screen.dart';
import 'features/api_tester/api_tester_screen.dart';
import 'features/jwt/jwt_screen.dart';
import 'features/json_tools/json_tools_screen.dart';
import 'features/generators/generators_screen.dart';
import 'features/network_tools/network_tools_screen.dart';
import 'features/encoders/encoders_screen.dart';
import 'features/regex_tester/regex_tester_screen.dart';
import 'features/cron_tool/cron_screen.dart';
import 'features/server_monitor/monitor_screen.dart';
import 'features/server_monitor/monitor_detail_screen.dart';
import 'features/reference/reference_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/help/help_screen.dart';
import 'features/splash/splash_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/api-tester', builder: (_, __) => const ApiTesterScreen()),
    GoRoute(path: '/jwt', builder: (_, __) => const JwtScreen()),
    GoRoute(path: '/json-tools', builder: (_, __) => const JsonToolsScreen()),
    GoRoute(path: '/generators', builder: (_, __) => const GeneratorsScreen()),
    GoRoute(path: '/network-tools', builder: (_, __) => const NetworkToolsScreen()),
    GoRoute(path: '/encoders', builder: (_, __) => const EncodersScreen()),
    GoRoute(path: '/regex', builder: (_, __) => const RegexTesterScreen()),
    GoRoute(path: '/cron', builder: (_, __) => const CronScreen()),
    GoRoute(path: '/monitor', builder: (_, __) => const MonitorScreen()),
    GoRoute(
      path: '/monitor/:id',
      builder: (ctx, state) => MonitorDetailScreen(
        serverId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(path: '/reference', builder: (_, __) => const ReferenceScreen()),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);

class DevPocketApp extends ConsumerWidget {
  const DevPocketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final theme = switch (settings.themeMode) {
      AppThemeMode.amoledDark => AppTheme.amoledDark,
      AppThemeMode.light => AppTheme.lightTheme,
      AppThemeMode.dark => AppTheme.darkTheme,
    };

    return MaterialApp.router(
      title: 'DevPocket',
      theme: theme,
      // Always treat AMOLed Dark as Dark Theme to ensure components style correctly
      themeMode: settings.themeMode == AppThemeMode.light 
          ? ThemeMode.light 
          : ThemeMode.dark,
      darkTheme: settings.themeMode == AppThemeMode.amoledDark 
          ? AppTheme.amoledDark 
          : AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
