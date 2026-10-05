import 'package:flutter/services.dart';

/// What kind of target an [Item] url points to. Email and phone items are
/// stored as `mailto:` / `tel:` urls, so the [Item] model stays unchanged.
enum LinkType {
  link(
    label: 'Link',
    fieldLabel: 'Enter url',
    scheme: '',
    prefill: 'https://',
    keyboardType: TextInputType.url,
  ),
  email(
    label: 'Email',
    fieldLabel: 'Enter email',
    scheme: 'mailto:',
    prefill: '',
    keyboardType: TextInputType.emailAddress,
  ),
  phone(
    label: 'Phone',
    fieldLabel: 'Enter phone number',
    scheme: 'tel:',
    prefill: '',
    keyboardType: TextInputType.phone,
  );

  const LinkType({
    required this.label,
    required this.fieldLabel,
    required this.scheme,
    required this.prefill,
    required this.keyboardType,
  });

  final String label;
  final String fieldLabel;
  final String scheme;
  final String prefill;
  final TextInputType keyboardType;

  //regexp to check url
  static final _linkRegExp = RegExp(
    r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})",
  );
  static final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phoneRegExp = RegExp(r'^\+?[0-9\s()\-]+$');
  static final _phoneSeparators = RegExp(r'[\s()\-]');

  static LinkType fromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.startsWith(email.scheme)) return email;
    if (lower.startsWith(phone.scheme)) return phone;
    return link;
  }

  /// The part of a saved [url] shown in the edit field.
  String displayValue(String url) => url.substring(scheme.length);

  /// Turns what the user typed into the url that gets saved.
  String toUrl(String input) => switch (this) {
    link => input.replaceAll("https://https://", "https://"),
    email => '$scheme${input.trim()}',
    phone => '$scheme${input.replaceAll(_phoneSeparators, '')}',
  };

  String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return fieldLabel;
    final input = value.trim();

    return switch (this) {
      link when !_linkRegExp.hasMatch(value) =>
        "Enter link in correct way 'https://example.com'",
      email when !_emailRegExp.hasMatch(input) =>
        "Enter email in correct way 'name@example.com'",
      phone
          when !_phoneRegExp.hasMatch(input) ||
              input.replaceAll(RegExp(r'\D'), '').length < 3 =>
        "Enter phone number in correct way '+1 555 123 4567'",
      _ => null,
    };
  }
}
