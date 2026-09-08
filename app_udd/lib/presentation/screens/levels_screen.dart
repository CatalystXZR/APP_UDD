import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona la dificultad')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.levels.length,
        itemBuilder: (context, i) {
          final level = AppConstants.levels[i];
          return Card(
            child: ListTile(
              title: Text(level),
              subtitle: Text(
                '${AppConstants.secondsPerQuestion[level]} segundos por pregunta',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
