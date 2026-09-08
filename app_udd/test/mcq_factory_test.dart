import 'dart:math';

import 'package:bvo_matematica/domain/entities/question.dart';
import 'package:bvo_matematica/domain/generators/latex_format.dart';
import 'package:bvo_matematica/domain/generators/mcq_factory.dart';
import 'package:bvo_matematica/domain/generators/rational.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mcq', () {
    test('produce 6 alternativas unicas con la correcta rastreada', () {
      final q = mcq(
        familyId: 'basico-f6',
        level: 'Básico',
        text: r'Calcule \(\lim e_n\).',
        correctText: wrapMath(Rational(2).toLatex()),
        distractors: [
          wrapMath(Rational(4).toLatex()),
          wrapMath(Rational(1, 2).toLatex()),
          wrapMath(Rational(3).toLatex()),
          wrapMath(Rational(5).toLatex()),
          'No existe',
        ],
        solution: ['a', 'b', 'c'],
        rng: Random(7),
      );
      expect(q.options.length, 6);
      expect(q.options.toSet().length, 6);
      expect(q.correctText, wrapMath('2'));
      expect(q.options[q.correct], wrapMath('2'));
    });

    test('misma semilla produce mismo orden', () {
      Question buildQ() => mcq(
            familyId: 'x',
            level: 'Básico',
            text: 't',
            correctText: wrapMath('1'),
            distractors: const ['a', 'b', 'c', 'd', 'e'],
            solution: const [],
            rng: Random(42),
          );
      final a = buildQ();
      final b = buildQ();
      expect(a.options, b.options);
      expect(a.correct, b.correct);
    });

    test('distractores colisionados se rellenan sin duplicar', () {
      final q = mcq(
        familyId: 'x',
        level: 'Básico',
        text: 't',
        correctText: wrapMath('1'),
        distractors: const [r'\(1\)', r'\(1\)', r'\(1\)'],
        solution: const [],
        rng: Random(1),
      );
      expect(q.options.length, 6);
      expect(q.options.toSet().length, 6);
      expect(q.correctText, wrapMath('1'));
    });

    test('invariante masiva con rng aleatorio', () {
      final rng = Random();
      for (var i = 0; i < 200; i++) {
        final Question q = mcq(
          familyId: 'x',
          level: 'Básico',
          text: 't',
          correctText: wrapMath(Rational(i % 5).toLatex()),
          distractors: const ['d1', 'd2', 'd3'],
          solution: const [],
          rng: rng,
        );
        expect(q.options.length, 6);
        expect(q.options[q.correct], q.correctText);
      }
    });
  });
}
