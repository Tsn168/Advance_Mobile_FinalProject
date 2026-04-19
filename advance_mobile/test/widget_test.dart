import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advance_mobile/main.dart';
import 'package:advance_mobile/service_locator.dart';

void main() {
  testWidgets('App boots splash then shows bottom navigation', (
    WidgetTester tester,
  ) async {
    setupServiceLocator();

    await tester.pumpWidget(const MyApp());

    expect(find.text('Bike Sharing App'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    await tester.tap(find.text('Plans'));
    await tester.pumpAndSettle();

    expect(find.text('Subscription Plans'), findsOneWidget);
  });
}
