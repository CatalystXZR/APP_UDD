import 'dart:math';

import '../../entities/question.dart';
import '../latex_format.dart';
import '../mcq_factory.dart';
import '../rational.dart';
import 'family.dart';
import 'family_text.dart';

const _allowedAlphaBeta = {-2, -1, 1, 2, 3, 4};
const _allowedAB = {-3, -2, -1, 1, 2, 3};
const _allowedB7 = {-3, -2, -1, 1, 2, 3};

Question expertoF1(int p, int q, int r, {Random? rng}) {
  if (p == 0) throw ArgumentError('p debe ser no nulo');
  if (p.abs() > 4 || q.abs() > 5 || r.abs() > 6) {
    throw ArgumentError('parámetro fuera de rango');
  }
  int term(int n) => r + p * (n - 1) * n ~/ 2 + q * (n - 1);
  final ans = term(5);
  return mcq(
    familyId: 'experto-f1',
    level: 'Experto',
    text:
        'Si \\(a_{n+1}-a_n=${pnTerm(p)}${signedTerm(q)}\\) y \\(a_1=$r\\), halle \\(a_5\\).',
    correctText: wrapMath('$ans'),
    distractors: [
      wrapMath('${term(4)}'),
      wrapMath('${term(6)}'),
      wrapMath('${ans + p}'),
      wrapMath('${ans - p}'),
    ],
    solution: [
      'Sumamos telescópicamente las diferencias:',
      '\\[a_n-a_1=\\sum_{k=1}^{n-1}(${pnTerm(p)}${signedTerm(q)})\\]',
      'Con \\[\\sum_{k=1}^{n-1}k=\\frac{n(n-1)}{2}\\] se obtiene:',
      '\\[a_n=$r+\\frac{$p(n-1)n}{2}${signedTerm(q)}(n-1)\\]',
      'Verificando en \\(n=5\\): \\(a_5=$ans\\).',
    ],
    rng: rng,
  );
}

Question expertoF2(int a, int b, int alpha, int beta, {Random? rng}) {
  if (!_allowedAlphaBeta.contains(alpha) ||
      !_allowedAlphaBeta.contains(beta) ||
      alpha == beta) {
    throw ArgumentError('alpha,beta no autorizados');
  }
  if (!_allowedAB.contains(a) || !_allowedAB.contains(b)) {
    throw ArgumentError('A,B no autorizados');
  }
  int term(int n) {
    var pa = 1, pb = 1;
    for (var i = 0; i < n; i++) {
      pa *= alpha;
      pb *= beta;
    }
    return a * pa + b * pb;
  }

  if (term(1).abs() >= 50 || term(2).abs() >= 50) {
    throw ArgumentError('términos iniciales muy grandes');
  }
  final ans = term(3);
  return mcq(
    familyId: 'experto-f2',
    level: 'Experto',
    text:
        'Si \\(b_n=$a($alpha)^n${signedTerm(b)}($beta)^n\\), halle \\(b_3\\).',
    correctText: wrapMath('$ans'),
    distractors: [
      wrapMath('${term(2)}'),
      wrapMath('${term(4)}'),
      wrapMath('${-ans}'),
      wrapMath('${term(1)}'),
    ],
    solution: [
      'Calculamos los datos iniciales:',
      '\\[b_1=${term(1)},\\qquad b_2=${term(2)}\\]',
      'La recurrencia de segundo orden es:',
      '\\[b_{n+2}=${alpha + beta}b_{n+1}${signedTerm(-alpha * beta)}b_n\\]',
      'Verificando: \\(b_3=$ans\\).',
    ],
    rng: rng,
  );
}

