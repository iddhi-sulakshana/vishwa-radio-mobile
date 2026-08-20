/// The station's real livestream URL — the single source of truth shared by
/// [SiteSettings.defaults] and the radio player's fallback, so the two can
/// never drift apart the way the old hardcoded duplicate constants did.
const kDefaultLivestreamUrl =
    'https://carina.streamerr.co/stream/vishwaradio/stream';

class ContactInfo {
  final String address;
  final String phone;
  final String email;

  const ContactInfo({
    required this.address,
    required this.phone,
    required this.email,
  });
}

class SocialLinks {
  final String facebook;
  final String instagram;
  final String youtube;
  final String whatsapp;
  final String tiktok;

  const SocialLinks({
    required this.facebook,
    required this.instagram,
    required this.youtube,
    required this.whatsapp,
    required this.tiktok,
  });

  /// The (platform label, url) pairs that are actually configured, in the
  /// order the app shows them — mirrors the website's `useSocialLinks()`.
  List<(String, String)> get configured => [
    if (facebook.isNotEmpty) ('Facebook', facebook),
    if (instagram.isNotEmpty) ('Instagram', instagram),
    if (youtube.isNotEmpty) ('YouTube', youtube),
    if (whatsapp.isNotEmpty) ('WhatsApp', whatsapp),
    if (tiktok.isNotEmpty) ('TikTok', tiktok),
  ];
}

/// The occasional video broadcast, as the admin console publishes it.
///
/// The console parses the YouTube link and sends finished values, so the app
/// never has to tell a `youtu.be` link from a `/live/` permalink. When
/// [enabled] is false the rest is blank.
class YoutubeLive {
  final bool enabled;

  /// Canonical watch link — where "Watch on YouTube" goes.
  final String url;

  /// iframe `src`. The website uses this; the app plays by [videoId] instead.
  final String embedUrl;

  /// Empty when the link points at a channel's live page rather than one
  /// broadcast, because that form carries no video id to play.
  final String videoId;

  const YoutubeLive({
    required this.enabled,
    required this.url,
    required this.embedUrl,
    required this.videoId,
  });

  static const offAir = YoutubeLive(
    enabled: false,
    url: '',
    embedUrl: '',
    videoId: '',
  );

  /// Whether the in-app player can carry this one. When false and [enabled]
  /// is true, the screen shows the live badge and links out to YouTube.
  bool get canEmbed => enabled && videoId.isNotEmpty;
}

class SiteSettings {
  final ContactInfo contact;
  final String mapEmbedUrl;
  final String mapLinkUrl;
  final String livestreamUrl;
  final YoutubeLive youtubeLive;
  final SocialLinks social;

  /// Donation details for the donate screen.
  final DonateSettings donate;

  const SiteSettings({
    required this.contact,
    required this.mapEmbedUrl,
    required this.mapLinkUrl,
    required this.livestreamUrl,
    required this.youtubeLive,
    required this.social,
    required this.donate,
  });

  /// What the app shows before anything has been fetched — today's real
  /// values, not blanks, so a first launch with no network still looks
  /// correct. Mirrors the seed values in the console's 0002 migration.
  static SiteSettings defaults() => const SiteSettings(
    contact: ContactInfo(
      address: '238/2/7, Megodakalugamuwa, Peradeniya, Sri Lanka',
      phone: '+94 81 238 7854 / +94 77 532 2253',
      email: 'woodrose@gmail.com',
    ),
    mapEmbedUrl: '',
    mapLinkUrl: '',
    livestreamUrl: kDefaultLivestreamUrl,
    // Off air until the console says otherwise — a video broadcast is the
    // exception, and guessing "live" would show a badge over an empty frame.
    youtubeLive: YoutubeLive.offAir,
    social: SocialLinks(
      facebook: 'https://www.facebook.com/profile.php?id=61564523367836',
      instagram: '',
      youtube: '',
      whatsapp: '',
      tiktok: '',
    ),
    // Empty rather than invented: the console seeds these blank too, because
    // publishing placeholder bank details is worse than publishing none.
    donate: DonateSettings.empty,
  );
}

/// Bank transfer details, as the admin console publishes them.
class BankDetails {
  final String name;
  final String accountName;
  final String accountNumber;
  final String branch;
  final String swift;

  const BankDetails({
    required this.name,
    required this.accountName,
    required this.accountNumber,
    required this.branch,
    required this.swift,
  });

  static const empty = BankDetails(
    name: '',
    accountName: '',
    accountNumber: '',
    branch: '',
    swift: '',
  );

  /// Whether there is enough here to make a transfer. A bank name with no
  /// account number cannot be paid into, and an account number with no bank
  /// cannot be found — a half-filled panel invites a failed transfer, so it
  /// counts as unset. Branch and SWIFT are genuinely optional. Mirrors
  /// `hasBankDetails()` in the console.
  bool get isComplete =>
      name.trim().isNotEmpty && accountNumber.trim().isNotEmpty;

  /// The (label, value) pairs that are actually set, in display order.
  List<(String, String)> get rows => [
    if (name.trim().isNotEmpty) ('Bank', name),
    if (accountName.trim().isNotEmpty) ('Account name', accountName),
    if (accountNumber.trim().isNotEmpty) ('Account number', accountNumber),
    if (branch.trim().isNotEmpty) ('Branch', branch),
    if (swift.trim().isNotEmpty) ('SWIFT code', swift),
  ];
}

/// What the donate screen shows.
class DonateSettings {
  final String intro;

  /// External donation link. Empty hides the button.
  final String linkUrl;

  final BankDetails bank;

  const DonateSettings({
    required this.intro,
    required this.linkUrl,
    required this.bank,
  });

  static const empty = DonateSettings(
    intro: '',
    linkUrl: '',
    bank: BankDetails.empty,
  );
}
