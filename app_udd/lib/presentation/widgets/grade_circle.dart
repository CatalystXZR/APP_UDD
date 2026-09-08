import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../logic/test_scoring.dart';

class GradeCircle extends StatelessWidget {
  const GradeCircle({super.key, required this.correctCount});

  final int correctCount;

  @override
  Widget build(BuildContext context) {
    final grade = gradeForCorrect(correctCount);
    final color = gradeColor(grade);
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        formatGrade(grade),
        style: const TextStyle(
          color: AppColors.blanco,
          fontSize: 44,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