Question expertoF3(int p, int q, {Random? rng}) {
  if (!{4, 5, 6, 7}.contains(p)) throw ArgumentError('p no autorizado');
  if (!{1, 2, 3}.contains(q)) throw ArgumentError('q no autorizado');
  final n0 = p - q - 1;
  if (!{1, 2, 3, 4}.contains(n0)) throw ArgumentError('igualdad fuera de rango');
  return mcq(
    familyId: 'experto-f3',
    level: 'Experto',
    text:
        'Sea \\(c_n=\\frac{$p^n}{(n+$q)!}\\). ¿Para qué \\(n\\) se cumple \\(c_{n+1}=c_n\\)?',
    correctText: wrapMath('$n0'),
    distractors: [
      wrapMath('${n0 + 1}'),
      wrapMath('${n0 - 1}'),
      wrapMath('${2 * n0}'),
      wrapMath('0'),
    ],
    solution: [
      'Estudiamos el cociente:',
      '\\[\\frac{c_{n+1}}{c_n}=\\frac{$p}{n+${q + 1}}\\]',
      'Hay igualdad cuando \\(n+$q+1=$p\\):',
      '\\[n=${p - q - 1}\\]',
    ],
    rng: rng,
  );
}

Question expertoF4(int r, int s, {Random? rng}) {
  if (r < 0) throw ArgumentError('r debe ser no negativo');
  if (s - r < 1 || s - r > 6) throw ArgumentError('s-r fuera de rango');
  if (r > 8 || s > 8) throw ArgumentError('r,s superan 8');
  final correct =
      '\\(\\frac{${s - r}}{\\sqrt{n+$s}+\\sqrt{n+$r}}\\)';
  return mcq(
    familyId: 'experto-f4',
    level: 'Experto',
    text:
        'Al racionalizar \\(d_n=\\sqrt{n+$s}-\\sqrt{n+$r}\\) se obtiene:',
    correctText: correct,
    distractors: [
      '\\(\\frac{${s - r}}{\\sqrt{n+$s}-\\sqrt{n+$r}}\\)',
      '\\(\\frac{${s + r}}{\\sqrt{n+$s}+\\sqrt{n+$r}}\\)',
      '\\(\\sqrt{n+$s}+\\sqrt{n+$r}\\)',
      '\\(${s - r}(\\sqrt{n+$s}+\\sqrt{n+$r})\\)',
    ],
    solution: [
      'Multiplicamos por la conjugada:',
      '\\[d_n=\\frac{${s - r}}{\\sqrt{n+$s}+\\sqrt{n+$r}}\\]',
      'Es positiva y decreciente, con cotas que tienden a \\(0\\).',
      'Por lo tanto, converge a \\(0\\).',
    ],
    rng: rng,
  );
}

Question expertoF5(int a, int b, int lambda, int mu, {Random? rng}) {
  for (final v in [a, b]) {
    if (v < 1 || v > 4) throw ArgumentError('A,B fuera de rango');
  }
  if (!(lambda > mu && mu > 0)) throw ArgumentError('lambda>mu>0 exigido');
  if (!{(3, 2), (4, 2), (4, 3), (5, 2)}.contains((lambda, mu))) {
    throw ArgumentError('par (lambda,mu) no autorizado');
  }
  final correctText = a == 1 ? wrapMath('0') : wrapMath('\\ln $a');
  return mcq(
    familyId: 'experto-f5',
    level: 'Experto',
    text:
        'Factorice la potencia dominante y calcule \\(\\lim e_n\\) con \\(e_n=\\ln($a($lambda)^n+$b($mu)^n)-n\\ln$lambda\\).',
    correctText: correctText,
    distractors: [
      wrapMath('\\ln ${a + b}'),
      wrapMath('\\ln $lambda'),
      wrapMath('\\ln $mu'),
      wrapMath('$b'),
    ],
    solution: [
      'Factorizamos la potencia dominante \\($lambda^n\\):',
      '\\[e_n=\\ln\\!\\left($a+$b\\left(\\frac{$mu}{$lambda}\\right)^n\\right)\\]',
      'Como \\(\\left(\\frac{$mu}{$lambda}\\right)^n\\to0\\):',
      '\\[\\lim e_n=${a == 1 ? '0' : '\\ln $a'}\\]',
    ],
    rng: rng,
  );
}

