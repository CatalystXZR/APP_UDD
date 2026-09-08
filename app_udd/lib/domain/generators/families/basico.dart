import 'dart:math';

import '../../entities/question.dart';
import '../latex_format.dart';
import '../mcq_factory.dart';
import '../rational.dart';
import 'family.dart';
import 'family_text.dart';

Question basicoF1(int p, int q, int k, {Random? rng}) {
  if (p == 0) throw ArgumentError('p debe ser no nulo');
  if (k < 1 || k > 12) throw ArgumentError('k fuera de rango');
  final ans = p * k + q;
  if (ans.abs() > 40) throw ArgumentError('|a_k| supera 40');
  return mcq(
    familyId: 'basico-f1',
    level: 'Básico',
    text: 'Si \\(a_n=${pnTerm(p)}${signedTerm(q)}\\), determine \\(a_{$k}\\).',
    correctText: wrapMath('$ans'),
    distractors: [
      wrapMath('${p * (k - 1) + q}'),
      wrapMath('${p * (k + 1) + q}'),
      wrapMath('${p * k}'),
      wrapMath('${(p + 1) * k + q}'),
    ],
    solution: [
      'Para \\(n=$k\\), sustituimos directamente en el término general:',
      '\\[a_{$k}=$p($k)${signedTerm(q)}=$ans\\]',
      'Por lo tanto, \\(a_{$k}=$ans\\).',
    ],
    rng: rng,
  );
}

Question basicoF2(int r, int s, int k, {Random? rng}) {
  if (s < 1) throw ArgumentError('s debe ser positivo');
  if (r == s) throw ArgumentError('r y s deben diferir');
  if (k < 5 || k > 12) throw ArgumentError('k fuera de rango');
  Rational term(int n) => Rational(n + r, n + s);
  final first = [for (var n = 1; n <= 4; n++) term(n).toLatex()].join(', ');
  final ans = term(k);
  return mcq(
    familyId: 'basico-f2',
    level: 'Básico',
    text:
        'Los primeros términos son \\($first\\). Determine el término general y \\(a_{$k}\\).',
    correctText: wrapMath(ans.toLatex()),
    distractors: [
      wrapMath(term(k - 1).toLatex()),
      wrapMath(Rational(k + r, k + s + 1).toLatex()),
      wrapMath(Rational(k + r + 1, k + s).toLatex()),
      wrapMath(Rational(k, k + s).toLatex()),
    ],
    solution: [
      'Identificamos el patrón de numeradores y denominadores:',
      '\\[a_n=\\frac{n${signedTerm(r)}}{n${signedTerm(s)}}\\]',
      'Sustituyendo \\(n=$k\\):',
      '\\[a_{$k}=\\frac{${k + r}}{${k + s}}=${ans.toLatex()}\\]',
    ],
    rng: rng,
  );
}

Question basicoF3(int a1, int d, int k, {Random? rng}) {
  if (d == 0) throw ArgumentError('d debe ser no nula');
  if (d.abs() > 5) throw ArgumentError('|d| supera 5');
  final ans = a1 + (k - 1) * d;
  return mcq(
    familyId: 'basico-f3',
    level: 'Básico',
    text:
        'Si \\(b_1=$a1\\) y \\(b_{n+1}=b_n${signedTerm(d)}\\), determine \\(b_{$k}\\).',
    correctText: wrapMath('$ans'),
    distractors: [
      wrapMath('${a1 + k * d}'),
      wrapMath('${a1 + (k - 2) * d}'),
      wrapMath('${a1 + (k - 1) * (d + 1)}'),
      wrapMath('$a1'),
    ],
    solution: [
      'Usamos el término general de una progresión aritmética:',
      '\\[b_n=b_1+(n-1)d\\]',
      'Sustituyendo \\(b_1=$a1\\), \\(d=$d\\) y \\(n=$k\\):',
      '\\[b_{$k}=$a1+${k - 1}($d)=$ans\\]',
    ],
    rng: rng,
  );
}

const _allowedP = {-4, -3, -2, 2, 3, 4};

Question basicoF4(int p, int q, {Random? rng}) {
  if (!_allowedP.contains(p)) throw ArgumentError('p no autorizado');
  if (q.abs() > 6) throw ArgumentError('|q| supera 6');
  final growing = p > 0;
  return mcq(
    familyId: 'basico-f4',
    level: 'Básico',
    text:
        'Determine si \\(c_n=${pnTerm(p)}${signedTerm(q)}\\) es creciente o decreciente.',
    correctText:
        growing ? 'Estrictamente creciente' : 'Estrictamente decreciente',
    distractors: const [
      'Constante',
      'No es monótona',
      'Estrictamente creciente',
      'Estrictamente decreciente',
    ],
    solution: [
      'Estudiamos el signo de la diferencia entre términos consecutivos:',
      '\\[c_{n+1}-c_n=$p\\]',
      growing
          ? 'Como \\(p=$p>0\\), la sucesión es estrictamente creciente.'
          : 'Como \\(p=$p<0\\), la sucesión es estrictamente decreciente.',
    ],
    rng: rng,
  );
}

