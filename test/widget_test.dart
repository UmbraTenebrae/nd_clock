import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nd_clock/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: NdClockApp()),
    );
    await tester.pump();
    // The clock screen should be present
    expect(find.byType(Scaffold), findsWidgets);
  });
}
