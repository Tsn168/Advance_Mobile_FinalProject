import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PrelaunchSplashScreen extends StatefulWidget {
  const PrelaunchSplashScreen({super.key, required this.nextScreen});

  final Widget nextScreen;

  @override
  State<PrelaunchSplashScreen> createState() => _PrelaunchSplashScreenState();
}

class _PrelaunchSplashScreenState extends State<PrelaunchSplashScreen>
    with TickerProviderStateMixin {
  static const Duration _splashDuration = Duration(milliseconds: 2400);

  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final AnimationController _ambientController;
  late final Animation<double> _contentFadeAnimation;
  late final Animation<double> _introScaleAnimation;
  late final Animation<double> _pulseScaleAnimation;
  late final Animation<double> _titleOpacityAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _subtitleOpacityAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;
  late final Animation<double> _pillsOpacityAnimation;
  late final Animation<Offset> _pillsSlideAnimation;
  late final Animation<double> _loadingOpacityAnimation;
  late final Animation<double> _loadingScaleAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _contentFadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );
    _introScaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _titleOpacityAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.12, 0.55, curve: Curves.easeOut),
    );
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleOpacityAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.82, curve: Curves.easeOut),
    );
    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );
    _pillsOpacityAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _pillsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.52, 1.0, curve: Curves.easeOutBack),
          ),
        );
    _loadingOpacityAnimation = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
    );
    _loadingScaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.72, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _introController.forward();
    _pulseController.repeat(reverse: true);
    _ambientController.repeat(reverse: true);

    _navigationTimer = Timer(_splashDuration, _navigateToMain);
  }

  void _navigateToMain() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _pulseController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isCompact = size.width < 370;
    final double horizontalPadding = size.width >= 760
        ? size.width * 0.24
        : AppSpacing.xxl;
    final double cardPadding = isCompact ? AppSpacing.lg : AppSpacing.xl;
    final double badgeSize = isCompact ? 114 : 138;
    final double iconSize = isCompact ? 58 : 70;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AnimatedBackgroundShape(
              alignment: Alignment.topLeft,
              size: 260,
              color: AppColors.primaryLight,
              opacity: 0.18,
              animation: _ambientController,
              offsetX: 14,
              offsetY: 10,
              scaleRange: 0.06,
              rotationRange: 0.08,
              phaseShift: 0.0,
            ),
            _AnimatedBackgroundShape(
              alignment: Alignment.bottomRight,
              size: 300,
              color: AppColors.accent,
              opacity: 0.14,
              animation: _ambientController,
              offsetX: -16,
              offsetY: 12,
              scaleRange: 0.08,
              rotationRange: -0.06,
              phaseShift: 0.35,
            ),
            _AnimatedBackgroundShape(
              alignment: Alignment(-0.85, 0.65),
              size: 160,
              color: AppColors.primary,
              opacity: 0.1,
              animation: _ambientController,
              offsetX: 9,
              offsetY: -8,
              scaleRange: 0.05,
              rotationRange: 0.05,
              phaseShift: 0.58,
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: AnimatedBuilder(
                      animation: _ambientController,
                      builder: (context, child) {
                        final double wave = math.sin(
                          _ambientController.value * 2 * math.pi,
                        );
                        return Transform.translate(
                          offset: Offset(0, -4 * wave),
                          child: child,
                        );
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Container(
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLarge + AppSpacing.md,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.white.withValues(alpha: 0.95),
                                AppColors.white.withValues(alpha: 0.86),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 40,
                                spreadRadius: 1,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _introController,
                                  _pulseController,
                                  _ambientController,
                                ]),
                                builder: (context, child) {
                                  final double wave = math.sin(
                                    _ambientController.value * 2 * math.pi,
                                  );
                                  final double tilt = 0.045 * wave;
                                  return Transform.translate(
                                    offset: Offset(0, -4.5 * wave),
                                    child: Transform.rotate(
                                      angle: tilt,
                                      child: Transform.scale(
                                        scale:
                                            _introScaleAnimation.value *
                                            _pulseScaleAnimation.value,
                                        child: _SplashBikeBadge(
                                          size: badgeSize,
                                          iconSize: iconSize,
                                          ringOpacity:
                                              0.18 + (0.16 * (wave + 1) / 2),
                                          glowStrength:
                                              (_pulseScaleAnimation.value - 1) *
                                              28,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              SlideTransition(
                                position: _titleSlideAnimation,
                                child: FadeTransition(
                                  opacity: _titleOpacityAnimation,
                                  child: Text(
                                    'Bike Sharing App',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.h3.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              FadeTransition(
                                opacity: _subtitleOpacityAnimation,
                                child: SlideTransition(
                                  position: _subtitleSlideAnimation,
                                  child: Text(
                                    'Smart rides for every city block',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              FadeTransition(
                                opacity: _pillsOpacityAnimation,
                                child: SlideTransition(
                                  position: _pillsSlideAnimation,
                                  child: const _ValuePills(),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              FadeTransition(
                                opacity: _loadingOpacityAnimation,
                                child: ScaleTransition(
                                  scale: _loadingScaleAnimation,
                                  child: Column(
                                    children: [
                                      AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          final double glowBlur =
                                              8 +
                                              ((_pulseScaleAnimation.value -
                                                      1) *
                                                  240);
                                          return Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: glowBlur,
                                                  spreadRadius: 0.7,
                                                ),
                                              ],
                                            ),
                                            child: child,
                                          );
                                        },
                                        child: const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.6,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      _LoadingCaption(
                                        animation: _ambientController,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBackgroundShape extends StatelessWidget {
  const _AnimatedBackgroundShape({
    required this.alignment,
    required this.size,
    required this.color,
    required this.opacity,
    required this.animation,
    required this.offsetX,
    required this.offsetY,
    required this.scaleRange,
    required this.rotationRange,
    required this.phaseShift,
  });

  final Alignment alignment;
  final double size;
  final Color color;
  final double opacity;
  final Animation<double> animation;
  final double offsetX;
  final double offsetY;
  final double scaleRange;
  final double rotationRange;
  final double phaseShift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double phase = (animation.value + phaseShift) * 2 * math.pi;
        final double wave = math.sin(phase);
        final double waveY = math.cos(phase);
        final double scale = 1 + (scaleRange * wave * 0.5);

        return IgnorePointer(
          child: Align(
            alignment: alignment,
            child: Transform.translate(
              offset: Offset(offsetX * wave, offsetY * waveY),
              child: Transform.rotate(
                angle: rotationRange * wave,
                child: Transform.scale(scale: scale, child: child),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _SplashBikeBadge extends StatelessWidget {
  const _SplashBikeBadge({
    required this.size,
    required this.iconSize,
    required this.ringOpacity,
    required this.glowStrength,
  });

  final double size;
  final double iconSize;
  final double ringOpacity;
  final double glowStrength;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bike sharing logo',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + AppSpacing.xl,
            height: size + AppSpacing.xl,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8 + glowStrength,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Container(
            width: size + AppSpacing.lg,
            height: size + AppSpacing.lg,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: ringOpacity),
                width: 2,
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.2,
            right: size * 0.18,
            child: Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          Icon(
            Icons.directions_bike_rounded,
            size: iconSize,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class _LoadingCaption extends StatelessWidget {
  const _LoadingCaption({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final int dots = ((animation.value * 10) % 4).floor();
        final String suffix = List.filled(dots, '.').join();
        return Text(
          'Preparing your ride$suffix',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        );
      },
    );
  }
}

class _ValuePills extends StatelessWidget {
  const _ValuePills();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: const [
        _ValuePill(icon: Icons.eco_rounded, label: 'Eco'),
        _ValuePill(icon: Icons.flash_on_rounded, label: 'Fast'),
        _ValuePill(icon: Icons.route_rounded, label: 'Smart'),
      ],
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSmall,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
