import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:devpocket/core/theme/app_colors.dart';
import 'package:devpocket/core/theme/app_text_styles.dart';
import 'package:devpocket/core/utils/formatters.dart';
import 'package:devpocket/core/widgets/frosted_glass.dart';
import 'package:devpocket/core/widgets/glowing_empty_state.dart';
import 'package:devpocket/features/api_tester/providers/api_tester_provider.dart';
import 'package:devpocket/features/api_tester/models/request_model.dart';
import 'package:devpocket/features/api_tester/widgets/method_selector.dart';
import 'package:devpocket/features/api_tester/widgets/headers_editor.dart';
import 'package:devpocket/features/api_tester/widgets/body_editor.dart';
import 'package:devpocket/features/api_tester/widgets/response_viewer.dart';
import 'package:devpocket/features/api_tester/widgets/collections_drawer.dart';
import 'package:devpocket/features/api_tester/widgets/environment_selector.dart';
import 'package:devpocket/features/api_tester/runner_screen.dart';
import 'package:devpocket/features/api_tester/environment_manager_screen.dart';

class ApiTesterScreen extends ConsumerStatefulWidget {
  const ApiTesterScreen({super.key});

  @override
  ConsumerState<ApiTesterScreen> createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends ConsumerState<ApiTesterScreen> {
  final _urlController = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _activeTab = 0; // 0=Params, 1=Auth, 2=Headers, 3=Body

  @override
  void initState() {
    super.initState();
    final req = ref.read(apiTesterProvider).request;
    _urlController.text = req.url;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to URL changes from provider to update controller
    ref.listen(apiTesterProvider.select((s) => s.request.url), (prev, next) {
      if (next != _urlController.text) {
        // Prevent cursor jumping by only updating if different
        _urlController.value = _urlController.value.copyWith(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(apiTesterProvider);
    final notifier = ref.read(apiTesterProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CollectionsDrawer(
        collections: state.collections,
        savedRequests: state.savedRequests,
        onSelect: (req) {
          notifier.loadRequest(req);
          _urlController.text = req.url;
          Navigator.of(context).pop();
        },
        onCreate: (name) => notifier.createCollection(name),
        onSave: (colId, name) => notifier.saveToCollection(colId, name: name),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App bar
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FrostedGlass(
                blur: context.isDarkMode ? 15.0 : 0,
                color: context.adaptiveAppBarBackground,
                child: const SizedBox.expand(),
              ),
              leading: Hero(
                tag: 'hero-api-tester',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),
              title: Text('API Tester', style: context.textStyles.heading2),
              actions: [
                const EnvironmentSelector(),
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
                  tooltip: 'How to use',
                  onPressed: () => context.push('/api-help'),
                ),
                IconButton(
                  icon: const Icon(Icons.save_rounded),
                  tooltip: 'Save to Collection',
                  onPressed: () => _showSaveDialog(context, notifier, state),
                ),
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'History',
                  onPressed: () => _showHistorySheet(context, state, notifier),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_open_rounded),
                  tooltip: 'Collections',
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Method selector
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: MethodSelector(
                  selected: state.request.method,
                  onChanged: notifier.updateMethod,
                ),
              ),
            ),

            // URL bar
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _UrlBar(
                  controller: _urlController,
                  method: state.request.method,
                  onChanged: notifier.updateUrl,
                ),
              ),
            ),

            // ── Request Editor Tabs (IndexedStack approach) ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ── Tab Bar ──────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: context.adaptiveGlassSurface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        border: Border(
                          top: BorderSide(color: context.adaptiveGlassBorder),
                          left: BorderSide(color: context.adaptiveGlassBorder),
                          right: BorderSide(color: context.adaptiveGlassBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildTab('Params', 0),
                          _buildTab('Auth', 1),
                          _buildTab('Headers', 2),
                          if (['POST', 'PUT', 'PATCH', 'DELETE']
                              .contains(state.request.method))
                            _buildTab('Body', 3),
                        ],
                      ),
                    ),
                    // ── Tab Content ──────────────────────────────
                    Container(
                      height: 270,
                      decoration: BoxDecoration(
                        color: context.adaptiveGlassSurface,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                        border: Border(
                          bottom: BorderSide(color: context.adaptiveGlassBorder),
                          left: BorderSide(color: context.adaptiveGlassBorder),
                          right: BorderSide(color: context.adaptiveGlassBorder),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                        child: IndexedStack(
                          index: _activeTab.clamp(
                            0,
                            ['POST', 'PUT', 'PATCH', 'DELETE']
                                    .contains(state.request.method)
                                ? 3
                                : 2,
                          ),
                          children: [
                            // 0 — Params
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: HeadersEditor(
                                pairs: state.request.params,
                                onChanged: notifier.updateParams,
                                keyHint: 'Param',
                                valueHint: 'Value',
                              ),
                            ),
                            // 1 — Auth
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: _AuthEditor(
                                request: state.request,
                                onBearerChanged: notifier.updateBearerToken,
                                onBasicChanged: notifier.updateBasicAuth,
                                onApiKeyChanged: notifier.updateApiKey,
                              ),
                            ),
                            // 2 — Headers
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: HeadersEditor(
                                pairs: state.request.headers,
                                onChanged: notifier.updateHeaders,
                                keyHint: 'Header',
                                valueHint: 'Value',
                              ),
                            ),
                            // 3 — Body
                            if (['POST', 'PUT', 'PATCH', 'DELETE']
                                .contains(state.request.method))
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: BodyEditor(
                                  body: state.request.body,
                                  bodyType: state.request.bodyType,
                                  onBodyChanged: notifier.updateBody,
                                  onTypeChanged: notifier.updateBodyType,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Send button
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: _SendButton(
                  isLoading: state.isLoading,
                  onSend: () {
                    HapticFeedback.lightImpact();
                    ref.read(apiTesterProvider.notifier).sendRequest();
                    // Scroll down to response after a moment
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    });
                  },
                ),
              ),
            ),

