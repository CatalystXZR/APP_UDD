import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bvo_matematica/domain/entities/question.dart';
import 'package:bvo_matematica/domain/generators/families/experto.dart';
import 'package:bvo_matematica/domain/generators/latex_format.dart';
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

int ipow(int base, int exp) {
  var r = 1;
  for (var i = 0; i < exp; i++) {
    r *= base;
  }
  return r;
}

void main() {
  test('todas las tuplas autorizadas de Experto generan preguntas validas',
      () {
    final seed = jsonDecode(
      File('assets/seed/families_seed.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final level = (seed['levels'] as List)
        .firstWhere((l) => l['key'] == 'experto') as Map<String, dynamic>;
    final families = level['families'] as List;
    expect(families.length, 7);

    var count = 0;
    for (final f in families) {
      final fam = f as Map<String, dynamic>;
      final gen = expertoGenerators[fam['generator_key']]!;
      for (final t in fam['tuples'] as List) {
        final tuple = t as Map<String, dynamic>;
        final values = List<dynamic>.from(tuple['values'] as List);
        final q = gen(tuple, Random(123));
        checkInvariants(q);
        switch (fam['family_index'] as int) {
          case 1:
            final p = iv(values, 0), qq = iv(values, 1), r = iv(values, 2);
            expect(q.correctText, wrapMath('${r + 10 * p + 4 * qq}'));
          case 2:
            final a = iv(values, 0),
                b = iv(values, 1),
                al = iv(values, 2),
                be = iv(values, 3);
            expect(q.correctText,
                wrapMath('${a * ipow(al, 3) + b * ipow(be, 3)}'));
          case 3:
            expect(q.correctText, wrapMath('${iv(values, 0) - iv(values, 1) - 1}'));
          case 4:
            final r = iv(values, 0), s = iv(values, 1);
            expect(
                q.correctText,
                '\\(\\frac{${s - r}}{\\sqrt{n+$s}+\\sqrt{n+$r}}\\)');
          case 5:
            final a = iv(values, 0);
            expect(q.correctText,
                a == 1 ? wrapMath('0') : wrapMath('\\ln $a'));
          case 6:
            expect(q.correctText, wrapMath('\\sqrt{${iv(values, 0)}}'));
          case 7:
            final a = iv(values, 0), b = iv(values, 1);
            expect(q.correctText,
                '${wrapMath('${a + b}')} y ${wrapMath('${a - b}')}');
        }
        count++;
      }
    }
    expect(count, 95);
  });

  test('guardas rechazan parametros fuera de pauta', () {
    expect(() => expertoF1(0, 1, 3), throwsArgumentError);
    expect(() => expertoF1(9, 1, 3), throwsArgumentError);
    expect(() => expertoF2(1, -1, 3, 3), throwsArgumentError);
    expect(() => expertoF2(9, -1, 3, 2), throwsArgumentError);
    expect(() => expertoF3(8, 1), throwsArgumentError);
    expect(() => expertoF3(4, 3), throwsArgumentError);
    expect(() => expertoF4(0, 9), throwsArgumentError);
    expect(() => expertoF5(1, 1, 2, 3), throwsArgumentError);
    expect(() => expertoF5(5, 1, 3, 2), throwsArgumentError);
    expect(() => expertoF6(4, 3), throwsArgumentError);
    expect(() => expertoF6(2, 9), throwsArgumentError);
    expect(() => expertoF7(1, 0, 2), throwsArgumentError);
    expect(() => expertoF7(1, 1, 99), throwsArgumentError);
  });
}
