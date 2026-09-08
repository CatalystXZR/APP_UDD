import 'package:bvo_matematica/latex/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

const sample = r'Pedir calcular tres términos de \(a_n=2n+1\). \[\lim_{n\to\infty}e_n=\frac{a}{c}\] Fin.';

Widget wrap(String s) => MaterialApp(home: Scaffold(body: LatexText(s)));

void main() {
  testWidgets('renderiza prosa + inline + display sin errores', (tester) async {
    await tester.pumpWidget(wrap(sample));
    await tester.pumpAndSettle();
    expect(find.byType(LatexText), findsOneWidget);
    expect(find.byType(Math), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('golden muestra representativa estilo pauta', (tester) async {
    await tester.pumpWidget(wrap(sample));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(LatexText),
      matchesGoldenFile('goldens/latex_sample.png'),
    );
  });
}
