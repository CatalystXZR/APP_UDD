import 'package:flutter/material.dart';

int gradeForCorrect(int correctCount) =>
    (correctCount + 1).clamp(1, 7);

String formatGrade(int grade) => '$grade,0';

String formatTime(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

Color gradeColor(int grade) {
  switch (grade.clamp(1, 7)) {
    case 1:
      return const Color(0xFFD65F5F);
    case 2:
      return const Color(0xFFDF8585);
    case 3:
      return const Color(0xFFA9D7E8);
    case 4:
      return const Color(0xFF79C2DF);
    case 5:
      return const Color(0xFF55A6CE);
    case 6:
      return const Color(0xFF438DBD);
    default:
      return const Color(0xFF397FAE);
  }
}

const levelKeys = ['basico', 'medio', 'experto'];

const levelLabels = {
  'basico': 'Básico',
  'medio': 'Medio',
  'experto': 'Experto',
};

const levelDescriptions = {
  'basico': 'Fundamentos y procedimientos esenciales',
  'medio': 'Mayor análisis y combinación de técnicas',
  'experto': 'Razonamiento, identidades y desafíos multietapa',
};
