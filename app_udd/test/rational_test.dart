import 'package:bvo_matematica/domain/generators/latex_format.dart';
import 'package:bvo_matematica/domain/generators/rational.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rational', () {
    test('normaliza signo y mcd', () {
      expect(Rational(2, 4), Rational(1, 2));
      expect(Rational(-1, -2), Rational(1, 2));
      expect(Rational(1, -2), Rational(-1, 2));
      expect(Rational(0, 5), Rational(0));
    });

    test('denominador cero lanza', () {
      expect(() => Rational(1, 0), throwsArgumentError);
    });

    test('aritmetica exacta sin flotantes', () {
      expect(Rational(1, 3) + Rational(1, 6), Rational(1, 2));
      expect(Rational(2, 3) * Rational(3, 4), Rational(1, 2));
      expect(Rational(3, 4) / Rational(3, 2), Rational(1, 2));
      expect(Rational(5, 6) - Rational(1, 3), Rational(1, 2));
      expect(Rational(2, 5).neg(), Rational(-2, 5));
    });

    test('toLatex', () {
      expect(Rational(3).toLatex(), '3');
      expect(Rational(-4).toLatex(), '-4');
      expect(Rational(3, 2).toLatex(), r'\frac{3}{2}');
      expect(Rational(-1, 2).toLatex(), r'-\frac{1}{2}');
    });

    test('timesX', () {
      expect(Rational(1).timesX(), 'x');
      expect(Rational(-1).timesX(), '-x');
      expect(Rational(2).timesX(), '2x');
      expect(Rational(1, 2).timesX(), r'\frac{1}{2}x');
    });

    test('onePlusCoeffX nunca produce +-', () {
      expect(onePlusCoeffX(Rational(-2)), '1-2x');
      expect(onePlusCoeffX(Rational(3)), '1+3x');
      expect(onePlusCoeffX(Rational(-1, 2)), r'1-\frac{1}{2}x');
    });

    test('basePow agrupa bases no enteras', () {
      expect(basePow(mathBases[0], 'x'), '2^{x}');
      expect(basePow(mathBases[3], 'x'), r'\(\sqrt{2}\)^{x}');
      expect(basePow(mathBases[4], 'x'), r'\(\frac32\)^{x}');
    });

    test('rationalTimesSymbol', () {
      expect(rationalTimesSymbol(Rational(0), r'\ln 5'), '0');
      expect(rationalTimesSymbol(Rational(1), r'\ln 5'), r'\ln 5');
      expect(rationalTimesSymbol(Rational(-1), r'\ln 5'), r'-\ln 5');
      expect(rationalTimesSymbol(Rational(2), r'\ln 5'), r'2\ln 5');
      expect(rationalTimesSymbol(Rational(3, 2), r'\ln 5'), r'\frac{3\ln 5}{2}');
    });

    test('sumSymbolic une signos sin ++ ni +-', () {
      final s = sumSymbolic(
        symTerm(Rational(3, 2), r'\ln 5'),
        symTerm(Rational(1), r'\ln 3'),
      );
      expect(s, r'\frac{3\ln 5}{2}+\ln 3');
      final d = sumSymbolic(
        symTerm(Rational(1), r'\ln 5'),
        symTerm(Rational(2), r'\ln 3'),
        subtractSecond: true,
      );
      expect(d, r'\ln 5-2\ln 3');
    });
  });
}
