import 'package:flutter/material.dart';

/// Colours for Vishwa Radio, keyed to the vishwaradio.lk logo: orbit blue
/// #2469B4 (the ring) and signal red #E51A26 (the waveform). The backgrounds
/// run blue-glow → deep blue → near-black so the mark sits in its own palette
/// rather than on flat grey.
class AppColors {
  AppColors._();

  /// Sampled straight from assets/vishwa-radio.webp.
  static const orbit = Color(0xFF2469B4);
  static const signal = Color(0xFFE51A26);

  /// The globe's land masses. 2% of the mark, and it stays 2% of the app:
  /// the "on air" dot, nothing else.
  static const leaf = Color(0xFF7CBC44);

  static const orbitLight = Color(0xFF3B82CE);
  static const liveRed = Color(0xFFE51A26);
  static const tickerText = Color(0xFFCFE2F5);

  /// Play button fill. Deliberately signal red, and deliberately not the bone
  /// the reference app used: there gold was the field, so a second gold mass
  /// would have out-shouted the crest. Here blue is the field and red is
  /// already the scarce colour, so the play button should be the loudest
  /// thing on the screen.
  static const playButtonFill = signal;

  static const bgDeep = Color(0xFF070D12);
  static const bgDark = Color(0xFF0A1724);
  static const bgMid = Color(0xFF0F253E);
  static const bgWarm = Color(0xFF11375F);
  static const bgRadioWarm = Color(0xFF17497C);
  static const bgGlowBlue = Color(0xFF1A4B7F);
  static const bgSplashMid = Color(0xFF0D2947);
  static const bgSplashWarm = Color(0xFF15406C);

  static const tickerStart = Color(0xFF11375F);
  static const tickerEnd = Color(0xFF2469B4);

  static const coverArtBase = Color(0xFF0F253E);
  static const coverArtStripe = Color(0xFF173351);

  static const buttonGradient = [orbitLight, orbit];

  static Color whiteAlpha(double opacity) =>
      Colors.white.withValues(alpha: opacity);
  static Color orbitAlpha(double opacity) => orbit.withValues(alpha: opacity);
}
