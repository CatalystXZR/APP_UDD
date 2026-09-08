import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bvo_matematica/domain/entities/question.dart';
import 'package:bvo_matematica/domain/generators/families/basico.dart';
import 'package:bvo_matematica/domain/generators/latex_format.dart';
import 'package:bvo_matematica/domain/generators/rational.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> loadSeed() => jsonDecode(
      File('assets/seed/families_seed.json').readAsStringSync(),
    ) as Map<String, dynamic>;

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
  test('todas las tuplas autorizadas de Basico generan preguntas validas',
      () {
    final seed = loadSeed();
    final level = (seed['levels'] as List)
        .firstWhere((l) => l['key'] == 'basico') as Map<String, dynamic>;
    final families = level['families'] as List;
    expect(families.length, 7);

    var count = 0;
    for (final f in families) {
      final fam = f as Map<String, dynamic>;
      final gen = basicoGenerators[fam['generator_key']]!;
      final tuples = fam['tuples'] as List;
      if (tuples.isEmpty) continue;
      for (final t in tuples) {
        final tuple = t as Map<String, dynamic>;
        final values = List<dynamic>.from(tuple['values'] as List);
        final q = gen(tuple, Random(123));
        checkInvariants(q);
        final p0 = iv(values, 0);
        final p1 = iv(values, 1);
        switch (fam['family_index'] as int) {
          case 1:
            final k = iv(values, 2);
            expect(q.correctText, wrapMath('${p0 * k + p1}'));
          case 2:
            final k = iv(values, 2);
            expect(q.correctText,
                wrapMath(Rational(k + p0, k + p1).toLatex()));
          case 3:
            final k = iv(values, 2);
            expect(q.correctText, wrapMath('${p0 + (k - 1) * p1}'));
          case 5:
            final r = iv(values, 2);
            expect(
                q.correctText,
                wrapMath(
                    Rational(p0 * (r + 1) - p1, r + 1).toLatex()));
          case 6:
            final c = iv(values, 2);
            expect(q.correctText, wrapMath(Rational(p0, c).toLatex()));
          case 7:
            expect(q.correctText, wrapMath('$p1'));
        }
        count++;
      }
    }
    expect(count, 24);
  });

  test('F4 cubre todo el dominio autorizado de p', () {
    for (final p in [-4, -3, -2, 2, 3, 4]) {
      for (final q in [-6, 0, 6]) {
        final question = basicoF4(p, q, rng: Random(9));
        checkInvariants(question);
        expect(
            question.correctText,
            p > 0 ? 'Estrictamente creciente' : 'Estrictamente decreciente');
      }
    }
  });

  test('guardas rechazan parametros fuera de pauta', () {
    expect(() => basicoF1(0, 1, 8), throwsArgumentError);
    expect(() => basicoF1(2, 1, 99), throwsArgumentError);
    expect(() => basicoF2(1, 1, 8), throwsArgumentError);
    expect(() => basicoF3(3, 0, 9), throwsArgumentError);
    expect(() => basicoF4(5, 0), throwsArgumentError);
    expect(() => basicoF5(4, 0, 1), throwsArgumentError);
    expect(() => basicoF6(2, 1, 0, 3), throwsArgumentError);
    expect(() => basicoF7(4, 4), throwsArgumentError);
  });
}
