import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../logic/test_scoring.dart';

class TimerRing extends StatelessWidget {
  const TimerRing(
      {super.key, required this.secondsLeft, required this.total});

  final int secondsLeft;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : secondsLeft / total;
    final urgent = secondsLeft <= 10;
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: AppColors.borde,
            valueColor: AlwaysStoppedAnimation(
                urgent ? AppColors.rojo : AppColors.azul),
          ),
          Text(
            formatTime(secondsLeft),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: urgent ? AppColors.rojo : AppColors.texto,
            ),
          ),
        ],
      ),
    );
  }
}
