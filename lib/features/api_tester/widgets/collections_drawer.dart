import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glowing_empty_state.dart';
import '../../../core/widgets/frosted_glass.dart';
import '../models/response_model.dart';
import '../models/request_model.dart';
import '../services/collection_export_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_tester_provider.dart';

class CollectionsDrawer extends ConsumerWidget {
  final List<CollectionModel> collections;
  final List<RequestModel> savedRequests;
  final ValueChanged<RequestModel> onSelect;
  final ValueChanged<String> onCreate;
  final Function(String colId, String? name) onSave;

  const CollectionsDrawer({
    super.key,
    required this.collections,
    required this.savedRequests,
    required this.onSelect,
    required this.onCreate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: FrostedGlass(
        blur: 20.0,
        color: context.adaptiveOverlaySurface,
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Text('Collections', style: context.textStyles.heading2),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.file_upload_outlined, color: context.adaptiveTextPrimary),
                    tooltip: 'Export Collections',
                    onPressed: () => CollectionExportService.exportAndShare(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.file_download_outlined, color: context.adaptiveTextPrimary),
                    tooltip: 'Import Collections',
                    onPressed: () async {
                      final success = await CollectionExportService.importFromFile(context);
                      if (success) {
                        ref.read(apiTesterProvider.notifier).refreshData();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                    tooltip: 'New Collection',
                    onPressed: () => _showNewCollectionDialog(context),
                  ),
                ],
              ),
            ),
            if (collections.isEmpty)
              const Expanded(
                child: GlowingEmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'No collections yet',
                  subtitle: 'Save a request to create your first collection.',
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: collections.length,
                  itemBuilder: (_, i) {
                    final col = collections[i];
                    final requests = savedRequests
                        .where((r) => r.collectionId == col.id)
                        .toList();
                    return ExpansionTile(
                      leading: const Icon(Icons.folder_rounded,
                          color: AppColors.primary, size: 20),
                      title: Text(col.name, style: context.textStyles.body.copyWith(
                        color: context.adaptiveTextPrimary)),
                      subtitle: Text('${requests.length} request${requests.length == 1 ? '' : 's'}',
                          style: context.textStyles.caption),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                        onPressed: () => context.push('/api-runner/${col.id}'),
                        tooltip: 'Run Collection',
                      ),
                      children: requests.map((req) {
                        return GestureDetector(
                          onLongPress: () =>
                              _showRequestMenu(context, ref, req),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 0),
                            leading: _MethodBadge(method: req.method),
                            title: Text(
                              req.name ?? req.url,
                              style: context.textStyles.codeSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.more_vert_rounded,
                                size: 16, color: AppColors.textMuted),
                            onTap: () => onSelect(req),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

  void _showRequestMenu(
      BuildContext context, WidgetRef ref, RequestModel req) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                req.name ?? req.url,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.primary),
              title: const Text('Duplicate Request'),
              onTap: () {
                Navigator.pop(context);
                final copy = req.copyWith(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: '${req.name ?? 'Request'} (copy)',
                );
                ref
                    .read(apiTesterProvider.notifier)
                    .saveToCollection(req.collectionId, name: copy.name);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              title: const Text('Delete Request',
                  style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(apiTesterProvider.notifier)
                    .deleteRequest(req.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewCollectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Collection name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onCreate(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  final String method;
  const _MethodBadge({required this.method});

  Color get color => switch (method) {
    'GET' => AppColors.methodGet,
    'POST' => AppColors.methodPost,
    'PUT' => AppColors.methodPut,
    'PATCH' => AppColors.methodPatch,
    'DELETE' => AppColors.methodDelete,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(method.substring(0, method.length > 3 ? 3 : method.length),
          style: context.textStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
