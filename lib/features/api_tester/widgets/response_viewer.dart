import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/copy_button.dart';
import '../../../core/widgets/code_display.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../models/response_model.dart';

class ResponseViewer extends StatefulWidget {
  final ResponseModel? response;
  final bool isLoading;

  const ResponseViewer({
    super.key,
    this.response,
    this.isLoading = false,
  });

  @override
  State<ResponseViewer> createState() => _ResponseViewerState();
}

class _ResponseViewerState extends State<ResponseViewer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = ['Body', 'Headers', 'Preview', 'Raw'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.response;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: context.adaptiveCardBorder)),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                if (widget.isLoading)
                  const ShimmerLoader(
                    width: 80,
                    height: 24,
                  )
                else if (r != null) ...[
                  if (r.errorMessage != null)
                    const StatusBadge(
                      label: 'Error',
                      type: StatusBadgeType.error,
                      showDot: true,
                    )
                  else
                    StatusBadge(
                      label: '${r.statusCode} ${r.reasonPhrase}',
                      type: StatusBadgeTypeExt.typeForHttpCode(r.statusCode),
                      showDot: true,
                    ),
                ],
                const Spacer(),
                if (r != null && r.errorMessage == null) ...[
                  _StatChip(
                    icon: Icons.timer_rounded,
                    value: AppFormatters.duration(r.responseTime),
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.data_usage_rounded,
                    value: AppFormatters.fileSize(r.sizeBytes),
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.divider,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Content
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Body tab
                _buildBodyTab(r),
                // Headers tab
                _buildHeadersTab(r),
                // Preview tab
                _buildPreviewTab(r),
                // Raw tab
                _buildRawTab(r),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTab(ResponseModel? r) {
    if (widget.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoader(
            width: index % 2 == 0 ? double.infinity : MediaQuery.of(context).size.width * 0.6,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
    if (r == null) return const Center(child: Text('No response yet'));
    if (r.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.danger, size: 48),
              const SizedBox(height: 12),
              Text(r.errorMessage!, style: context.textStyles.body,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    String displayBody = r.body;
    String lang = 'json';

    // Try to pretty print JSON
    try {
      final decoded = jsonDecode(r.body);
      displayBody = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      lang = r.headers['content-type']?.contains('xml') == true ? 'xml' : 'text';
    }

    if (displayBody.isEmpty) {
      return const Center(child: Text('Empty response body'));
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CodeDisplay(
              code: displayBody,
              language: lang,
              showLineNumbers: true,
              showCopyButton: false,
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: CopyButton(text: displayBody),
        ),
      ],
    );
  }

  Widget _buildHeadersTab(ResponseModel? r) {
    if (r == null || r.headers.isEmpty) {
      return const Center(child: Text('No headers'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: r.headers.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (_, i) {
        final entry = r.headers.entries.elementAt(i);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(entry.key,
                    style: context.textStyles.codeSmall
                        .copyWith(color: AppColors.syntaxKey)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(entry.value,
                    style: context.textStyles.codeSmall
                        .copyWith(color: context.adaptiveTextSecondary)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRawTab(ResponseModel? r) {
    final raw = r?.body ?? '';
    if (raw.isEmpty) return const Center(child: Text('No response'));
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(raw, style: context.textStyles.codeSmall),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CopyButton(text: raw),
        ),
      ],
    );
  }

  Widget _buildPreviewTab(ResponseModel? r) {
    if (r == null || r.body.isEmpty) {
      return const Center(child: Text('No response to preview'));
    }

    final contentType = r.headers['content-type'] ?? '';
    final isHtml = contentType.contains('text/html') ||
        r.body.trimLeft().startsWith('<');

    if (isHtml) {
      // Real HTML rendering via flutter_widget_from_html_core
      return Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: HtmlWidget(
            r.body,
            textStyle: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    // For JSON / plain text — show a formatted preview
    final isJson = contentType.contains('json') ||
        r.body.trimLeft().startsWith('{') ||
        r.body.trimLeft().startsWith('[');

    if (isJson) {
      String pretty = r.body;
      try {
        final decoded = json.decode(r.body);
        pretty = const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {}
      return Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              pretty,
              style: context.textStyles.codeSmall.copyWith(
                color: const Color(0xFF98C379), // green for JSON
              ),
            ),
          ),
          Positioned(top: 8, right: 8, child: CopyButton(text: pretty)),
        ],
      );
    }

    // Fallback for plain text / XML
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            r.body,
            style: context.textStyles.codeSmall,
          ),
        ),
        Positioned(top: 8, right: 8, child: CopyButton(text: r.body)),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textStyles.codeSmall.copyWith(
            color: context.adaptiveTextSecondary,
          ),
        ),
      ],
    );
  }
}

