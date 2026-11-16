import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/main.dart';

void main() {
  testWidgets('English journal labels are localized', (tester) async {
    await tester.pumpWidget(const HealthUniverseApp());
    await tester.pumpAndSettle();
    expect(find.text('Personal health journal'), findsOneWidget);
    expect(find.text('Save measurement'), findsOneWidget);
    expect(find.text('History (0)'), findsOneWidget);
  });
}
