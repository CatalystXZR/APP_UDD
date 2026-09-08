import 'dart:math';

import 'rational.dart';

final List<Rational> nonzeroCoeffs = [
  Rational(-5),
  Rational(-4),
  Rational(-3),
  Rational(-2),
  Rational(-1),
  Rational(1, 2),
  Rational(2, 3),
  Rational(3, 2),
  Rational(3, 4),
  Rational(4, 3),
  Rational(1),
  Rational(2),
  Rational(3),
  Rational(4),
  Rational(5),
  Rational(6),
];

final List<Rational> posCoeffs =
    nonzeroCoeffs.where((r) => r.n > 0).toList();

class MathBase {
  const MathBase(this.key, this.latex, this.ln);

  final String key;
  final String latex;
  final String ln;
}

const List<MathBase> mathBases = [
  MathBase('2', '2', '\\ln 2'),
  MathBase('3', '3', '\\ln 3'),
  MathBase('5', '5', '\\ln 5'),
  MathBase('sqrt2', '\\sqrt{2}', '\\ln\\sqrt{2}'),
  MathBase('3/2', '\\frac32', '\\ln\\!\\(\\frac32\\)'),
  MathBase('5/2', '\\frac52', '\\ln\\!\\(\\frac52\\)'),
];

String wrapMath(String s) => '\\($s\\)';

T pick<T>(List<T> arr, Random rng) => arr[rng.nextInt(arr.length)];

String ratioLatex(Rational a, Rational b) => (a / b).toLatex();

String parenCoeffX(Rational r) {
  final s = r.timesX();
  return r.isNegative ? '($s)' : s;
}

String onePlusCoeffX(Rational r) {
  if (r.isNegative) return '1-${r.neg().timesX()}';
  return '1+${r.timesX()}';
}

String basePow(MathBase base, String exponentLatex) {
  final needsParens =
      base.key.contains('/') || base.key.startsWith('sqrt');
  final b = needsParens ? '\\(${base.latex}\\)' : base.latex;
  return '$b^{$exponentLatex}';
}

String coeffTimesExpr(Rational r, String expr) {
  if (r.isOne) return expr;
  if (r.isMinusOne) return '-$expr';
  return '${r.toLatex()}\\,$expr';
}

String rationalTimesSymbol(Rational r, String symbol) {
  if (r.isZero) return '0';
  if (r.d == 1) {
    if (r.n == 1) return symbol;
    if (r.n == -1) return '-$symbol';
    return '${r.n}$symbol';
  }
  final sign = r.isNegative ? '-' : '';
  final absn = r.n.abs();
  final numPart = absn == 1 ? symbol : '$absn$symbol';
  return '$sign\\frac{$numPart}{${r.d}}';
}

String signedSymbolTerm(Rational r, String symbol) {
  if (r.isZero) return '';
  final body = rationalTimesSymbol(r.abs(), symbol);
  return r.isNegative ? '-$body' : '+$body';
}

String signedExprTerm(Rational r, String expr) {
  if (r.isZero) return '';
  final body = coeffTimesExpr(r.abs(), expr);
  return r.isNegative ? '-$body' : '+$body';
}

String rationalOverLn(Rational r, String lnBase) {
  final sign = r.isNegative ? '-' : '';
  final an = r.n.abs();
  if (r.d == 1) {
    if (an == 1) return '$sign\\frac{1}{$lnBase}';
    return '$sign\\frac{$an}{$lnBase}';
  }
  final numerator = an == 1 ? '1' : '$an';
  return '$sign\\frac{$numerator}{${r.d}$lnBase}';
}

({Rational coef, String sym}) symTerm(Rational coef, String sym) =>
    (coef: coef, sym: sym);

String sumSymbolic(
  ({Rational coef, String sym}) term1,
  ({Rational coef, String sym}) term2, {
  bool subtractSecond = false,
}) {
  final t1 = rationalTimesSymbol(term1.coef, term1.sym);
  final c2 = subtractSecond ? term2.coef.neg() : term2.coef;
  final t2raw = rationalTimesSymbol(c2, term2.sym);
  if (t2raw.startsWith('-')) return '$t1$t2raw';
  return '$t1+$t2raw';
}
