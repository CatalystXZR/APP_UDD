import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.azul,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'BVO',
                  style: TextStyle(
                    color: AppColors.blanco,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ENTRENAMIENTO MATEMÁTICO UNIVERSITARIO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gris,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Prepara tus pruebas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () => context.go('/levels'),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
