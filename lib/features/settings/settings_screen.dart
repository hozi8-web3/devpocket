import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/section_header.dart';
import '../settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop()),
        title: Text('Settings', style: context.textStyles.heading2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          const SectionHeader(title: 'Appearance'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.adaptiveCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.adaptiveCardBorder),
            ),
            child: Column(children: [
              _ThemeTile(
                label: 'AMOLED Dark',
                subtitle: 'True black for OLED displays',
                icon: Icons.phone_android_rounded,
                mode: AppThemeMode.amoledDark,
                current: settings.themeMode,
                onTap: () => notifier.setTheme(AppThemeMode.amoledDark),
              ),
              _Divider(),
              _ThemeTile(
                label: 'Dark',
                subtitle: 'Default dark theme',
                icon: Icons.dark_mode_rounded,
                mode: AppThemeMode.dark,
                current: settings.themeMode,
                onTap: () => notifier.setTheme(AppThemeMode.dark),
              ),
              _Divider(),
              _ThemeTile(
                label: 'Light',
                subtitle: 'Light theme',
                icon: Icons.light_mode_rounded,
                mode: AppThemeMode.light,
                current: settings.themeMode,
                onTap: () => notifier.setTheme(AppThemeMode.light),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Network
          const SectionHeader(title: 'Network'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.adaptiveCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.adaptiveCardBorder),
            ),
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Request Timeout',
                  style: context.textStyles.body
                      .copyWith(color: context.adaptiveTextPrimary)),
              Text('${settings.requestTimeoutSeconds} seconds',
                  style: context.textStyles.caption),
              Slider(
                value: settings.requestTimeoutSeconds.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '${settings.requestTimeoutSeconds}s',
                onChanged: (v) => notifier.setTimeout(v.round()),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Server Monitor
          const SectionHeader(title: 'Server Monitor'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.adaptiveCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.adaptiveCardBorder),
            ),
            child: Column(children: [
              SwitchListTile(
                title:
                    Text('Enable Monitoring', style: context.textStyles.body),
                subtitle: Text('Run checks in background',
                    style: context.textStyles.caption),
                value: settings.monitoringEnabled,
                onChanged: notifier.setMonitoringEnabled,
                secondary: const Icon(Icons.monitor_heart_rounded,
                    color: AppColors.danger),
              ),
              _Divider(),
              SwitchListTile(
                title: Text('Notify on Down', style: context.textStyles.body),
                subtitle: Text('Alert when server goes down',
                    style: context.textStyles.caption),
                value: settings.notifyOnDown,
                onChanged: settings.monitoringEnabled
                    ? notifier.setNotifyOnDown
                    : null,
                secondary: const Icon(Icons.notifications_active_rounded,
                    color: AppColors.warning),
              ),
              _Divider(),
              SwitchListTile(
                title:
                    Text('Notify on Recovery', style: context.textStyles.body),
                subtitle: Text('Alert when server comes back',
                    style: context.textStyles.caption),
                value: settings.notifyOnRecover,
                onChanged: settings.monitoringEnabled
                    ? notifier.setNotifyOnRecover
                    : null,
                secondary: const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // About
          const SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.adaptiveCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.adaptiveCardBorder),
            ),
            child: Column(children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd
                    ]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset('assets/logo.png',
                      width: 22, height: 22, filterQuality: FilterQuality.high),
                ),
                title: Text('DevPocket',
                    style: context.textStyles.body.copyWith(
                        color: context.adaptiveTextPrimary,
                        fontWeight: FontWeight.w600)),
                subtitle: Text('Developer Toolkit',
                    style: context.textStyles.caption),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snap) {
                      final v =
                          snap.hasData ? 'v${snap.data!.version}' : 'v...';
                      return Text(v,
                          style: context.textStyles.codeSmall
                              .copyWith(color: AppColors.primary));
                    },
                  ),
                ),
              ),
              _Divider(),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded,
                    color: AppColors.primary),
                title: Text('Documentation', style: context.textStyles.body),
                subtitle: Text('devpocket.gitbook.io',
                    style: context.textStyles.caption),
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 16, color: AppColors.textMuted),
                onTap: () => launchUrl(
                  Uri.parse('https://devpocket.gitbook.io/devpocket/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _Divider(),
              ListTile(
                leading:
                    const Icon(Icons.code_rounded, color: AppColors.textMuted),
                title: Text('All tools work offline',
                    style: context.textStyles.body),
                subtitle: Text('Except network-dependent tools',
                    style: context.textStyles.caption),
              ),
            ]),
          ),
          const SizedBox(height: 32),

          // Made By
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () =>
                  launchUrl(Uri.parse('https://github.com/hozi8-web3')),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Made by ',
                      style: context.textStyles.caption.copyWith(
                        color: context.adaptiveTextSecondary,
                      ),
                    ),
                    Text(
                      'HOZAIFA ALI',
                      style: context.textStyles.label.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final AppThemeMode mode;
  final AppThemeMode current;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == mode;
    return ListTile(
      onTap: onTap,
      leading:
          Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted),
      title: Text(label,
          style: context.textStyles.body.copyWith(
              color:
                  selected ? AppColors.primary : context.adaptiveTextPrimary)),
      subtitle: Text(subtitle, style: context.textStyles.caption),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: context.adaptiveCardBorder,
    );
  }
}
