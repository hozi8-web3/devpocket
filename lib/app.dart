import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/home/home_screen.dart';
import 'features/api_tester/api_tester_screen.dart';
import 'features/api_tester/runner_screen.dart';
import 'features/api_tester/environment_manager_screen.dart';
import 'features/api_tester/api_tester_help_screen.dart';
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
import 'features/terminal/terminal_screen.dart';

CustomTransitionPage _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeIn).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', pageBuilder: (ctx, state) => _buildPage(const SplashScreen(), state)),
    GoRoute(path: '/onboarding', pageBuilder: (ctx, state) => _buildPage(const OnboardingScreen(), state)),
    GoRoute(path: '/home', pageBuilder: (ctx, state) => _buildPage(const HomeScreen(), state)),
    GoRoute(path: '/api-tester', pageBuilder: (ctx, state) => _buildPage(const ApiTesterScreen(), state)),
    GoRoute(
      path: '/api-runner/:id',
      pageBuilder: (ctx, state) => _buildPage(
        CollectionRunnerScreen(collectionId: state.pathParameters['id'] ?? ''),
        state,
      ),
    ),
    GoRoute(
      path: '/api-help',
      builder: (context, state) => const ApiTesterHelpScreen(),
    ),
    GoRoute(path: '/environments', pageBuilder: (ctx, state) => _buildPage(const EnvironmentManagerScreen(), state)),
    GoRoute(path: '/jwt', pageBuilder: (ctx, state) => _buildPage(const JwtScreen(), state)),
    GoRoute(path: '/json-tools', pageBuilder: (ctx, state) => _buildPage(const JsonToolsScreen(), state)),
    GoRoute(path: '/generators', pageBuilder: (ctx, state) => _buildPage(const GeneratorsScreen(), state)),
    GoRoute(path: '/network-tools', pageBuilder: (ctx, state) => _buildPage(const NetworkToolsScreen(), state)),
    GoRoute(path: '/encoders', pageBuilder: (ctx, state) => _buildPage(const EncodersScreen(), state)),
    GoRoute(path: '/regex', pageBuilder: (ctx, state) => _buildPage(const RegexTesterScreen(), state)),
    GoRoute(path: '/cron', pageBuilder: (ctx, state) => _buildPage(const CronScreen(), state)),
    GoRoute(path: '/monitor', pageBuilder: (ctx, state) => _buildPage(const MonitorScreen(), state)),
    GoRoute(
      path: '/monitor/:id',
      pageBuilder: (ctx, state) => _buildPage(
        MonitorDetailScreen(serverId: state.pathParameters['id'] ?? ''),
        state,
      ),
    ),
    GoRoute(path: '/reference', pageBuilder: (ctx, state) => _buildPage(const ReferenceScreen(), state)),
    GoRoute(path: '/help', pageBuilder: (ctx, state) => _buildPage(const HelpScreen(), state)),
    GoRoute(path: '/settings', pageBuilder: (ctx, state) => _buildPage(const SettingsScreen(), state)),
    GoRoute(path: '/terminal', pageBuilder: (ctx, state) => _buildPage(const TerminalScreen(), state)),
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
