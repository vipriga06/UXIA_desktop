import 'package:flutter/material.dart';
import 'theme/app_styles.dart';
import 'views/login_view.dart';

void main() => runApp(const Aida());

/// Root application widget (Single Responsibility: App configuration)
class Aida extends StatelessWidget {
  const Aida({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.I.D.A administrator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginView(),
    );
  }
}
