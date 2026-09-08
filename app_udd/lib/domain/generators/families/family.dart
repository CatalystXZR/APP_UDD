import 'dart:math';

import '../../entities/question.dart';

typedef FamilyGenerator = Question Function(
    Map<String, dynamic> tuple, Random rng);

List<dynamic> tupleValues(Map<String, dynamic> tuple) =>
    tuple['values'] as List;

List<String> tupleRaw(Map<String, dynamic> tuple) =>
    (tuple['raw'] as List).map((e) => e.toString()).toList();

int tupleInt(Map<String, dynamic> tuple, int pos) =>
    (tupleValues(tuple)[pos] as num).toInt();
