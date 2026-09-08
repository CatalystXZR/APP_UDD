import 'dart:math';

import 'package:bvo_matematica/data/repositories/family_repository.dart';
import 'package:bvo_matematica/data/seed/families_seed_data.dart';
import 'package:bvo_matematica/domain/generators/families/registries.dart';
import 'package:bvo_matematica/domain/validators/question_auditor.dart';
import 'package:bvo_matematica/latex/latex_parser.dart';
import 'package:flutter_math_fork/src/parser/tex/parse_error.dart';
import 'package:flutter_math_fork/src/parser/tex/parser.dart';
import 'package:flutter_math_fork/src/parser/tex/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('auditoria estructural del banco completo', () {
    final specs = FamilyRepository.parseSeed(familiesSeedJson);
    final report = QuestionAuditor(extraRandomBuilds: 20).run(specs);
    expect(report.generated, greaterThan(147 + 20 * 21 - 1));
    expect(report.errors, isEmpty,
        reason: report.errors.take(10).join('\n'));
  });

  test('toda expresion LaTeX del banco parsea sin errores', () async {
    final specs = FamilyRepository.parseSeed(familiesSeedJson);
    var expressions = 0;
    final failures = <String>[];
    for (final spec in specs) {
      final gen = allFamilyGenerators[spec.generatorKey]!;
      final work = spec.tuples.isEmpty
          ? [
              {
                'values': [2, 0],
                'raw': []
              }
            ]
          : spec.tuples;
      for (final tuple in work) {
        final q = gen(Map<String, dynamic>.from(tuple), Random(11));
        for (final line in [q.text, ...q.options, ...q.solution]) {
          for (final seg in parseLatex(line)) {
            if (seg.isText || seg.content.trim().isEmpty) continue;
            expressions++;
            try {
              TexParser(seg.content, const TexParserSettings()).parse();
            } on ParseException catch (e) {
              failures.add('${spec.id}: ${e.message} << ${seg.content}');
            }
          }
        }
      }
    }
    expect(expressions, greaterThan(1000));
    expect(failures, isEmpty, reason: failures.take(10).join('\n'));
  });
}
