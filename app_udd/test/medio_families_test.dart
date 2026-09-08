import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bvo_matematica/domain/entities/question.dart';
import 'package:bvo_matematica/domain/generators/families/medio.dart';
import 'package:bvo_matematica/domain/generators/latex_format.dart';
import 'package:bvo_matematica/domain/generators/rational.dart';
import 'package:flutter_test/flutter_test.dart';

void checkInvariants(Question q) {
  expect(q.options.length, 6, reason: q.familyId);
  expect(q.options.toSet().length, 6, reason: q.familyId);
  expect(q.correct, inInclusiveRange(0, 5), reason: q.familyId);
  expect(q.solution.length, greaterThanOrEqualTo(3), reason: q.familyId);
  expect(q.text.contains(r'\(') || q.text.contains(r'\['), isTrue,
      reason: q.familyId);
}

int iv(List<dynamic> t, int i) => (t[i] as num).toInt();

void main() {
  test('todas las tuplas autorizadas de Medio generan preguntas validas',
      () {
    final seed = jsonDecode(
      File('assets/seed/families_seed.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final level = (seed['levels'] as List)
        .firstWhere((l) => l['key'] == 'medio') as Map<String, dynamic>;
    final families = level['families'] as List;
    expect(families.length, 7);

    final seedSymbols =
        ((families[6] as Map)['params'] as List).firstWhere(
            (p) => p['name'] == 'eps')['symbols'] as Map<String, dynamic>;
    expect(Map.of(seedSymbols), epsSymbols);

    var count = 0;
    for (final f in families) {
      final fam = f as Map<String, dynamic>;
      final gen = medioGenerators[fam['generator_key']]!;
      for (final t in fam['tuples'] as List) {
        final tuple = t as Map<String, dynamic>;
        final values = List<dynamic>.from(tuple['values'] as List);
        final q = gen(tuple, Random(123));
        checkInvariants(q);
        switch (fam['family_index'] as int) {
          case 1:
            final p = iv(values, 0),
                qq = iv(values, 1),
                r = iv(values, 2),
                h = iv(values, 3),
                k = iv(values, 4);
            final sign = (k + h).isOdd ? Rational(-1) : Rational(1);
            expect(q.correctText,
                wrapMath((sign * Rational(p * k + qq, k + r)).toLatex()));
          case 2:
            final l = iv(values, 0), c = iv(values, 1), qq = iv(values, 2);
            expect(q.correctText, wrapMath('${l + c * qq * qq * qq}'));
          case 3:
            final a = iv(values, 0),
                b = iv(values, 1),
                c = iv(values, 2),
                d = iv(values, 3);
            expect(
                q.correctText,
                a * d - b * c > 0
                    ? 'Estrictamente creciente'
                    : 'Estrictamente decreciente');
          case 4:
            expect(q.correctText, wrapMath('${iv(values, 0)}'));
          case 5:
            final p = iv(values, 0), qq = iv(values, 1);
            expect(q.correctText,
                wrapMath(Rational(qq, 2 * p).toLatex()));
          case 6:
            expect(q.correctText, wrapMath('${iv(values, 1)}'));
          case 7:
            expect(q.correctText, wrapMath('0'));
        }
        count++;
      }
    }
    expect(count, 28);
  });

  test('guardas rechazan parametros fuera de pauta', () {
    expect(() => medioF1(5, 0, 1, 0, 8), throwsArgumentError);
    expect(() => medioF1(2, 0, 1, 2, 8), throwsArgumentError);
    expect(() => medioF2(3, 2, 5), throwsArgumentError);
    expect(() => medioF3(1, 1, 0, 1), throwsArgumentError);
    expect(() => medioF3(2, 4, 2, 4), throwsArgumentError);
    expect(() => medioF4(3, 0, 1), throwsArgumentError);
    expect(() => medioF5(5, 4, 1), throwsArgumentError);
    expect(() => medioF5(1, 3, 1), throwsArgumentError);
    expect(
        () => medioF6(Rational(3, 2), 4, 0), throwsArgumentError);
    expect(() => medioF7('xxx', 2, 3, 1), throwsArgumentError);
  });
}
