import 'package:app_time/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on dashboard screen', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Próximo jogo'), findsOneWidget);
  });
}
