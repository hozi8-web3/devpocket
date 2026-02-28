import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/copy_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/code_display.dart';
import '../../core/utils/formatters.dart';
import 'services/jwt_service.dart';

class JwtScreen extends StatefulWidget {
  const JwtScreen({super.key});

  @override
  State<JwtScreen> createState() => _JwtScreenState();
}

class _JwtScreenState extends State<JwtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tokenController = TextEditingController();
  final _secretController = TextEditingController();
  final _payloadController = TextEditingController(
    text: '{\n  "sub": "1234567890",\n  "name": "John Doe",\n  "admin": true\n}',
  );
  final _genSecretController = TextEditingController(text: 'your-secret-key');

  JwtDecodeResult? _result;
  bool? _signatureValid;
  String? _generatedToken;
  String? _error;
  String _genAlgo = 'HS256';
  int _expiryHours = 24;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tokenController.dispose();
    _secretController.dispose();
    _payloadController.dispose();
    _genSecretController.dispose();
    super.dispose();
  }

  void _decode() {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    final result = JwtService.decode(token);
    setState(() {
      _result = result;
      _error = result == null ? 'Invalid JWT token format' : null;
      _signatureValid = null;
    });
  }

  void _verify() {
    if (_result == null) return;
    final valid = JwtService.verifyHmacSignature(
      _tokenController.text.trim(),
      _secretController.text,
      _result!.algorithm,
    );
    setState(() => _signatureValid = valid);
  }

  void _generate() {
    try {
      Map<String, dynamic> payload;
      payload = jsonDecode(_payloadController.text) as Map<String, dynamic>;

      final token = JwtService.generate(
        payload: payload,
        secret: _genSecretController.text,
        algorithm: _genAlgo,
        expiryHours: _expiryHours,
      );
      setState(() => _generatedToken = token);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid JSON payload: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: 'hero-jwt',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        title: Text('JWT Decoder', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Decode'), Tab(text: 'Generate')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDecodeTab(), _buildGenerateTab()],
      ),
    );
  }

  Widget _buildDecodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Token input
          TextField(
            controller: _tokenController,
            maxLines: 4,
            style: AppTextStyles.codeSmall,
            decoration: const InputDecoration(
              hintText: 'Paste JWT token here...',
              alignLabelWithHint: true,
            ),
            onChanged: (_) {
              if (_tokenController.text.contains('.')) _decode();
            },
          ),
          const SizedBox(height: 12),

          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                const SizedBox(width: 8),
                Text(_error!, style: AppTextStyles.body.copyWith(color: AppColors.danger)),
              ]),
            ),

          if (_result != null) ...[
            // Status row
            Row(
              children: [
                _result!.isExpired
                    ? const StatusBadge(label: 'EXPIRED', type: StatusBadgeType.error, showDot: true)
                    : const StatusBadge(label: 'VALID', type: StatusBadgeType.success, showDot: true),
                const SizedBox(width: 12),
                StatusBadge(
                  label: _result!.algorithm,
                  type: StatusBadgeType.info,
                ),
                const SizedBox(width: 12),
                StatusBadge(
                  label: _result!.type,
                  type: StatusBadgeType.neutral,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expiry info
            if (_result!.expiry != null)
              _InfoRow(
                label: 'Expires',
                value: _result!.isExpired
                    ? 'EXPIRED (${AppFormatters.dateTime(_result!.expiry!)})'
                    : 'In ${_formatDuration(_result!.timeRemaining!)} (${AppFormatters.dateTime(_result!.expiry!)})',
                valueColor: _result!.isExpired ? AppColors.danger : AppColors.success,
              ),
            if (_result!.issuedAt != null)
              _InfoRow(
                label: 'Issued At',
                value: AppFormatters.dateTime(_result!.issuedAt!),
              ),
            if (_result!.notBefore != null)
              _InfoRow(
                label: 'Not Before',
                value: AppFormatters.dateTime(_result!.notBefore!),
              ),

            const SizedBox(height: 16),

            // Header
            const SectionHeader(title: 'Header'),
            const SizedBox(height: 8),
            _CodeCard(
              code: JwtService.prettyJson(_result!.header),
              label: 'Header',
            ),
            const SizedBox(height: 12),

            // Payload
            const SectionHeader(title: 'Payload'),
            const SizedBox(height: 8),
            _CodeCard(
              code: JwtService.prettyJson(_result!.payload),
              label: 'Payload',
            ),
            const SizedBox(height: 16),

            // Signature verification
            const SectionHeader(title: 'Verify Signature'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _secretController,
                    decoration: const InputDecoration(
                      hintText: 'Enter secret key...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _verify,
                  child: const Text('Verify'),
                ),
              ],
            ),
            if (_signatureValid != null) ...[
              const SizedBox(height: 8),
              StatusBadge(
                label: _signatureValid! ? 'Signature Valid ✓' : 'Signature Invalid ✗',
                type: _signatureValid! ? StatusBadgeType.success : StatusBadgeType.error,
                showDot: true,
              ),
            ],
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Payload (JSON)'),
          const SizedBox(height: 8),
          TextField(
            controller: _payloadController,
            maxLines: 6,
            style: AppTextStyles.code,
            decoration: const InputDecoration(
              hintText: '{\n  "sub": "123",\n  "name": "John"\n}',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          const SectionHeader(title: 'Secret Key'),
          const SizedBox(height: 8),
          TextField(
            controller: _genSecretController,
            style: AppTextStyles.code,
            decoration: const InputDecoration(hintText: 'your-secret-key'),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Algorithm:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              ...['HS256', 'HS384', 'HS512'].map((a) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(a),
                  selected: _genAlgo == a,
                  onSelected: (_) => setState(() => _genAlgo = a),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: _genAlgo == a ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Text('Expiry (hours):', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _expiryHours.toDouble(),
                  min: 1,
                  max: 168,
                  divisions: 167,
                  label: '${_expiryHours}h',
                  onChanged: (v) => setState(() => _expiryHours = v.round()),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text('${_expiryHours}h',
                    style: AppTextStyles.code, textAlign: TextAlign.right),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              label: const Text('Generate JWT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          if (_generatedToken != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.codeBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.adaptiveCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Generated Token', style: AppTextStyles.label),
                      CopyButton(text: _generatedToken!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _generatedToken!,
                    style: AppTextStyles.codeSmall,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.codeSmall.copyWith(
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String code;
  final String label;

  const _CodeCard({required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.adaptiveCardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 10),
                child: Text(label, style: AppTextStyles.label.copyWith(color: AppColors.primary)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: CopyButton(text: code),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: CodeDisplay(code: code, language: 'json', showCopyButton: false),
          ),
        ],
      ),
    );
  }
}
