import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/frosted_glass.dart';
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
              blur: 15.0,
              color: AppColors.background.withOpacity(0.7),
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
                    Text('DevPocket', style: AppTextStyles.heading2),
                    Text(
                      'Developer Toolkit',
                      style: AppTextStyles.caption.copyWith(
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
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => setState(() {
                          _searching = false;
                          _searchController.clear();
                          _query = '';
                        }),
                      )
                    : IconButton(
                        key: const ValueKey('search'),
                        icon: const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () =>
                            setState(() => _searching = true),
                      ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline_rounded,
                    color: AppColors.textSecondary),
                onPressed: () => context.push('/help'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded,
                    color: AppColors.textSecondary),
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
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textPrimary),
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
