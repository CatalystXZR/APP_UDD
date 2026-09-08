import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/navigation/router.dart';

class BvoApp extends StatelessWidget {
  const BvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BVO Matemática',
      theme: buildAppTheme(),
      routerConfig: buildRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}
