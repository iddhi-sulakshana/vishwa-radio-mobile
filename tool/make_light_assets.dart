// Generates the light-on-dark variants of the two logos, plus the launcher
// icon. Committed rather than run once by hand so the transform is
// reproducible and reviewable:
//
//   dart run tool/make_light_assets.dart
//
// Both source logos are drawn for light backgrounds — most of their opaque
// pixels are near-black text that vanishes on the app's near-black grounds.
// Only the low-saturation dark pixels are lifted; the saturated brand colours
// (red waveform, blue orbit, green globe, gold rose) are left exactly as they
// are, because recolouring those would be recolouring the brand.
import 'dart:io';

import 'package:image/image.dart' as img;

/// Above this luminance a pixel is already light enough to read on dark.
const _lightEnough = 0.72;

/// The saturation below which a pixel counts as ink rather than brand colour,
/// per image — because one number cannot serve both.
///
/// The Vishwa mark needs only its charcoal script and wordmark lifted, and its
/// globe green sits at 0.64; anything high enough to catch that green would
/// wash the globe out. The Woodrose emblem has no green to protect, and its
/// lettering is a saturated brown at 0.67 that is illegible on a near-black
/// ground, so it needs a threshold above that — but below the 0.88 of the gold
/// rose, which is a brand colour and already bright.
const _inkSaturation = <String, double>{
  'vishwa-radio': 0.30,
  'woodrose-logo': 0.72,
};

img.Image _lighten(img.Image src, double inkSaturation) {
  final out = img.Image.from(src);
  for (final p in out) {
    if (p.a < 8) continue;

    final r = p.r / 255, g = p.g / 255, b = p.b / 255;
    final maxC = [r, g, b].reduce((a, b) => a > b ? a : b);
    final minC = [r, g, b].reduce((a, b) => a < b ? a : b);
    final lum = 0.299 * r + 0.587 * g + 0.114 * b;
    final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;

    if (sat >= inkSaturation || lum >= _lightEnough) continue;

    // Ink: map onto a near-white that keeps a trace of the original hue so
    // the mark does not read as flat white-on-black.
    p.r = (235 + r * 20).clamp(0, 255).toInt();
    p.g = (235 + g * 20).clamp(0, 255).toInt();
    p.b = (238 + b * 17).clamp(0, 255).toInt();
  }
  return out;
}

/// Square canvas with the mark centred, on the deep blue ground, for the
/// launcher icon. iOS strips alpha, so the ground must be painted in.
///
/// Deliberately the mark only — the globe, orbit, VR and waveforms — with the
/// "vishwaradio.lk" wordmark cropped off. A launcher icon is rendered at 48dp,
/// where that wordmark is an unreadable smear that also forces the rest of the
/// lockup smaller to fit. Dropping it lets the recognisable part fill the tile.
img.Image _icon(img.Image logo, {int size = 1024}) {
  // The wordmark sits in the bottom quarter of the source lockup.
  final markOnly = img.copyCrop(
    logo,
    x: 0,
    y: 0,
    width: logo.width,
    height: (logo.height * 0.76).round(),
  );
  // Then trim the transparent margin so the mark itself sets the bounds.
  final trimmed = img.trim(markOnly, mode: img.TrimMode.transparent);

  final canvas = img.Image(width: size, height: size, numChannels: 4);
  img.fill(canvas, color: img.ColorRgb8(0x11, 0x37, 0x5F));

  // Fit inside 76% of the tile, on whichever axis binds — iOS and Android both
  // crop or mask the edges, so the mark must not run to them.
  final target = size * 0.76;
  final scale = target / (trimmed.width > trimmed.height ? trimmed.width : trimmed.height);
  final resized = img.copyResize(
    trimmed,
    width: (trimmed.width * scale).round(),
    height: (trimmed.height * scale).round(),
    interpolation: img.Interpolation.cubic,
  );

  img.compositeImage(
    canvas,
    resized,
    dstX: (size - resized.width) ~/ 2,
    dstY: (size - resized.height) ~/ 2,
  );
  return canvas;
}

void main() {
  for (final name in ['vishwa-radio', 'woodrose-logo']) {
    final bytes = File('assets/$name.webp').readAsBytesSync();
    final src = img.decodeWebP(bytes);
    if (src == null) {
      stderr.writeln('could not decode assets/$name.webp');
      exit(1);
    }
    final light = _lighten(src, _inkSaturation[name]!);
    File('assets/$name-light.png').writeAsBytesSync(img.encodePng(light));
    stdout.writeln('wrote assets/$name-light.png (${light.width}x${light.height})');
  }

  final logo =
      img.decodePng(File('assets/vishwa-radio-light.png').readAsBytesSync())!;
  File('assets/icon/1024.png').writeAsBytesSync(img.encodePng(_icon(logo)));
  stdout.writeln('wrote assets/icon/1024.png (1024x1024)');
}