const _allowedQ = {2, 3, 5, 6, 7};

Question expertoF6(int q, int u, {Random? rng}) {
  if (!_allowedQ.contains(q)) throw ArgumentError('Q no autorizado');
  final root = sqrt(q);
  if (u <= root) throw ArgumentError('u debe superar sqrt(Q)');
  if (u * u - q > 6) throw ArgumentError('u^2-Q supera 6');
  final x2 = Rational(u * u + q, 2 * u);
  return mcq(
    familyId: 'experto-f6',
    level: 'Experto',
    text:
        'Sea \\(x_1=$u\\) y \\(x_{n+1}=\\frac12\\left(x_n+\\frac{$q}{x_n}\\right)\\). Halle su límite.',
    correctText: wrapMath('\\sqrt{$q}'),
    distractors: [
      wrapMath('$q'),
      wrapMath('$u'),
      wrapMath('\\sqrt{${q + 1}}'),
      wrapMath('\\sqrt{${q - 1}}'),
    ],
    solution: [
      'Todos los términos son positivos y desde \\(n=2\\):',
      '\\[x_2=\\frac12\\left($u+\\frac{$q}{$u}\\right)=${x2.toLatex()}\\geq\\sqrt{$q}\\]',
      'La sucesión decrece acotada inferiormente por \\(\\sqrt{$q}\\).',
      'Por lo tanto, converge a \\(\\sqrt{$q}\\).',
    ],
    rng: rng,
  );
}

Question expertoF7(int a, int b, int c, {Random? rng}) {
  if (!_allowedB7.contains(b)) throw ArgumentError('B no autorizado');
  if (a.abs() > 5 || c.abs() > 5) throw ArgumentError('|A|,|C| superan 5');
  final even = a + b;
  final odd = a - b;
  final correctText = '${wrapMath('$even')} y ${wrapMath('$odd')}';
  final bTerm = b == 1
      ? '+(-1)^n'
      : b == -1
          ? '-(-1)^n'
          : '${signedTerm(b)}(-1)^n';
  return mcq(
    familyId: 'experto-f7',
    level: 'Experto',
    text:
        'Sea \\(y_n=$a$bTerm${c >= 0 ? '+' : '-'}\\frac{${c.abs()}}{n}\\). ¿Cuáles son los límites de las subsucesiones par e impar?',
    correctText: correctText,
    distractors: [
      '${wrapMath('$odd')} y ${wrapMath('$even')}',
      wrapMath('$a'),
      wrapMath('${a + b + c}'),
      'No existe',
    ],
    solution: [
      'Estudiamos las subsucesiones:',
      '\\[y_{2n}\\longrightarrow ${a + b},\\qquad y_{2n-1}\\longrightarrow ${a - b}\\]',
      'Son dos límites distintos.',
      'Por tanto, \\((y_n)\\) diverge.',
    ],
    rng: rng,
  );
}

final Map<String, FamilyGenerator> expertoGenerators = {
  'seq_reconstruction_from_differences': (t, rng) => expertoF1(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2),
      rng: rng),
  'seq_second_order_recurrence': (t, rng) => expertoF2(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), tupleInt(t, 3),
      rng: rng),
  'seq_monotonicity_regime_change': (t, rng) =>
      expertoF3(tupleInt(t, 0), tupleInt(t, 1), rng: rng),
  'seq_root_monotonicity_bound': (t, rng) =>
      expertoF4(tupleInt(t, 0), tupleInt(t, 1), rng: rng),
  'seq_hidden_dominant_power_limit': (t, rng) => expertoF5(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2), tupleInt(t, 3),
      rng: rng),
  'seq_heron_iteration': (t, rng) =>
      expertoF6(tupleInt(t, 0), tupleInt(t, 1), rng: rng),
  'seq_subsequence_convergence': (t, rng) => expertoF7(
      tupleInt(t, 0), tupleInt(t, 1), tupleInt(t, 2),
      rng: rng),
};
