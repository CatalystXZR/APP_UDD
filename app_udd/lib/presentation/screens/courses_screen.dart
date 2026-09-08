import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué quieres practicar?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/levels'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _courseCard(
            context,
            icon: Icons.show_chart,
            name: 'Introducción al Cálculo',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Contenido en preparación')),
            ),
          ),
          _courseCard(
            context,
            icon: Icons.functions,
            name: 'Cálculo Diferencial',
            onTap: () => context.go('/contents'),
          ),
        ],
      ),
    );
  }

  Widget _courseCard(BuildContext context,
      {required IconData icon,
      required String name,
      required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Icon(icon, size: 40, color: AppColors.azul),
        title: Text(name,
            style:
                const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.azul),
        onTap: onTap,
      ),
    );
  }
}
