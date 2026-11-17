import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final locales = <String, Map<String, dynamic>>{};
  for (final locale in ['en', 'tr', 'ar']) {
    final path = 'lib/l10n/app_$locale.arb';
    final json = jsonDecode(File(path).readAsStringSync());
    locales[locale] = Map<String, dynamic>.from(json as Map);
  }

  test('all locale files have matching translation keys', () {
    final sourceKeys = locales['en']!.keys.where((k) => !k.startsWith('@')).toSet();
    for (final locale in locales.keys) {
      final translatedKeys = locales[locale]!.keys.where((k) => !k.startsWith('@')).toSet();
      expect(translatedKeys, sourceKeys, reason: 'Missing or extra keys in $locale');
      expect(locales[locale]!['@@locale'], locale);
      for (final key in translatedKeys) {
        final value = locales[locale]![key];
        expect(value, isA<String>(), reason: '$locale:$key must be a string');
        expect((value as String).trim(), isNotEmpty, reason: '$locale:$key is empty');
      }
    }
  });

  test('localized ICU placeholders match the English template', () {
    final token = RegExp(r'\{([a-zA-Z][a-zA-Z0-9_]*)\}');
    final source = locales['en']!;
    for (final locale in locales.keys) {
      for (final key in source.keys.where((k) => !k.startsWith('@'))) {
        final expected = token.allMatches(source[key] as String).map((m) => m.group(1)).toSet();
        final actual = token.allMatches(locales[locale]![key] as String)
            .map((m) => m.group(1)).toSet();
        expect(actual, expected, reason: '$locale:$key placeholder mismatch');
        if (expected.isNotEmpty) {
          final metadata = locales[locale]!['@$key'] as Map<String, dynamic>?;
          expect(metadata, isNotNull, reason: '$locale:$key lacks metadata');
          final placeholders = (metadata!['placeholders'] as Map).keys.toSet();
          expect(placeholders, expected, reason: '$locale:$key metadata mismatch');
        }
      }
    }
  });
}
