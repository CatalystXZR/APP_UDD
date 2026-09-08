import 'dart:math';

import '../../data/models/family_spec.dart';
import '../../domain/entities/question.dart';
import '../generators/families/registries.dart';

class AuditReport {
  AuditReport();

  int generated = 0;
  final List<String> errors = [];
  final List<String> warnings = [];

  bool get ok => errors.isEmpty;
}

int _count(String src, String token) {
  var n = 0;
  var i = src.indexOf(token);
  while (i != -1) {
    n++;
    i = src.indexOf(token, i + token.length);
  }
  return n;
}

List<String> auditQuestion(Question q, String tag) {
  final findings = <String>[];
  final joined =
      ([q.text, ...q.options, ...q.solution]).join(' ');
  if (q.text.trim().isEmpty) findings.add('$tag: enunciado vacío');
  if (!q.text.contains(r'\(') && !q.text.contains(r'\[')) {
    findings.add('$tag: enunciado sin matemática');
  }
  if (q.options.length != 6) {
    findings.add('$tag: ${q.options.length} alternativas (se exigen 6)');
  }
  if (q.options.toSet().length != q.options.length) {
    findings.add('$tag: alternativas repetidas');
  }
  if (q.options.any((o) => o.trim().isEmpty)) {
    findings.add('$tag: alternativa vacía');
  }
  if (q.correct < 0 || q.correct >= q.options.length) {
    findings.add('$tag: índice correcto inválido');
  }
  if (q.solution.length < 3) {
    findings.add('$tag: pauta con menos de 3 líneas');
  }
  if (q.solution.any((s) => s.trim().isEmpty)) {
    findings.add('$tag: línea de pauta vacía');
  }
  if (joined.contains('Math input error')) {
    findings.add('$tag: Math input error literal');
  }
  if (_count(joined, r'\(') != _count(joined, r'\)') ||
      _count(joined, r'\[') != _count(joined, r'\]')) {
    findings.add('$tag: delimitadores desbalanceados');
  }
  return findings;
}

class QuestionAuditor {
  QuestionAuditor({this.extraRandomBuilds = 0});

  final int extraRandomBuilds;

  AuditReport run(List<FamilySpec> specs, {int seed = 7}) {
    final report = AuditReport();
    final rng = Random(seed);
    for (final spec in specs) {
      final gen = allFamilyGenerators[spec.generatorKey];
      if (gen == null) {
        report.errors.add('${spec.id}: sin generador registrado');
        continue;
      }
      if (spec.tuples.isEmpty && spec.domain == null) {
        report.errors.add('${spec.id}: sin tuplas ni dominio');
        continue;
      }
      final tag = spec.id;
      final List<Map<String, dynamic>> work = spec.tuples.isEmpty
          ? [_sampleDomain(spec)]
          : spec.tuples;
      for (final tuple in work) {
        try {
          final q = gen(Map<String, dynamic>.from(tuple), rng);
          report.generated++;
          report.errors.addAll(auditQuestion(q, tag));
        } catch (err) {
          report.errors.add('$tag: $err');
        }
        if (report.errors.length > 100) return report;
      }
      for (var i = 0; i < extraRandomBuilds; i++) {
        try {
          final tuple = spec.tuples.isEmpty
              ? _sampleDomain(spec)
              : spec.tuples[rng.nextInt(spec.tuples.length)];
          final q = gen(Map<String, dynamic>.from(tuple), rng);
          report.generated++;
          report.errors.addAll(auditQuestion(q, '$tag~r$i'));
        } catch (err) {
          report.errors.add('$tag~r$i: $err');
        }
        if (report.errors.length > 100) return report;
      }
    }
    if (specs.length != 21) {
      report.warnings.add('banco con ${specs.length} familias (se esperan 21)');
    }
    return report;
  }

  Map<String, dynamic> _sampleDomain(FamilySpec spec) {
    final rng = Random(spec.id.hashCode);
    return {
      'values': spec.domain!.entries.map((e) {
        final v = e.value;
        if (v is List) return v[rng.nextInt(v.length)];
        if (v is Map) {
          final min = (v['min'] as num).toInt();
          final max = (v['max'] as num).toInt();
          return min + rng.nextInt(max - min + 1);
        }
        return v;
      }).toList(),
      'raw': [],
    };
  }
}
