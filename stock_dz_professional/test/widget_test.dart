import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:stock_dz_professional/ui/dashboard_page.dart';

void main() {
  testWidgets('DashboardPage loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: DashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsOneWidget);
  });
}