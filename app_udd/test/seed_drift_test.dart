import 'dart:convert';
import 'dart:io';

import 'package:bvo_matematica/data/repositories/family_repository.dart';
import 'package:bvo_matematica/data/seed/families_seed_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed compilado coincide con families_seed.json', () {
    final fromFile =
        File('assets/seed/families_seed.json').readAsStringSync();
    expect(jsonDecode(familiesSeedJson), jsonDecode(fromFile));
    expect(FamilyRepository.parseSeed(familiesSeedJson).length, 21);
  });
}
