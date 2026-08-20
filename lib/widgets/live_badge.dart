import 'package:flutter/material.dart';

import '../services/now_playing_controller.dart';
import '../services/radio_player_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'pulsing_opacity.dart';

/// The small pulsing red dot used inside every "LIVE" / "ON AIR" indicator.
class LiveDot extends StatelessWidget {
  final double size;

  const LiveDot({super.key, this.size = 7});

  @override
  Widget build(BuildContext context) {
    return PulsingOpacity(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.liveRed),
      ),
    );
  }
}

/// The outlined pill shown in the Radio screen header.
///
/// Three states, in descending confidence. Playing on this device is the
/// strongest: "LIVE", pulsing. Failing that, the console's now-playing feed may
/// report the stream itself is up, which earns a steady "ON AIR" — true, but
/// not about this device, so no pulse. Otherwise "LIVE RADIO", which describes
/// the medium rather than claiming a broadcast is in progress.
///
/// The middle state is deliberately conservative: when the console cannot reach
/// Streamerr, `onAir` is false, so an outage reads as "LIVE RADIO" rather than
/// as the station being off.
class LivePill extends StatelessWidget {
  const LivePill({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        RadioPlayerController.instance,
        NowPlayingController.instance,
      ]),
      builder: (context, _) {
        final playing = RadioPlayerController.instance.isPlaying;
        final onAir = NowPlayingController.instance.current.onAir;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: AppColors.signalAlpha(
                    playing ? 0.4 : (onAir ? 0.3 : 0.18))),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (playing)
                const LiveDot()
              else
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.signalAlpha(onAir ? 0.6 : 0.35),
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                playing ? 'LIVE' : (onAir ? 'ON AIR' : 'LIVE RADIO'),
                style: AppText.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: playing
                        ? AppColors.signal
                        : AppColors.signalAlpha(onAir ? 0.8 : 0.55),
                    letterSpacing: 1.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
