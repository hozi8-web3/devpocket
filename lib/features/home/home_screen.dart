import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/frosted_glass.dart';
import '../../core/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/tool_card.dart';
import '../../core/widgets/section_header.dart';

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final bool isNew;
  final String heroTag;

  const _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.isNew = false,
    required this.heroTag,
  });
}

const List<_ToolItem> _tools = [
  _ToolItem(
    title: 'API Tester',
    subtitle: 'REST client with collections',
    icon: Icons.api_rounded,
    color: AppColors.primary,
    route: '/api-tester',
    heroTag: 'hero-api-tester',
  ),
  _ToolItem(
    title: 'JWT Decoder',
    subtitle: 'Decode, verify & generate',
    icon: Icons.lock_open_rounded,
    color: AppColors.secondary,
    route: '/jwt',
    heroTag: 'hero-jwt',
  ),
  _ToolItem(
    title: 'JSON Tools',
    subtitle: 'Format, diff, validate, query',
    icon: Icons.data_object_rounded,
    color: Color(0xFFF59E0B),
    route: '/json-tools',
    heroTag: 'hero-json-tools',
  ),
  _ToolItem(
    title: 'Generators',
    subtitle: 'UUID, password, hash, HMAC',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF10B981),
    route: '/generators',
    heroTag: 'hero-generators',
  ),
  _ToolItem(
    title: 'Network Tools',
    subtitle: 'Ping, DNS, SSL, IP lookup',
    icon: Icons.network_check_rounded,
    color: Color(0xFF3B82F6),
    route: '/network-tools',
    heroTag: 'hero-network-tools',
  ),
  _ToolItem(
    title: 'Encoders',
    subtitle: 'Base64, URL, HTML, Hex',
    icon: Icons.transform_rounded,
    color: Color(0xFFEC4899),
    route: '/encoders',
    heroTag: 'hero-encoders',
  ),
  _ToolItem(
    title: 'Regex Tester',
    subtitle: 'Real-time match highlighting',
    icon: Icons.manage_search_rounded,
    color: Color(0xFF8B5CF6),
    route: '/regex',
    heroTag: 'hero-regex',
  ),
  _ToolItem(
    title: 'Cron Parser',
    subtitle: 'Explain & schedule builder',
    icon: Icons.schedule_rounded,
    color: Color(0xFF06B6D4),
    route: '/cron',
    heroTag: 'hero-cron',
  ),
  _ToolItem(
    title: 'Server Monitor',
    subtitle: 'Uptime tracking & history',
    icon: Icons.monitor_heart_rounded,
    color: Color(0xFFEF4444),
    route: '/monitor',
    heroTag: 'hero-monitor',
  ),
  _ToolItem(
    title: 'Reference',
    subtitle: 'HTTP codes, ports, git, linux',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFF97316),
    route: '/reference',
    heroTag: 'hero-reference',
  ),
  _ToolItem(
    title: 'Terminal',
    subtitle: 'Termux-like dev shell',
    icon: Icons.terminal_rounded,
    color: Color(0xFF22C55E),
    route: '/terminal',
    isNew: true,
    heroTag: 'hero-terminal',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final updateInfo = await UpdateService.checkForUpdates();
    if (updateInfo != null && mounted) {
      _showUpdateSheet(updateInfo);
    }
  }

  void _showUpdateSheet(UpdateInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FrostedGlass(
        blur: 20,
        color: context.adaptiveOverlaySurface,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.adaptiveTextSecondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.system_update_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Update Available', style: context.textStyles.heading2),
                        const SizedBox(height: 4),
                        Text(
                          'Version ${info.version}',
                          style: context.textStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.adaptiveCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.adaptiveCardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Release Notes',
                      style: context.textStyles.label.copyWith(
                        color: context.adaptiveTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      info.releaseNotes.isEmpty ? 'Performance improvements and bug fixes.' : info.releaseNotes,
                      style: context.textStyles.body.copyWith(height: 1.5),
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        if (info.downloadUrl != null) {
                          final uri = Uri.parse(info.downloadUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                      child: const Text('Download Info'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ToolItem> get _filtered => _query.isEmpty
      ? _tools
      : _tools
          .where((t) =>
              t.title.toLowerCase().contains(_query.toLowerCase()) ||
              t.subtitle.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FrostedGlass(
              blur: context.isDarkMode ? 15.0 : 0,
              color: context.adaptiveAppBarBackground,
              child: const SizedBox.expand(),
            ),
            // No expandedHeight / FlexibleSpaceBar — avoids the
            // double-title overlap that caused the "jumbled" logo.
            toolbarHeight: 64,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.developer_mode_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('DevPocket', style: context.textStyles.heading2),
                    Text(
                      'Developer Toolkit',
                      style: context.textStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            titleSpacing: 16,
            actions: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _searching
                    ? IconButton(
                        key: const ValueKey('close'),
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.adaptiveTextSecondary,
                      ),
                        onPressed: () => setState(() {
                          _searching = false;
                          _searchController.clear();
                          _query = '';
                        }),
                      )
                    : IconButton(
                        key: const ValueKey('search'),
                      icon: Icon(
                        Icons.search_rounded,
                        color: context.adaptiveTextSecondary,
                      ),
                        onPressed: () =>
                            setState(() => _searching = true),
                      ),
              ),
              IconButton(
              icon: Icon(
                Icons.help_outline_rounded,
                color: context.adaptiveTextSecondary,
              ),
                onPressed: () => context.push('/help'),
              ),
              IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: context.adaptiveTextSecondary,
              ),
                onPressed: () => context.push('/settings'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Search bar ────────────────────────────────────────
          if (_searching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search tools...',
                    prefixIcon: Icon(Icons.search_rounded,
                        color: context.adaptiveTextSecondary, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style:
                      context.textStyles.body.copyWith(color: context.adaptiveTextPrimary),
                ),
              ),
            ),

          // ── Section header ────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: _query.isEmpty ? 'All Tools' : 'Results',
              subtitle:
                  '${_filtered.length} tool${_filtered.length == 1 ? '' : 's'}',
            ),
          ),

          // ── Tool grid ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final tool = _filtered[i];
                  return ToolCard(
                    title: tool.title,
                    subtitle: tool.subtitle,
                    icon: tool.icon,
                    color: tool.color,
                    isNew: tool.isNew,
                    heroTag: tool.heroTag,
                    onTap: () => context.push(tool.route),
                  );
                },
                childCount: _filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
