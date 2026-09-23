import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'auth_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would use get_it or similar for Dependency Injection.
    // For this boilerplate, we're providing it locally at the top level
    // (now inside AuthGate).
    return MaterialApp(
      title: 'Journal Publication Trend',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

