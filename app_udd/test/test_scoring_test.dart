import 'package:bvo_matematica/presentation/logic/test_scoring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nota chilena 1..7 desde correctas', () {
    expect(gradeForCorrect(0), 1);
    expect(gradeForCorrect(3), 4);
    expect(gradeForCorrect(6), 7);
    expect(gradeForCorrect(7), 7);
    expect(gradeForCorrect(99), 7);
  });

  test('formato de nota y tiempo', () {
    expect(formatGrade(4), '4,0');
    expect(formatTime(60), '1:00');
    expect(formatTime(90), '1:30');
    expect(formatTime(5), '0:05');
  });

  test('color de nota por tramo', () {
    expect(gradeColor(1), const Color(0xFFD65F5F));
    expect(gradeColor(4), const Color(0xFF79C2DF));
    expect(gradeColor(7), const Color(0xFF397FAE));
  });
}
