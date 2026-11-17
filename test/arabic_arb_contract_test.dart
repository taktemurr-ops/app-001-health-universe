import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic ARB has the same message keys and placeholders as English', () {
    Map<String, dynamic> load(String locale) {
      final file = File('lib/l10n/app_$locale.arb');
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    }

    final english = load('en');
    final arabic = load('ar');
    expect(arabic['@@locale'], 'ar');

    final messageKeys = english.keys.where((key) => !key.startsWith('@')).toSet();
    expect(arabic.keys.where((key) => !key.startsWith('@')).toSet(), messageKeys);

    for (final key in messageKeys) {
      expect(arabic[key], isA<String>(), reason: key);
      expect((arabic[key] as String).trim(), isNotEmpty, reason: key);
      final placeholders = RegExp(r'\{([a-zA-Z][a-zA-Z0-9]*)\}');
      final expected = placeholders
          .allMatches(english[key] as String)
          .map((match) => match.group(1))
          .toSet();
      final actual = placeholders
          .allMatches(arabic[key] as String)
          .map((match) => match.group(1))
          .toSet();
      expect(actual, expected, reason: 'Placeholder mismatch in $key');
    }
  });
}
