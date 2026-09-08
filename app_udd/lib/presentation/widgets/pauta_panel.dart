import 'package:flutter/material.dart';

import '../../../latex/latex_text.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/question.dart';

class PautaPanel extends StatelessWidget {
  const PautaPanel({super.key, required this.questions});

  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Pauta de la prueba',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
        ),
        for (var i = 0; i < questions.length; i++) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pregunta ${i + 1}',
                    style: const TextStyle(
                      color: AppColors.azul,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LatexText(questions[i].text),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Respuesta correcta: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Expanded(
                          child: LatexText(
                              questions[i].correctText)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Resolución',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  for (final line in questions[i].solution)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LatexText(line),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
