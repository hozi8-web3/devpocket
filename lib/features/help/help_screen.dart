import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/section_header.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            leading: Hero(
              tag: 'hero-help',
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('How to Use DevPocket', style: context.textStyles.heading2),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.15), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: const Alignment(0, -0.2),
                  child: Image.asset('assets/logo.png', width: 60, height: 60, filterQuality: FilterQuality.high),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.secondary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset('assets/logo.png', width: 28, height: 28, filterQuality: FilterQuality.high),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Welcome to DevPocket',
                                style: context.textStyles.heading2.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'DevPocket is your offline-first, all-in-one developer toolkit. Designed to bring essential utilities right to your fingertips with a premium, focused experience.',
                          style: context.textStyles.body.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'Core Tools & Features'),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.api_rounded,
                    color: AppColors.primary,
                    title: 'API Tester',
                    description: 'Send REST API requests easily. It supports Bearer, Basic, and API Key authentication. Use the Collections drawer (swipe from right) to save and organize your frequently used requests. Tap the History icon to replay past requests.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.monitor_heart_rounded,
                    color: AppColors.danger,
                    title: 'Server Monitor',
                    description: 'Track the uptime of your critical infrastructure. Add a server URL or IP, and the app will periodically ping it, showing response times and status history in beautiful sparkline charts.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.lock_open_rounded,
                    color: AppColors.secondary,
                    title: 'JWT Decoder & Generator',
                    description: 'Paste a JWT to instantly decode its payload, verify signatures, and check expiration. You can also generate fresh JWTs for testing by specifying your payload and secret.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.data_object_rounded,
                    color: const Color(0xFFF59E0B),
                    title: 'JSON Tools',
                    description: 'Format messy JSON, minify it for production, validate syntax, compare differences between two JSON objects, or use JsonPath to query specific nodes.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.network_check_rounded,
                    color: const Color(0xFF3B82F6),
                    title: 'Network Utilities',
                    description: 'Ping hosts, inspect DNS records, verify SSL certificates and expiration dates, examine HTTP security headers, and perform IP geolocation lookups.',
                  ),
                  _buildFeatureCard(
                    context: context,
                    icon: Icons.manage_search_rounded,
                    color: const Color(0xFF8B5CF6),
                    title: 'Regex Tester',
                    description: 'Test your regular expressions in real-time. Features syntax highlighting for matches, group extraction, and a library of common patterns to get you started quickly.',
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'Pro Tips'),
                  const SizedBox(height: 16),
                  _buildTipContent(
                    context: context,
                    icon: Icons.search_rounded,
                    text: 'Use the universal search bar on the Home screen to instantly filter and find the tool you need.',
                  ),
                  _buildTipContent(
                    context: context,
                    icon: Icons.dark_mode_rounded,
                    text: 'Head over to Settings to switch between Light, Dark, and AMOLED Dark themes for lower battery consumption on OLED displays.',
                  ),
                  _buildTipContent(
                    context: context,
                    icon: Icons.content_copy_rounded,
                    text: 'Most outputs and code blocks feature a quick-copy button. Tap it to instantly copy the result to your clipboard with haptic feedback.',
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Built with ♥ for Developers',
                      style: context.textStyles.caption.copyWith(
                        letterSpacing: 2,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.adaptiveCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.adaptiveCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.heading3),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: context.textStyles.body.copyWith(
                    color: context.adaptiveTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipContent({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.adaptiveTextSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.body.copyWith(
                color: context.adaptiveTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}