import 'dart:io';
import 'dart:math';

import 'package:bvo_matematica/data/models/family_spec.dart';
import 'package:bvo_matematica/data/repositories/family_repository.dart';
import 'package:bvo_matematica/domain/entities/question.dart';
import 'package:bvo_matematica/domain/generators/test_assembler.dart';
import 'package:flutter_test/flutter_test.dart';

List<FamilySpec> loadSpecs() => FamilyRepository.parseSeed(
      File('assets/seed/families_seed.json').readAsStringSync(),
    );

void checkInvariants(Question q) {
  expect(q.options.length, 6, reason: q.familyId);
  expect(q.options.toSet().length, 6, reason: q.familyId);
  expect(q.solution.length, greaterThanOrEqualTo(3), reason: q.familyId);
}

void main() {
  test('parseSeed entrega 21 specs con tuplas consistentes', () {
    final specs = loadSpecs();
    expect(specs.length, 21);
    for (final level in ['basico', 'medio', 'experto']) {
      expect(specs.where((s) => s.levelKey == level).length, 7);
    }
    var tuples = 0;
    for (final s in specs) {
      if (s.tuples.isEmpty) {
        expect(s.domain, isNotNull, reason: s.id);
      } else {
        tuples += s.tuples.length;
      }
    }
    expect(tuples, 147);
  });

  test('arma prueba de 7 con rotacion completa por nivel', () {
    final specs = loadSpecs();
    final asm = TestAssembler();
    for (final level in ['basico', 'medio', 'experto']) {
      final memory = <String, List<String>>{};
      final test =
          asm.build(levelKey: level, specs: specs, rng: Random(5), memory: memory);
      expect(test.length, 7);
      expect(test.map((q) => q.familyId).toSet().length, 7);
      expect(test.every((q) => q.level == _label(level)), isTrue);
      for (final q in test) {
        checkInvariants(q);
      }
      expect(memory[level]!.length, 7);
    }
  });

  test('misma semilla reproduce la misma prueba', () {
    final specs = loadSpecs();
    final asm = TestAssembler();
    final a = asm.build(levelKey: 'medio', specs: specs, rng: Random(42));
    final b = asm.build(levelKey: 'medio', specs: specs, rng: Random(42));
    expect(
        a.map((q) => q.text).toList(), b.map((q) => q.text).toList());
    expect(a.map((q) => q.correct).toList(),
        b.map((q) => q.correct).toList());
  });

  test('novedad prioriza familias no vistas', () {
    final specs = loadSpecs();
    final asm = TestAssembler();
    final memory = <String, List<String>>{
      'basico': ['basico-f1', 'basico-f2', 'basico-f3'],
    };
    final test = asm.build(
        levelKey: 'basico', specs: specs, rng: Random(1), memory: memory);
    expect(
        test.take(4).map((q) => q.familyId),
        containsAll(['basico-f4', 'basico-f5', 'basico-f6', 'basico-f7']));
  });

  test('firma de mecanismo ignora solo numeros', () {
    expect(mechanismSignature(r'Calcule \(a_8\) con \(x+8\)'),
        mechanismSignature(r'Calcule \(a_5\) con \(x+3\)'));
    expect(mechanismSignature(r'Halle \(a_8\)'),
        isNot(mechanismSignature(r'Halle el límite')));
  });

  test('banco reducido varia tuplas sin repetir texto', () {
    final specs =
        loadSpecs().where((s) => s.levelKey == 'basico').take(2).toList();
    final test = TestAssembler().build(
        levelKey: 'basico', specs: specs, rng: Random(3));
    expect(test.length, 7);
    expect(test.map((q) => q.text).toSet().length, 7);
  });
}

String _label(String key) =>
    {'basico': 'Básico', 'medio': 'Medio', 'experto': 'Experto'}[key]!;
