import 'package:flutter_test/flutter_test.dart';
import 'package:vishwa_radio/models/site_settings.dart';

void main() {
  test('defaults match the values already live on the website', () {
    final settings = SiteSettings.defaults();

    expect(settings.contact.email, 'woodrose@gmail.com');
    expect(settings.contact.phone, '+94 81 238 7854 / +94 77 532 2253');
    expect(
      settings.livestreamUrl,
      'https://carina.streamerr.co/stream/vishwaradio/stream',
    );
    expect(settings.social.facebook, isNotEmpty);
    expect(settings.social.instagram, isEmpty);
  });

  test('defaults are off air — a video stream is the exception, not the rule',
      () {
    expect(SiteSettings.defaults().youtubeLive.enabled, isFalse);
  });

  test('SocialLinks.configured only lists non-empty platforms, in order', () {
    const social = SocialLinks(
      facebook: 'https://fb.example',
      instagram: '',
      youtube: 'https://yt.example',
      whatsapp: '',
      tiktok: '',
    );

    expect(social.configured, [
      ('Facebook', 'https://fb.example'),
      ('YouTube', 'https://yt.example'),
    ]);
  });

  group('YoutubeLive.canEmbed', () {
    test('is true for a live broadcast with a video id', () {
      const live = YoutubeLive(
        enabled: true,
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
        videoId: 'dQw4w9WgXcQ',
      );

      expect(live.canEmbed, isTrue);
    });

    test('is false without a video id, so a channel link opens YouTube instead',
        () {
      const live = YoutubeLive(
        enabled: true,
        url: 'https://www.youtube.com/channel/UC123/live',
        embedUrl: 'https://www.youtube.com/embed/live_stream?channel=UC123',
        videoId: '',
      );

      expect(live.canEmbed, isFalse);
    });

    test('is false when off air', () {
      expect(YoutubeLive.offAir.canEmbed, isFalse);
    });
  });

  group('BankDetails', () {
    test('is incomplete when nothing is set', () {
      expect(BankDetails.empty.isComplete, isFalse);
    });

    // A bank name with no account number cannot be paid into, and an account
    // number with no bank cannot be found. Showing a half-filled panel invites
    // a failed transfer.
    test('needs both a name and an account number', () {
      const nameOnly = BankDetails(
        name: 'Commercial Bank',
        accountName: '',
        accountNumber: '',
        branch: '',
        swift: '',
      );
      const numberOnly = BankDetails(
        name: '',
        accountName: '',
        accountNumber: '1234567890',
        branch: '',
        swift: '',
      );
      expect(nameOnly.isComplete, isFalse);
      expect(numberOnly.isComplete, isFalse);
    });

    test('is complete once both are set', () {
      const both = BankDetails(
        name: 'Commercial Bank',
        accountName: '',
        accountNumber: '1234567890',
        branch: '',
        swift: '',
      );
      expect(both.isComplete, isTrue);
    });

    test('ignores whitespace-only values', () {
      const blank = BankDetails(
        name: '   ',
        accountName: '',
        accountNumber: '  ',
        branch: '',
        swift: '',
      );
      expect(blank.isComplete, isFalse);
    });

    test('rows lists only the fields that are set, in order', () {
      const bank = BankDetails(
        name: 'Commercial Bank',
        accountName: '',
        accountNumber: '1234567890',
        branch: 'Peradeniya',
        swift: '',
      );
      expect(bank.rows, [
        ('Bank', 'Commercial Bank'),
        ('Account number', '1234567890'),
        ('Branch', 'Peradeniya'),
      ]);
    });
  });
}
