import 'dart:math';

import '../../entities/question.dart';
import '../latex_format.dart';
import '../mcq_factory.dart';
import '../rational.dart';
import 'family.dart';
import 'family_text.dart';

const _allowedMP = {2, 3, 4};
const _allowedMR = {1, 2, 3, 4};
const _allowedQ = {2, 3, -2};
const _allowedLP = {1, 2, 3, 4};

const epsSymbols = {
  'alternating': '(-1)^n',
  'sin': '\\sin n',
  'cos_sq': '\\cos(n^2)',
  'alternating_shift': '(-1)^{n+1}',
};

Rational _rhoFromRaw(String raw) {
  switch (raw) {
    case r'\tfrac12':
      return Rational(1, 2);
    case r'\tfrac13':
      return Rational(1, 3);
    case r'\tfrac14':
      return Rational(1, 4);
    case r'\tfrac23':
      return Rational(2, 3);
  }
  throw ArgumentError('rho no autorizado: $raw');
}

Question medioF1(int p, int q, int r, int h, int k, {Random? rng}) {
  if (!_allowedMP.contains(p)) throw ArgumentError('p no autorizado');
  if (q.abs() > 4) throw ArgumentError('|q| supera 4');
  if (!_allowedMR.contains(r)) throw ArgumentError('r no autorizado');
  if (h != 0 && h != 1) throw ArgumentError('h debe ser 0 o 1');
  if (k < 5 || k > 10) throw ArgumentError('k fuera de rango');
  for (var n = 1; n <= k; n++) {
    if (p * n + q <= 0) throw ArgumentError('numerador no positivo');
  }
  Rational term(int n) {
    final sign = (n + h).isOdd ? Rational(-1) : Rational(1);
    return sign * Rational(p * n + q, n + r);
  }

  final first = [for (var n = 1; n <= 4; n++) term(n).toLatex()].join(', ');
  final ans = term(k);
  return mcq(
    familyId: 'medio-f1',
    level: 'Medio',
    text:
        'Los primeros términos son \\($first\\). Halle \\(a_{$k}\\) y explique el efecto de \\(h=$h\\).',
    correctText: wrapMath(ans.toLatex()),
    distractors: [
      wrapMath(term(k - 1).toLatex()),
      wrapMath(ans.neg().toLatex()),
      wrapMath(Rational(p * k + q, k + r + 1).toLatex()),
      wrapMath(Rational(p * (k + 1) + q, k + 1 + r).toLatex()),
    ],
    solution: [
      'El factor \\((-1)^{n+$h}\\) alterna el signo; con \\(h=$h\\):',
      '\\[a_n=(-1)^{n+$h}\\frac{${pnTerm(p)}${signedTerm(q)}}{n${signedTerm(r)}}\\]',
      'Sustituyendo \\(n=$k\\):',
      '\\[a_{$k}=${ans.toLatex()}\\]',
    ],
    rng: rng,
  );
}

Question medioF2(int l, int c, int q, {Random? rng}) {
  if (!_allowedQ.contains(q)) throw ArgumentError('q no autorizado');
  if (c == 0) throw ArgumentError('C debe ser no nulo');
  if (c.abs() > 4) throw ArgumentError('|C| supera 4');
  if (l.abs() > 5) throw ArgumentError('|L| supera 5');
  int term(int n) {
    var p = 1;
    for (var i = 1; i < n; i++) {
      p *= q;
    }
    return l + c * p;
  }

  final ans = term(4);
  return mcq(
    familyId: 'medio-f2',
    level: 'Medio',
    text:
        'Si \\(b_n=$l${c >= 0 ? '+' : ''}$c($q)^{n-1}\\), halle \\(b_4\\) y verifique su recurrencia.',
    correctText: wrapMath('$ans'),
    distractors: [
      wrapMath('${term(3)}'),
      wrapMath('${term(5)}'),
      wrapMath('${l + c * q * 3}'),
      wrapMath('${l + c + q}'),
    ],
    solution: [
      'La recurrencia de primer orden es:',
      '\\[b_{n+1}=$q b_n${signedTerm((1 - q) * l)},\\qquad b_1=${l + c}\\]',
      'Evaluando el término general en \\(n=4\\):',
      '\\[b_4=$l+$c($q)^3=$ans\\]',
    ],
    rng: rng,
  );
}

