import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final directory = Directory('lib/l10n');

  test('English and Turkish ARB files share translation keys and placeholders', () {
    final en = jsonDecode(File('${directory.path}/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;
    final tr = jsonDecode(File('${directory.path}/app_tr.arb').readAsStringSync())
        as Map<String, dynamic>;

    expect(en['@@locale'], 'en');
    expect(tr['@@locale'], 'tr');

    Set<String> keys(Map<String, dynamic> arb) =>
        arb.keys.where((key) => !key.startsWith('@')).toSet();

    expect(keys(tr), keys(en));
    for (final key in keys(en)) {
      expect(en[key], isA<String>(), reason: 'English: $key');
      expect(tr[key], isA<String>(), reason: 'Turkish: $key');
      expect((en[key] as String).trim(), isNotEmpty);
      expect((tr[key] as String).trim(), isNotEmpty);

      final tokens = RegExp(r'\{([a-zA-Z][a-zA-Z0-9_]*)\}');
      Set<String> placeholders(String value) =>
          tokens.allMatches(value).map((match) => match.group(1)!).toSet();
      expect(
        placeholders(tr[key] as String),
        placeholders(en[key] as String),
        reason: 'Placeholder mismatch for $key',
      );
    }
  });

  test('every shipped ARB locale has a declared locale and valid JSON', () {
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.arb'))
        .toList();
    expect(files, isNotEmpty);
    for (final file in files) {
      final arb = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final locale = file.uri.pathSegments.last
          .replaceFirst('app_', '')
          .replaceFirst('.arb', '');
      expect(arb['@@locale'], locale, reason: file.path);
    }
  });
}
