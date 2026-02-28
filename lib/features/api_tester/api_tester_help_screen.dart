import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/frosted_glass.dart';
import '../../core/widgets/section_header.dart';

class ApiTesterHelpScreen extends StatelessWidget {
  const ApiTesterHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('API Tester Pro Guide', style: context.textStyles.heading2),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.api_rounded,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildIntro(context),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Advanced Features'),
                const SizedBox(height: 16),
                _buildFeatureTile(
                  context,
                  icon: Icons.hub_rounded,
                  title: 'Environment Variables',
                  description: 'Use placeholders like {{baseUrl}} in headers, URLs, or body. Switch between Dev, Staging, and Prod via the toolbar selector.',
                  color: AppColors.primary,
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.play_circle_filled_rounded,
                  title: 'Collection Runner',
                  description: 'Run entire API collections sequentially with one tap. Perfect for integration testing or bulk migrations.',
                  color: AppColors.success,
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.file_download_rounded,
                  title: 'Postman Import',
                  description: 'Import Postman v2.1 collections directly from the Collections Drawer. Nested folders are automatically flattened for focus.',
                  color: AppColors.info,
                ),
                _buildFeatureTile(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Auto History',
                  description: 'Every request you send is automatically saved to history. Replay any past request with a single tap.',
                  color: AppColors.warning,
                ),
                const SizedBox(height: 32),
                _buildProTip(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.adaptiveCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.adaptiveCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modern API Development', style: context.textStyles.heading3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(
            'DevPocket API Tester is a professional-grade tool designed for speed and flexibility. Whether you are debugging local endpoints or running cloud migrations, we have got you covered.',
            style: context.textStyles.body.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.adaptiveGlassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.adaptiveGlassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textStyles.bodyBold),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: context.textStyles.caption.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'PRO TIP: Swipe from the right edge to open your Collections at any time.',
              style: context.textStyles.labelSmall.copyWith(color: context.adaptiveTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