Question medioF3(int a, int b, int c, int d, {Random? rng}) {
  for (final v in [a, b, c, d]) {
    if (v.abs() > 6) throw ArgumentError('coeficiente fuera de rango');
  }
  if (c <= 0) throw ArgumentError('C debe ser positivo');
  if (c + d <= 0) throw ArgumentError('denominador no positivo en n=1');
  final det = a * d - b * c;
  if (det == 0) throw ArgumentError('AD-BC nulo');
  final growing = det > 0;
  return mcq(
    familyId: 'medio-f3',
    level: 'Medio',
    text:
        'Determine la monotonía de \\(c_n=\\frac{${a}n${signedTerm(b)}}{${c}n${signedTerm(d)}}\\).',
    correctText:
        growing ? 'Estrictamente creciente' : 'Estrictamente decreciente',
    distractors: const [
      'No es monótona',
      'Constante',
      'Estrictamente creciente',
      'Estrictamente decreciente',
    ],
    solution: [
      'Calculamos la diferencia entre términos consecutivos:',
      '\\[c_{n+1}-c_n=\\frac{$det}{(${c}n${signedTerm(d)})(${c}n${signedTerm(c + d)})}\\]',
      growing
          ? 'Como \\($det>0\\), la sucesión es estrictamente creciente.'
          : 'Como \\($det<0\\), la sucesión es estrictamente decreciente.',
    ],
    rng: rng,
  );
}

Question medioF4(int l, int k, int r, {Random? rng}) {
  if (k == 0) throw ArgumentError('K debe ser no nulo');
  if (r < 0) throw ArgumentError('r debe ser no negativo');
  final first = Rational(l * (r + 1) + k, r + 1);
  final decreasing = k > 0;
  return mcq(
    familyId: 'medio-f4',
    level: 'Medio',
    text:
        'Sea \\(d_n=$l${k >= 0 ? '+' : ''}\\frac{${k.abs()}}{n${signedTerm(r)}}\\). Halle su límite.',
    correctText: wrapMath('$l'),
    distractors: [
      wrapMath(first.toLatex()),
      wrapMath('${l + 1}'),
      wrapMath('${l - 1}'),
      wrapMath('${l + k}'),
    ],
    solution: [
      decreasing
          ? 'Como \\(K=$k>0\\), la sucesión decrece hacia \\($l\\).'
          : 'Como \\(K=$k<0\\), la sucesión crece hacia \\($l\\).',
      'El extremo alcanzado es:',
      '\\[d_1=$l${k >= 0 ? '+' : ''}\\frac{${k.abs()}}{${r + 1}}=${first.toLatex()}\\]',
      'El límite \\($l\\) es una cota no alcanzada.',
    ],
    rng: rng,
  );
}

Question medioF5(int p, int q, int r, {Random? rng}) {
  if (!_allowedLP.contains(p)) throw ArgumentError('p no autorizado');
  if (q % (2 * p) != 0) throw ArgumentError('q debe ser múltiplo de 2p');
  for (var n = 1; n <= 8; n++) {
    if (p * p * n * n + q * n + r <= 0) {
      throw ArgumentError('radicando no positivo');
    }
  }
  final ans = Rational(q, 2 * p);
  return mcq(
    familyId: 'medio-f5',
    level: 'Medio',
    text:
        'Racionalice y calcule \\(\\displaystyle\\lim_{n\\to\\infty}(\\sqrt{${p * p}n^2${signedTerm(q)}n${signedTerm(r)}}-${p}n)\\).',
    correctText: wrapMath(ans.toLatex()),
    distractors: [
      wrapMath('$q'),
      wrapMath('$p'),
      wrapMath(Rational(q, p).toLatex()),
      wrapMath('$r'),
    ],
    solution: [
      'Multiplicamos por la conjugada:',
      '\\[e_n=\\frac{$q\\,n+$r}{\\sqrt{${p * p}n^2${signedTerm(q)}n${signedTerm(r)}}+$p\\,n}\\]',
      'Dividiendo por \\(n\\) y tomando límite:',
      '\\[\\lim e_n=\\frac{$q}{${2 * p}}=${ans.toLatex()}\\]',
    ],
    rng: rng,
  );
}

