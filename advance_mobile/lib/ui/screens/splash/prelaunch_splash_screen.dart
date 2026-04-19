import 'dart:async';

import 'package:flutter/material.dart';

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
  late final Animation<double> _contentFadeAnimation;
  late final Animation<double> _introScaleAnimation;
  late final Animation<double> _pulseScaleAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;

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
    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );

    _introController.forward();
    _pulseController.repeat(reverse: true);

    _navigationTimer = Timer(
      _splashDuration,
      _navigateToMain,
    );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _contentFadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _introController,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              _introScaleAnimation.value *
                              _pulseScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 138,
                        height: 138,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surface.withValues(alpha: 0.96),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.24),
                              blurRadius: 26,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_bike_rounded,
                          size: 72,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Bike Sharing App',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                      SlideTransition(
                        position: _subtitleSlideAnimation,
                        child: Text(
                          'Smart rides for every city block',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.72),
                          ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
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
    );
  }
}
