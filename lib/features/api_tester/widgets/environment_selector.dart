import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/environment_provider.dart';

class EnvironmentSelector extends ConsumerWidget {
  const EnvironmentSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(environmentProvider);
    final activeEnv = state.activeEnvironment;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.adaptiveGlassBorder),
      ),
      child: PopupMenuButton<String?>(
        tooltip: 'Select Environment',
        onSelected: (id) {
          if (id == 'manage') {
            context.push('/environments');
          } else {
            ref.read(environmentProvider.notifier).setActiveEnvironment(id);
          }
        },
        offset: const Offset(0, 45),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: null,
            child: Row(
              children: [
                Icon(Icons.public_rounded, size: 18),
                SizedBox(width: 8),
                Text('No Environment'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          ...state.environments.map((env) => PopupMenuItem(
                value: env.id,
                child: Row(
                  children: [
                    Icon(
                      Icons.hub_rounded,
                      size: 18,
                      color: env.id == state.activeEnvironmentId ? AppColors.primary : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      env.name,
                      style: TextStyle(
                        color: env.id == state.activeEnvironmentId ? AppColors.primary : null,
                        fontWeight: env.id == state.activeEnvironmentId ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              )),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'manage',
            child: Row(
              children: [
                Icon(Icons.settings_rounded, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Manage Environments', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activeEnv == null ? Icons.public_rounded : Icons.hub_rounded,
                size: 16,
                color: activeEnv == null ? context.adaptiveTextSecondary : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  activeEnv?.name ?? 'No Env',
                  style: context.textStyles.labelSmall.copyWith(
                    color: activeEnv == null ? context.adaptiveTextSecondary : AppColors.primary,
                    fontWeight: activeEnv == null ? null : FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: context.adaptiveTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
