import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/glowing_empty_state.dart';
import '../../../core/widgets/frosted_glass.dart';
import '../models/response_model.dart';
import '../models/request_model.dart';

class CollectionsDrawer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: FrostedGlass(
        blur: 20.0,
        color: AppColors.surface.withOpacity(0.85),
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Text('Collections', style: AppTextStyles.heading2),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
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
                      title: Text(col.name, style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary)),
                      subtitle: Text('${requests.length} request${requests.length == 1 ? '' : 's'}',
                          style: AppTextStyles.caption),
                      children: requests.map((req) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
                          leading: _MethodBadge(method: req.method),
                          title: Text(
                            req.name ?? req.url,
                            style: AppTextStyles.codeSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => onSelect(req),
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
    _ => AppColors.textSecondary,
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
          style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}