            // Response
            if (state.response != null || state.isLoading)
              SliverToBoxAdapter(
                child: ResponseViewer(
                  response: state.response,
                  isLoading: state.isLoading,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String? _authBadge(RequestModel req) {
    if (req.bearerToken?.isNotEmpty == true) return 'Bearer';
    if (req.basicAuthUser?.isNotEmpty == true) return 'Basic';
    if (req.apiKey?.isNotEmpty == true) return 'API Key';
    return null;
  }

  void _showHistorySheet(
      BuildContext context, ApiTesterState state, ApiTesterNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FlexibleSpaceBar.createSettings(
        currentExtent: 1.0,
        child: FrostedGlass(
          blur: 20.0,
          color: context.adaptiveOverlaySurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, sc) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: context.adaptiveTextSecondary.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('History', style: context.textStyles.heading2),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          notifier.clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
                if (state.history.isEmpty)
                  const Expanded(
                    child: GlowingEmptyState(
                      icon: Icons.history_rounded,
                      title: 'No history',
                      subtitle: 'Run requests to see them here.',
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: sc,
                      itemCount: state.history.length,
                      itemBuilder: (_, i) {
                        final req = state.history[i];
                        return ListTile(
                          leading: _MethodChip(method: req.method),
                          title: Text(
                            req.url,
                            style: context.textStyles.codeSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            AppFormatters.timeAgo(req.createdAt),
                            style: context.textStyles.caption,
                          ),
                          onTap: () {
                            notifier.loadRequest(req);
                            _urlController.text = req.url;
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(
      BuildContext context, ApiTesterNotifier notifier, ApiTesterState state) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Request name'),
            ),
            const SizedBox(height: 12),
            if (state.collections.isEmpty)
              const Text('No collections yet. Create one first.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (state.collections.isNotEmpty) {
                await notifier.saveToCollection(
                  state.collections.first.id,
                  name: nameController.text,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ------ Tab Content (transparent background) ------
class _TabContent extends StatelessWidget {
  final Widget child;
  const _TabContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

// ------ URL Bar ------
class _UrlBar extends StatelessWidget {
  final TextEditingController controller;
  final String method;
  final ValueChanged<String> onChanged;

  const _UrlBar({
    required this.controller,
    required this.method,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.adaptiveCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              'https://',
              style: context.textStyles.codeSmall
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: context.textStyles.code.copyWith(fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: 'api.example.com/v1/users',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textMuted,
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

// ------ Send Button ------
class _SendButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onSend;

  const _SendButton({required this.isLoading, required this.onSend});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final glow = Tween<double>(begin: 0.25, end: 0.55).evaluate(_pulseController);
        return GestureDetector(
          onTap: widget.isLoading ? null : widget.onSend,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(glow),
                  blurRadius: 18, offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.isLoading
                  ? [const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))]
                  : [
                      Text('SEND REQUEST',
                          style: context.textStyles.button.copyWith(letterSpacing: 1.5)),
                      const SizedBox(width: 10),
                      const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ],
            ),
          ),
        );
      },
    );
  }
}

// ------ Auth Editor ------
class _AuthEditor extends StatefulWidget {
  final RequestModel request;
  final ValueChanged<String> onBearerChanged;
  final Function(String, String) onBasicChanged;
  final Function(String, String) onApiKeyChanged;

  const _AuthEditor({
    required this.request,
    required this.onBearerChanged,
    required this.onBasicChanged,
    required this.onApiKeyChanged,
  });

  @override
  State<_AuthEditor> createState() => _AuthEditorState();
}

class _AuthEditorState extends State<_AuthEditor> {
  String _type = 'none';

  @override
  void initState() {
    super.initState();
    if (widget.request.bearerToken?.isNotEmpty == true) _type = 'bearer';
    else if (widget.request.basicAuthUser?.isNotEmpty == true) _type = 'basic';
    else if (widget.request.apiKey?.isNotEmpty == true) _type = 'apikey';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['none', 'bearer', 'basic', 'apikey'].map((t) {
            final selected = _type == t;
            return ChoiceChip(
              label: Text(t.toUpperCase()),
              selected: selected,
              onSelected: (_) => setState(() => _type = t),
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: context.textStyles.labelSmall.copyWith(
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (_type == 'bearer')
          TextField(
            decoration: const InputDecoration(hintText: 'Bearer token'),
            onChanged: widget.onBearerChanged,
            controller: TextEditingController(text: widget.request.bearerToken ?? ''),
            style: context.textStyles.code,
          ),
        if (_type == 'basic') ...[
          TextField(
            decoration: const InputDecoration(hintText: 'Username'),
            onChanged: (v) => widget.onBasicChanged(v, widget.request.basicAuthPassword ?? ''),
            controller: TextEditingController(text: widget.request.basicAuthUser ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'Password'),
            obscureText: true,
            onChanged: (v) => widget.onBasicChanged(widget.request.basicAuthUser ?? '', v),
          ),
        ],
        if (_type == 'apikey') ...[
          TextField(
            decoration: const InputDecoration(hintText: 'Header name (e.g. X-API-Key)'),
            onChanged: (v) => widget.onApiKeyChanged(widget.request.apiKey ?? '', v),
            controller: TextEditingController(text: widget.request.apiKeyHeader ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'API Key value'),
            onChanged: (v) => widget.onApiKeyChanged(v, widget.request.apiKeyHeader ?? ''),
            controller: TextEditingController(text: widget.request.apiKey ?? ''),
          ),
        ],
      ],
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String method;
  const _MethodChip({required this.method});

  Color get color {
    return switch (method) {
      'GET' => AppColors.methodGet,
      'POST' => AppColors.methodPost,
      'PUT' => AppColors.methodPut,
      'PATCH' => AppColors.methodPatch,
      'DELETE' => AppColors.methodDelete,
      'HEAD' => AppColors.methodHead,
      _ => AppColors.methodOptions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(method, style: context.textStyles.labelSmall.copyWith(
        color: color, fontWeight: FontWeight.w700)),
    );
  }
}
