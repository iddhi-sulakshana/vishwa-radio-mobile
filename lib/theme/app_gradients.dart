import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Background and accent gradients. The geometry is carried over unchanged;
/// only the colours are Vishwa's.
class AppGradients {
  AppGradients._();

  // The warm end of both backgrounds runs blue-glow → deep blue so the field echoes
  // the logo's own ring colour before falling away to near-black.
  static const splashBackground = RadialGradient(
    center: Alignment(0, -1.3),
    radius: 1.35,
    colors: [
      AppColors.bgGlowBlue,
      AppColors.bgSplashWarm,
      AppColors.bgSplashMid,
      AppColors.bgDark,
      AppColors.bgDeep,
    ],
    stops: [0.0, 0.2, 0.45, 0.78, 1.0],
  );

  static const radioBackground = RadialGradient(
    center: Alignment(0, -0.8),
    radius: 1.5,
    colors: [
      AppColors.bgGlowBlue,
      AppColors.bgRadioWarm,
      AppColors.bgWarm,
      AppColors.bgDark,
      AppColors.bgDeep,
    ],
    stops: [0.0, 0.22, 0.5, 0.8, 1.0],
  );

  /// Shared background for the Timetable / Podcasts / Livestreams / About /
  /// Contact screens.
  static const section = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgMid, AppColors.bgDark, AppColors.bgDeep],
    stops: [0.0, 0.3, 1.0],
  );

  static const drawerPanel = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgMid, AppColors.bgDark, AppColors.bgDeep],
    stops: [0.0, 0.6, 1.0],
  );

  static const button = LinearGradient(
    begin: Alignment(-0.6, -1),
    end: Alignment(0.6, 1),
    colors: AppColors.buttonGradient,
  );

  static final navActive = LinearGradient(
    begin: const Alignment(-0.6, -1),
    end: const Alignment(0.6, 1),
    colors: [
      AppColors.orbitLight.withValues(alpha: 0.22),
      AppColors.orbit.withValues(alpha: 0.22),
    ],
  );

  static final scheduleLive = LinearGradient(
    begin: const Alignment(-0.6, -1),
    end: const Alignment(0.6, 1),
    colors: [
      AppColors.orbitLight.withValues(alpha: 0.14),
      AppColors.orbit.withValues(alpha: 0.10),
    ],
  );

  static const ticker = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.tickerStart, AppColors.tickerEnd],
  );
}
