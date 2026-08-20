import 'dart:async';

import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _navigateTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.radio);
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  double _dotOpacity(double t) {
    const rise = 0.4 / 1.2;
    const fall = 0.8 / 1.2;
    if (t < rise) return 0.25 + 0.75 * (t / rise);
    if (t < fall) return 1.0 - 0.75 * ((t - rise) / (fall - rise));
    return 0.25;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splashBackground),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) => _PulseRing(progress: _pulseController.value),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) => _PulseRing(progress: (_pulseController.value + 0.5) % 1.0),
                      ),
                      Image.asset(
                        'assets/woodrose-logo-light.png',
                        width: 132,
                        height: 132,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                Image.asset('assets/vishwa-radio-light.png', height: 110),
                const SizedBox(height: 26),
                Text(
                  'WOODROSE FOUNDATION',
                  style: AppText.mono(size: 11, weight: FontWeight.w700, color: AppColors.orbit, letterSpacing: 3),
                ),
                const SizedBox(height: 56),
                AnimatedBuilder(
                  animation: _dotsController,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final t = (_dotsController.value + i * (0.2 / 1.2)) % 1.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Opacity(
                            opacity: _dotOpacity(t),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.orbit),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double progress;

  const _PulseRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 + progress * 0.9;
    final opacity = (1 - progress).clamp(0.0, 1.0) * 0.55;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.orbit, width: 1),
          ),
        ),
      ),
    );
  }
}
