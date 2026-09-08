import 'basico.dart';
import 'experto.dart';
import 'family.dart';
import 'medio.dart';

final Map<String, FamilyGenerator> allFamilyGenerators = {
  ...basicoGenerators,
  ...medioGenerators,
  ...expertoGenerators,
};