Question basicoF5(int l, int m, int r, {Random? rng}) {
  if (m < 1 || m > 6) throw ArgumentError('m fuera de rango');
  if (r < 0 || r > 3) throw ArgumentError('r fuera de rango');
  final first = Rational(l * (r + 1) - m, r + 1);
  return mcq(
    familyId: 'basico-f5',
    level: 'Básico',
    text:
        'Sea \\(d_n=$l-\\frac{$m}{n${signedTerm(r)}}\\). ¿Cuál es su menor término?',
    correctText: wrapMath(first.toLatex()),
    distractors: [
      wrapMath('$l'),
      wrapMath(Rational(l * (r + 1) + m, r + 1).toLatex()),
      wrapMath(Rational(l * (r + 2) - m, r + 2).toLatex()),
      wrapMath(Rational(l * (r + 1) - m + 1, r + 1).toLatex()),
    ],
    solution: [
      'El primer término es el menor, pues \\(\\frac{$m}{n+$r}\\) decrece con \\(n\\):',
      '\\[d_1=$l-\\frac{$m}{${r + 1}}=${first.toLatex()}\\]',
      'Además \\(d_n<$l\\) para todo \\(n\\), luego \\($l\\) es cota superior.',
    ],
    rng: rng,
  );
}

Question basicoF6(int a, int b, int c, int d, {Random? rng}) {
  if (c == 0) throw ArgumentError('c debe ser no nulo');
  if (b.abs() > 5 || d.abs() > 5) throw ArgumentError('b,d fuera de rango');
  if (c + d <= 0) throw ArgumentError('denominador no positivo en n=1');
  final ans = Rational(a, c);
  return mcq(
    familyId: 'basico-f6',
    level: 'Básico',
    text:
        'Calcule \\(\\displaystyle\\lim_{n\\to\\infty}\\frac{${a}n${signedTerm(b)}}{${c}n${signedTerm(d)}}\\).',
    correctText: wrapMath(ans.toLatex()),
    distractors: [
      wrapMath(Rational(c, a).toLatex()),
      if (d != 0) wrapMath(Rational(b, d).toLatex()),
      wrapMath(Rational(a, d == 0 ? 1 : d).toLatex()),
      wrapMath(Rational(a + b, c + d).toLatex()),
    ],
    solution: [
      'Dividimos numerador y denominador por \\(n\\):',
      '\\[\\lim_{n\\to\\infty}\\frac{$a${signedTerm(b)}/n}{$c${signedTerm(d)}/n}=\\frac{$a}{$c}=${ans.toLatex()}\\]',
      'Por lo tanto, el límite es \\(${ans.toLatex()}\\).',
    ],
    rng: rng,
  );
}

Question basicoF7(int u, int l, {Random? rng}) {
  if (u == l) throw ArgumentError('u y L deben diferir');
  if (!{2, 4, 8}.contains((u - l).abs())) {
    throw ArgumentError('|u-L| no autorizado');
  }
  final x2 = Rational(u + l, 2);
  final x3 = Rational(x2.n + l * x2.d, 2 * x2.d);
  final growing = u < l;
  return mcq(
    familyId: 'basico-f7',
    level: 'Básico',
    text:
        'Sea \\(x_1=$u\\) y \\(x_{n+1}=\\frac{x_n+$l}{2}\\). Halle su límite.',
    correctText: wrapMath('$l'),
    distractors: [
      wrapMath('$u'),
      wrapMath(x2.toLatex()),
      wrapMath('${l + 1}'),
      wrapMath('${l - 1}'),
    ],
    solution: [
      'Calculamos los primeros términos:',
      '\\[x_2=\\frac{$u+$l}{2}=${x2.toLatex()},\\qquad x_3=\\frac{${x2.toLatex()}+$l}{2}=${x3.toLatex()}\\]',
      growing
          ? 'La sucesión es creciente y acotada superiormente por \\($l\\).'
          : 'La sucesión es decreciente y acotada inferiormente por \\($l\\).',
      'Con \\(x_n=$l+(${u - l})2^{-(n-1)}\\), el límite es \\($l\\).',
    ],
    rng: rng,
  );
}

final Map<String, FamilyGenerator> basicoGenerators = {
  'seq_explicit_terms': (t, rng) =>
      basicoF1(tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), rng: rng),
  'seq_pattern_recognition': (t, rng) =>
      basicoF2(tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), rng: rng),
  'seq_explicit_to_recursive': (t, rng) =>
      basicoF3(tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), rng: rng),
  'seq_immediate_monotonicity': (t, rng) =>
      basicoF4(tupleInt(t, 0), tupleInt(t, 1), rng: rng),
  'seq_elementary_bound': (t, rng) =>
      basicoF5(tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), rng: rng),
  'seq_direct_algebraic_limit': (t, rng) => basicoF6(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), tupleInt(t, 3),
      rng: rng),
  'seq_guided_convergent_recurrence': (t, rng) =>
      basicoF7(tupleInt(t, 0), tupleInt(t, 1), rng: rng),
};
