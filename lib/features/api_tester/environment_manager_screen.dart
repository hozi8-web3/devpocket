import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/frosted_glass.dart';
import 'models/environment_model.dart';
import 'providers/environment_provider.dart';

class EnvironmentManagerScreen extends ConsumerWidget {
  const EnvironmentManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envState = ref.watch(environmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Environments', style: context.textStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'How to use',
            onPressed: () => context.push('/api-help'),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => _showAddEnvironmentDialog(context, ref),
          ),
        ],
      ),
      body: envState.environments.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: envState.environments.length,
              itemBuilder: (context, index) {
                final env = envState.environments[index];
                final bool isActive = env.id == envState.activeEnvironmentId;
                
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: context.adaptiveCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isActive ? AppColors.primary : context.adaptiveCardBorder,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Row(
                      children: [
                        Text(env.name, style: context.textStyles.bodyBold),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Active', style: context.textStyles.labelSmall.copyWith(color: AppColors.primary)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text('${env.variables.length} variables', style: context.textStyles.caption),
                    onTap: () => _showEditEnvironmentDialog(context, ref, env),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isActive)
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                            onPressed: () => ref.read(environmentProvider.notifier).setActiveEnvironment(env.id),
                            tooltip: 'Set as Active',
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                          onPressed: () => _confirmDelete(context, ref, env),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('No Environments', style: context.textStyles.heading3),
          const SizedBox(height: 8),
          Text('Create an environment to use dynamic variables.', style: context.textStyles.caption),
        ],
      ),
    );
  }

  void _showAddEnvironmentDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Environment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Production, Staging'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(environmentProvider.notifier).createEnvironment(controller.text);
                context.pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEnvironmentDialog(BuildContext context, WidgetRef ref, EnvironmentModel env) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditEnvironmentModal(env: env),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EnvironmentModel env) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Environment?'),
        content: Text('This will permanently delete "${env.name}" and all its variables.'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(environmentProvider.notifier).deleteEnvironment(env.id);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _EditEnvironmentModal extends ConsumerStatefulWidget {
  final EnvironmentModel env;
  const _EditEnvironmentModal({required this.env});

  @override
  ConsumerState<_EditEnvironmentModal> createState() => _EditEnvironmentModalState();
}

class _EditEnvironmentModalState extends ConsumerState<_EditEnvironmentModal> {
  late Map<String, String> _variables;
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _variables = Map.from(widget.env.variables);
  }

  void _save() {
    ref.read(environmentProvider.notifier).updateEnvironment(
      widget.env.copyWith(variables: _variables),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FrostedGlass(
      blur: 20,
      color: context.adaptiveOverlaySurface,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.env.name, style: context.textStyles.heading2),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text('Variables', style: context.textStyles.bodyBold),
            const SizedBox(height: 10),
            if (_variables.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No variables yet', style: context.textStyles.caption)),
              )
            else
              ..._variables.entries.map((e) => _buildVariableRow(e.key, e.value)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: TextField(controller: _keyController, decoration: const InputDecoration(hintText: 'Key (e.g. baseUrl)'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _valueController, decoration: const InputDecoration(hintText: 'Value'))),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  onPressed: () {
                    if (_keyController.text.isNotEmpty) {
                      setState(() => _variables[_keyController.text] = _valueController.text);
                      _keyController.clear();
                      _valueController.clear();
                      _save();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(key, style: context.textStyles.codeSmall)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: context.textStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.danger, size: 20),
            onPressed: () {
              setState(() => _variables.remove(key));
              _save();
            },
          ),
        ],
      ),
    );
  }
}
