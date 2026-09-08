import 'dart:math';

import '../../data/models/family_spec.dart';
import '../entities/question.dart';
import 'families/registries.dart';

String normalizeQuestionText(String text) {
  var t = text.toLowerCase();
  t = t
      .replaceAll(r'\(', '')
      .replaceAll(r'\)', '')
      .replaceAll(r'\[', '')
      .replaceAll(r'\]', '');
  t = t.replaceAll(RegExp(r'\\(?:cfrac|dfrac)'), r'\frac');
  t = t.replaceAll(
      RegExp(r'\\(?:left|right|displaystyle|textstyle|limits|nolimits)'), '');
  t = t.replaceAll(RegExp(r'\\[,;:!]'), '');
  t = t.replaceAll(RegExp(r'\\(?:quad|qquad)'), '');
  t = t.replaceAll(RegExp(r'^\s*(?:calcule|determine|evalúe|evalue|halle)\s*'), '');
  t = t.replaceAll(RegExp(r'[.\s]+$'), '');
  t = t.replaceAll(RegExp(r'\s+'), '');
  if (t.startsWith('(\\lim') && t.endsWith(')')) {
    t = t.substring(1, t.length - 1);
  }
  return t;
}

String mechanismSignature(String text) {
  return normalizeQuestionText(text)
      .replaceAll(RegExp(r'-?\d+(?:[.,]\d+)?'), '#')
      .replaceAll(r'\tfrac', r'\frac');
}

class TestAssembler {
  TestAssembler({this.questionsPerTest = 7, this.maxAttempts = 200});

  final int questionsPerTest;
  final int maxAttempts;

  List<Question> build({
    required String levelKey,
    required List<FamilySpec> specs,
    Random? rng,
    Map<String, List<String>>? memory,
  }) {
    final rand = rng ?? Random();
    final pool =
        specs.where((s) => s.levelKey == levelKey).toList();
    if (pool.isEmpty) throw StateError('Sin familias para $levelKey');
    for (final s in pool) {
      if (!allFamilyGenerators.containsKey(s.generatorKey)) {
        throw StateError('Sin generador: ${s.generatorKey}');
      }
      if (s.tuples.isEmpty && s.domain == null) {
        throw StateError('Familia sin tuplas ni dominio: ${s.id}');
      }
    }

    final previous = memory?[levelKey] ?? const <String>[];
    final novel =
        pool.where((s) => !previous.contains(s.id)).toList()..shuffle(rand);
    final seen =
        pool.where((s) => previous.contains(s.id)).toList()..shuffle(rand);
    final ordered = [...novel, ...seen];

    final result = <Question>[];
    final usedMechanisms = <String>{};
    final usedTexts = <String>{};
    final usedTuples = <String>{};
    var attempts = 0;

    while (result.length < questionsPerTest && attempts < maxAttempts) {
      attempts++;
      final spec = ordered[result.length % ordered.length];
      final gen = allFamilyGenerators[spec.generatorKey]!;
      final tuple = _pickTuple(spec, usedTuples, rand);
      final q = gen(tuple, rand);
      final sig = mechanismSignature(q.text);
      final strict = attempts <= maxAttempts ~/ 2;
      if (strict ? usedMechanisms.contains(sig) : usedTexts.contains(normalizeQuestionText(q.text))) {
        continue;
      }
      usedMechanisms.add(sig);
      usedTexts.add(normalizeQuestionText(q.text));
      usedTuples.add('${spec.generatorKey}#${spec.tuples.indexOf(tuple)}');
      result.add(q);
    }

    if (result.length < questionsPerTest) {
      throw StateError('No se pudo completar la prueba para $levelKey');
    }

    if (memory != null) {
      memory[levelKey] = result.map((q) => q.familyId).toList();
    }
    return result;
  }

  Map<String, dynamic> _pickTuple(
    FamilySpec spec,
    Set<String> usedTuples,
    Random rand,
  ) {
    if (spec.tuples.isEmpty) {
      return {'values': _sampleDomain(spec.domain!, rand), 'raw': []};
    }
    final fresh = spec.tuples
        .where((t) =>
            !usedTuples.contains('${spec.generatorKey}#${spec.tuples.indexOf(t)}'))
        .toList();
    final candidates = fresh.isEmpty ? spec.tuples : fresh;
    return candidates[rand.nextInt(candidates.length)];
  }

  List<dynamic> _sampleDomain(Map<String, dynamic> domain, Random rand) {
    return domain.entries.map((e) {
      final v = e.value;
      if (v is List) return v[rand.nextInt(v.length)];
      if (v is Map) {
        final min = (v['min'] as num).toInt();
        final max = (v['max'] as num).toInt();
        return min + rand.nextInt(max - min + 1);
      }
      return v;
    }).toList();
  }
}
