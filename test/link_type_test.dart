import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_app/models/link_type.dart';

void main() {
  group('fromUrl', () {
    test('detects the type from the saved scheme', () {
      expect(LinkType.fromUrl('https://flutter.dev'), LinkType.link);
      expect(LinkType.fromUrl('www.flutter.dev'), LinkType.link);
      expect(LinkType.fromUrl('mailto:me@example.com'), LinkType.email);
      expect(LinkType.fromUrl('MAILTO:me@example.com'), LinkType.email);
      expect(LinkType.fromUrl('tel:+15551234567'), LinkType.phone);
    });
  });

  group('toUrl and displayValue', () {
    test('link is kept as typed, without a doubled https prefix', () {
      expect(
        LinkType.link.toUrl('https://https://dart.dev'),
        'https://dart.dev',
      );
      expect(
        LinkType.link.displayValue('https://dart.dev'),
        'https://dart.dev',
      );
    });

    test('email gets a mailto prefix', () {
      expect(LinkType.email.toUrl(' me@example.com '), 'mailto:me@example.com');
      expect(
        LinkType.email.displayValue('mailto:me@example.com'),
        'me@example.com',
      );
    });

    test('phone gets a tel prefix and drops separators', () {
      expect(LinkType.phone.toUrl('+1 (555) 123-4567'), 'tel:+15551234567');
      expect(LinkType.phone.displayValue('tel:+15551234567'), '+15551234567');
    });

    test('round-trips through the edit field', () {
      for (final url in [
        'https://flutter.dev',
        'mailto:me@example.com',
        'tel:+15551234567',
      ]) {
        final type = LinkType.fromUrl(url);
        expect(type.toUrl(type.displayValue(url)), url);
      }
    });
  });

  group('validate', () {
    test('link keeps the existing rules', () {
      expect(LinkType.link.validate(''), 'Enter url');
      expect(
        LinkType.link.validate('nope'),
        contains('Enter link in correct way'),
      );
      expect(LinkType.link.validate('https://flutter.dev'), isNull);
    });

    test('email', () {
      expect(LinkType.email.validate(''), 'Enter email');
      expect(
        LinkType.email.validate('me@example'),
        contains('Enter email in correct way'),
      );
      expect(LinkType.email.validate('me example@x.com'), isNotNull);
      expect(LinkType.email.validate('me@example.com'), isNull);
    });

    test('phone', () {
      expect(LinkType.phone.validate(''), 'Enter phone number');
      expect(
        LinkType.phone.validate('12'),
        contains('Enter phone number in correct way'),
      );
      expect(LinkType.phone.validate('call me'), isNotNull);
      expect(LinkType.phone.validate('+1 (555) 123-4567'), isNull);
      expect(LinkType.phone.validate('112'), isNull);
    });
  });
}