Question medioF6(Rational rho, int l, int u, {Random? rng}) {
  if (rho.n <= 0 || rho.n >= rho.d) {
    throw ArgumentError('rho debe estar en (0,1)');
  }
  final x2 = rho * Rational(u) + (Rational(1) - rho) * Rational(l);
  final drift = (Rational(1) - rho) * Rational(l);
  final driftTxt =
      drift.isNegative ? drift.toLatex() : '+${drift.toLatex()}';
  final growing = u < l;
  return mcq(
    familyId: 'medio-f6',
    level: 'Medio',
    text:
        'Sea \\(x_1=$u\\) y \\(x_{n+1}=${rho.toLatex()}x_n$driftTxt\\). Halle su límite.',
    correctText: wrapMath('$l'),
    distractors: [
      wrapMath('$u'),
      wrapMath(x2.toLatex()),
      wrapMath('${l + 1}'),
      wrapMath('${l - 1}'),
    ],
    solution: [
      'La forma cerrada es:',
      '\\[x_n=$l+(${u - l})(${rho.toLatex()})^{n-1}\\]',
      growing
          ? 'Como \\($u<$l\\), la sucesión crece acotada por \\($l\\).'
          : 'Como \\($u>$l\\), la sucesión decrece acotada por \\($l\\).',
      'Como \\(${rho.toLatex()}^{n-1}\\to0\\), el límite es \\($l\\).',
    ],
    rng: rng,
  );
}

Question medioF7(String epsKey, int a, int b, int c, {Random? rng}) {
  final eps = epsSymbols[epsKey];
  if (eps == null) throw ArgumentError('epsilon no autorizado');
  if (a <= 0) throw ArgumentError('a debe ser positivo');
  if (b < 0 || c < 0) throw ArgumentError('b,c no negativos');
  if (a > 6 || b > 6 || c > 6) throw ArgumentError('coeficiente fuera de rango');
  return mcq(
    familyId: 'medio-f7',
    level: 'Medio',
    text:
        'Justifique con el teorema del sándwich \\(\\displaystyle\\lim_{n\\to\\infty}$eps\\frac{${a}n${signedTerm(b)}}{n^2${signedTerm(c)}}\\).',
    correctText: wrapMath('0'),
    distractors: [
      'No existe',
      wrapMath('1'),
      wrapMath('-1'),
      wrapMath('$a'),
    ],
    solution: [
      'Acotamos el valor absoluto:',
      '\\[|y_n|\\leq\\frac{${a}n${signedTerm(b)}}{n^2${signedTerm(c)}}\\longrightarrow0\\]',
      'Por el teorema del sándwich, el límite es \\(0\\).',
    ],
    rng: rng,
  );
}

final Map<String, FamilyGenerator> medioGenerators = {
  'seq_alternating_pattern': (t, rng) => medioF1(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2),
      tupleInt(t, 3), tupleInt(t, 4),
      rng: rng),
  'seq_explicit_recursive_conversion': (t, rng) => medioF2(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2),
      rng: rng),
  'seq_rational_monotonicity': (t, rng) => medioF3(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), tupleInt(t, 3),
      rng: rng),
  'seq_horizontal_asymptote_bound': (t, rng) => medioF4(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2),
      rng: rng),
  'seq_rationalizable_limit': (t, rng) => medioF5(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2),
      rng: rng),
  'seq_affine_convergent_recurrence': (t, rng) => medioF6(
      _rhoFromRaw(tupleRaw(t)[0]), tupleInt(t, 1), tupleInt(t, 2),
      rng: rng),
  'seq_sandwich_theorem': (t, rng) => medioF7(
      tupleValues(t)[0].toString(),
      tupleInt(t, 1), tupleInt(t, 2), tupleInt(t, 3),
      rng: rng),
};
