import 'package:bvo_matematica/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flujo welcome hasta primera pregunta', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BvoApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();
    expect(find.text('Selecciona la dificultad'), findsOneWidget);

    await tester.tap(find.text('Básico'));
    await tester.pumpAndSettle();
    expect(find.text('¿Qué quieres practicar?'), findsOneWidget);

    await tester.tap(find.text('Cálculo Diferencial'));
    await tester.pumpAndSettle();
    expect(find.text('Selecciona el contenido'), findsOneWidget);

    await tester.tap(find.text('Sucesiones y Límites'));
    await tester.pumpAndSettle();
    expect(find.text('Antes de comenzar'), findsOneWidget);
    expect(find.textContaining('60 segundos por pregunta'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Comenzar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Pregunta 1'), findsOneWidget);
    expect(find.text('Confirmar respuesta'), findsOneWidget);

    final confirmFinder =
        find.widgetWithText(ElevatedButton, 'Confirmar respuesta');
    final confirm = tester.widget<ElevatedButton>(confirmFinder);
    expect(confirm.onPressed, isNull);

    await tester.tap(find.text('A.').first);
    await tester.pump();
    final enabled = tester.widget<ElevatedButton>(confirmFinder);
    expect(enabled.onPressed, isNotNull);

    await tester.tap(confirmFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Pregunta 2'), findsOneWidget);
  });
}
