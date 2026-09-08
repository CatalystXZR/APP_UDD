import 'dart:math';

import '../entities/question.dart';

const _fallbackOptions = [
  r'\(0\)',
  r'\(1\)',
  r'\(-1\)',
  r'\(\infty\)',
  'No existe',
  r'\(\frac12\)',
  r'\(2\)',
];

List<String> uniqueOptions(String correctText, List<String> distractors) {
  final out = <String>[];
  void add(String s) {
    if (s.isNotEmpty && !out.contains(s)) out.add(s);
  }

  add(correctText);
  for (final d in distractors) {
    add(d);
  }
  for (final f in _fallbackOptions) {
    add(f);
  }

  if (out.length < 6) {
    throw StateError('No fue posible construir 6 alternativas únicas');
  }
  return out.sublist(0, 6);
}

({List<String> options, int correct}) shuffleWithCorrect(
  List<String> values,
  Random rng,
) {
  final tagged = values.indexed
      .map((e) => (value: e.$2, correct: e.$1 == 0))
      .toList();
  for (var i = tagged.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final t = tagged[i];
    tagged[i] = tagged[j];
    tagged[j] = t;
  }
  return (
    options: tagged.map((e) => e.value).toList(),
    correct: tagged.indexWhere((e) => e.correct),
  );
}

Question mcq({
  required String familyId,
  required String level,
  required String text,
  required String correctText,
  required List<String> distractors,
  required List<String> solution,
  Map<String, Object?> meta = const {},
  Random? rng,
}) {
  final values = uniqueOptions(correctText, distractors);
  final shuffled = shuffleWithCorrect(values, rng ?? Random());
  return Question(
    familyId: familyId,
    level: level,
    text: text,
    options: shuffled.options,
    correct: shuffled.correct,
    solution: solution,
    meta: meta,
  );
}
