import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: const LoginView(),
    );
  }
}
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _urlController;
  late TextEditingController _usuariController;
  late TextEditingController _contrasenyaController;
  late recordarDades _dades;

  @override
  void initState() {
    super.initState();
    _dades = recordarDades('', '', '');
    _urlController = TextEditingController();
    _usuariController = TextEditingController();
    _contrasenyaController = TextEditingController();
    _carregarDades();
  }

  Future<void> _carregarDades() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dades.urlServidor = prefs.getString('url') ?? '';
      _dades.nomUsuari = prefs.getString('usuari') ?? '';
      _dades.contrasenya = prefs.getString('contrasenya') ?? '';
      
      _urlController.text = _dades.urlServidor;
      _usuariController.text = _dades.nomUsuari;
      _contrasenyaController.text = _dades.contrasenya;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usuariController.dispose();
    _contrasenyaController.dispose();
    super.dispose();
  }

  Future<void> _guardarDades() async {
    final prefs = await SharedPreferences.getInstance();
    _dades.urlServidor = _urlController.text;
    _dades.nomUsuari = _usuariController.text;
    _dades.contrasenya = _contrasenyaController.text;
    
    await prefs.setString('url', _dades.urlServidor);
    await prefs.setString('usuari', _dades.nomUsuari);
    await prefs.setString('contrasenya', _dades.contrasenya);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inici de sessió'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Center(child: Text('Inici de sessió')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'URL del servidor',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _usuariController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nom d\'usuari',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contrasenyaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Contrasenya',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      _guardarDades();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Entrar'),
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


class recordarDades {
  String urlServidor = '';
  String nomUsuari = '';
  String contrasenya = '';

  recordarDades(this.urlServidor, this.nomUsuari, this.contrasenya);
}