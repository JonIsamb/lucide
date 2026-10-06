import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide/app.dart';

void main() {
  testWidgets('the shell shows the 4 tabs and switches between them',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LucideApp()));

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Simulations'), findsOneWidget);
    expect(find.text('Jeu'), findsOneWidget);

    await tester.tap(find.text('Jeu'));
    await tester.pumpAndSettle();
    expect(find.text('Teste ton intuition'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
