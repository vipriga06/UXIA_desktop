import 'package:flutter/material.dart';

void main() => runApp(const Uxia());

class Uxia extends StatelessWidget {
  const Uxia({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Uxia Administrator';

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        useMaterial3: true,
      ),
      // EJERCICIO 2: Reemplaza HomeView por tu LoginView cuando lo crees.
      // Pista: crea una clase LoginView y asigna home: const LoginView().

    
      home: const LoginView(),
    );
  }
}
class LoginView extends StatelessWidget {
  const LoginView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Center(child: Text('Login')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tancar'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Logejar-se'),
        ),
      ),
    );
  }
}

