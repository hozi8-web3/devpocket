import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      if (mounted) context.go('/onboarding');
    } else {
      if (mounted) context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.5,
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Glowing Background Pulse
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: Opacity(
                    opacity: _fade.value * 0.6,
                    child: Transform.scale(
                      scale: 1.0 + (_scale.value * 0.5),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              blurRadius: 150,
                              spreadRadius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Main Content
                Opacity(
                  opacity: _fade.value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _fade.value)),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Premium Animated Logo Container
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/logo.png',
                                width: 120,
                                height: 120,
                                filterQuality: FilterQuality.high,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Brand Identity
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, AppColors.secondary],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'DevPocket',
                              style: context.textStyles.displayLarge.copyWith(
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'THE ULTIMATE TOOLKIT',
                              style: context.textStyles.label.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 3.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Sleek Progress Indicator
                          SizedBox(
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const LinearProgressIndicator(
                                minHeight: 4,
                                color: AppColors.primary,
                                backgroundColor: AppColors.card,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': '11 Offline Tools',
      'subtitle': 'API Testing, Generators, Regex, JWT, JSON processing and more — fully offline context.',
      'lottie': 'https://lottie.host/802613b5-3221-4ea6-a700-1c313a3038ce/oA3J27y3Z0.json', // Tools/Wrench animation
      'color': AppColors.primary,
    },
    {
      'title': 'Everything You Need',
      'subtitle': 'No more searching the web for random formatters or hash generators. Secure and private.',
      'lottie': 'https://lottie.host/17e23116-2810-4ea2-8b43-228741368b6c/vEvt6J4h0k.json', // Security/Lock animation
      'color': AppColors.secondary,
    },
    {
      'title': 'Server Monitoring',
      'subtitle': 'Keep track of your API uptimes directly from the app with historic logs.',
      'lottie': 'https://lottie.host/6ab64cc1-15b5-412e-9d29-c09e3e3fa910/k9O3Z22v6y.json', // Server/Network animation
      'color': AppColors.danger,
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: page['color'].withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: page['color'].withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Lottie.network(
                                page['lottie'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                animate: _currentPage == i,
                                repeat: true,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.rocket_launch_rounded, size: 80, color: page['color']);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'],
                          style: context.textStyles.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['subtitle'],
                          style: context.textStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == i ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: _currentPage == _pages.length - 1
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: context.textStyles.button.copyWith(
                          color: _currentPage == _pages.length - 1
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
