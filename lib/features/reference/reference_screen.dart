import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';
import '../../core/constants/http_codes.dart';
import '../../core/constants/common_ports.dart';
import '../../core/constants/git_commands.dart';
import '../../core/constants/linux_commands.dart';
import '../../core/constants/http_headers.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() { _search = ''; _searchController.clear(); }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            leading: Hero(
              tag: 'hero-reference',
              child: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Reference', style: context.textStyles.heading2),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0, -0.2),
                  child: Icon(Icons.library_books_rounded, size: 60, color: AppColors.primary.withOpacity(0.5)),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'HTTP Codes'),
                Tab(text: 'Headers'),
                Tab(text: 'Ports'),
                Tab(text: 'Git'),
                Tab(text: 'Linux'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _HttpCodesTab(search: _search),
                  _HeadersTab(search: _search),
                  _PortsTab(search: _search),
                  _GitTab(search: _search),
                  _LinuxTab(search: _search),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HTTP Codes ---
class _HttpCodesTab extends StatelessWidget {
  final String search;
  const _HttpCodesTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = httpStatusCodes.where((c) =>
        search.isEmpty ||
        c.code.toString().contains(search) ||
        c.name.toLowerCase().contains(search.toLowerCase()) ||
        c.description.toLowerCase().contains(search.toLowerCase())).toList();

    final groups = <String, List<HttpStatusCode>>{};
    for (final c in filtered) {
      final cat = '${c.code ~/ 100}xx ${_catName(c.code)}';
      groups.putIfAbsent(cat, () => []).add(c);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groups.entries.map((e) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(e.key, style: context.textStyles.label.copyWith(color: AppColors.primary)),
          ),
          ...e.value.map((c) => _RefCard(
            leading: Text('${c.code}', style: context.textStyles.codeBold.copyWith(color: _httpColor(c.code), fontSize: 18)),
            title: c.name,
            subtitle: c.description,
            copyValue: '${c.code} ${c.name}',
          )),
          const SizedBox(height: 8),
        ],
      )).toList(),
    );
  }

  String _catName(int code) {
    return switch (code ~/ 100) {
      1 => 'Informational',
      2 => 'Success',
      3 => 'Redirection',
      4 => 'Client Error',
      5 => 'Server Error',
      _ => '',
    };
  }

  Color _httpColor(int code) {
    return switch (code ~/ 100) {
      2 => AppColors.success,
      3 => AppColors.warning,
      4 => AppColors.danger,
      5 => const Color(0xFFFF4444),
      _ => AppColors.textMuted,
    };
  }
}

// --- Headers Tab ---
class _HeadersTab extends StatelessWidget {
  final String search;
  const _HeadersTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = httpHeaders.where((h) =>
        search.isEmpty ||
        h.name.toLowerCase().contains(search.toLowerCase()) ||
        h.description.toLowerCase().contains(search.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final h = filtered[i];
        return _RefCard(
          leading: _TypeBadge(type: h.type),
          title: h.name,
          subtitle: h.description,
          detail: h.example,
          copyValue: h.example,
        );
      },
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = type == 'request'
        ? AppColors.methodGet
        : type == 'response'
            ? AppColors.methodPost
            : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(type == 'both' ? 'REQ/RES' : type.toUpperCase(),
          style: context.textStyles.labelSmall.copyWith(color: color, fontSize: 9)),
    );
  }
}

// --- Ports Tab ---
class _PortsTab extends StatelessWidget {
  final String search;
  const _PortsTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = commonPorts.where((p) =>
        search.isEmpty ||
        p.port.toString().contains(search) ||
        p.service.toLowerCase().contains(search.toLowerCase()) ||
        p.description.toLowerCase().contains(search.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final p = filtered[i];
        return _RefCard(
          leading: Text(p.port.toString(), style: context.textStyles.codeBold.copyWith(color: AppColors.secondary, fontSize: 16)),
          title: p.service,
          subtitle: p.description,
          copyValue: p.port.toString(),
        );
      },
    );
  }
}

// --- Git Tab ---
class _GitTab extends StatelessWidget {
  final String search;
  const _GitTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = gitCommands.where((c) =>
        search.isEmpty ||
        c.command.toLowerCase().contains(search.toLowerCase()) ||
        c.description.toLowerCase().contains(search.toLowerCase()) ||
        c.category.toLowerCase().contains(search.toLowerCase())).toList();

    final groups = <String, List<GitCommandEntry>>{};
    for (final c in filtered) groups.putIfAbsent(c.category, () => []).add(c);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groups.entries.map((e) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(e.key, style: context.textStyles.label.copyWith(color: AppColors.primary)),
          ),
          ...e.value.map((c) => _RefCard(
            leading: const Icon(Icons.terminal_rounded, size: 18, color: AppColors.textMuted),
            title: c.description,
            detail: c.command,
            copyValue: c.command,
          )),
          const SizedBox(height: 8),
        ],
      )).toList(),
    );
  }
}

// --- Linux Tab ---
class _LinuxTab extends StatelessWidget {
  final String search;
  const _LinuxTab({required this.search});

  @override
  Widget build(BuildContext context) {
    final filtered = linuxCommands.where((c) =>
        search.isEmpty ||
        c.command.toLowerCase().contains(search.toLowerCase()) ||
        c.description.toLowerCase().contains(search.toLowerCase()) ||
        c.category.toLowerCase().contains(search.toLowerCase())).toList();

    final groups = <String, List<LinuxCommandEntry>>{};
    for (final c in filtered) groups.putIfAbsent(c.category, () => []).add(c);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groups.entries.map((e) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(e.key, style: context.textStyles.label.copyWith(color: AppColors.primary)),
          ),
          ...e.value.map((c) => _RefCard(
            leading: const Icon(Icons.terminal_rounded, size: 18, color: AppColors.textMuted),
            title: c.description,
            detail: '${c.command}${c.flags.isNotEmpty ? '\nFlags: ${c.flags}' : ''}',
            copyValue: c.command,
          )),
          const SizedBox(height: 8),
        ],
      )).toList(),
    );
  }
}

// --- Shared Card ---
class _RefCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final String? detail;
  final String copyValue;

  const _RefCard({
    required this.leading,
    required this.title,
    this.subtitle,
    this.detail,
    required this.copyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.adaptiveCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.adaptiveCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 12),
            child: leading,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.body.copyWith(color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!, style: context.textStyles.caption),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(detail!, style: context.textStyles.codeSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          CopyButton(text: copyValue, compact: true),
        ],
      ),
    );
  }
}
