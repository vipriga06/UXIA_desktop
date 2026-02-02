import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(const Aida());

// ============================================================================
// MODELS
// ============================================================================

class LoginCredentials {
  String urlServidor;
  String nomUsuari;
  String contrasenya;

  LoginCredentials({
    this.urlServidor = '',
    this.nomUsuari = '',
    this.contrasenya = '',
  });
}

// ============================================================================
// SERVICES
// ============================================================================

class PreferencesService {
  static const _urlKey = 'url';
  static const _usuariKey = 'usuari';
  static const _contrasenyaKey = 'contrasenya';

  Future<LoginCredentials> carregarDades() async {
    final prefs = await SharedPreferences.getInstance();
    return LoginCredentials(
      urlServidor: prefs.getString(_urlKey) ?? '',
      nomUsuari: prefs.getString(_usuariKey) ?? '',
      contrasenya: prefs.getString(_contrasenyaKey) ?? '',
    );
  }

  Future<void> guardarDades(LoginCredentials credencials) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_urlKey, credencials.urlServidor),
      prefs.setString(_usuariKey, credencials.nomUsuari),
      prefs.setString(_contrasenyaKey, credencials.contrasenya),
    ]);
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final IconData icon;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SvgPicture.asset(
      'assets/logos/logo_completo.svg',
      height: isMobile ? 100 : 220,
      fit: BoxFit.contain,
    );
  }
}

// ============================================================================
// APP ROOT
// ============================================================================

class Aida extends StatelessWidget {
  const Aida({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.I.D.A administrator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8bc6cc),
          secondary: const Color(0xFF476568),
          tertiary: const Color(0xFFffffff),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFffffff),
      ),
      home: const LoginView(),
    );
  }
}

// ============================================================================
// LOGIN VIEW
// ============================================================================

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final PreferencesService _preferencesService;
  late final TextEditingController _urlController;
  late final TextEditingController _usuariController;
  late final TextEditingController _contrasenyaController;

  @override
  void initState() {
    super.initState();
    _preferencesService = PreferencesService();
    _urlController = TextEditingController();
    _usuariController = TextEditingController();
    _contrasenyaController = TextEditingController();
    _carregarDades();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usuariController.dispose();
    _contrasenyaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDades() async {
    final credencials = await _preferencesService.carregarDades();
    setState(() {
      _urlController.text = credencials.urlServidor;
      _usuariController.text = credencials.nomUsuari;
      _contrasenyaController.text = credencials.contrasenya;
    });
  }

  Future<void> _guardarDades() async {
    final credencials = LoginCredentials(
      urlServidor: _urlController.text,
      nomUsuari: _usuariController.text,
      contrasenya: _contrasenyaController.text,
    );
    await _preferencesService.guardarDades(credencials);
  }

  void _mostrarDialogLogin() {
    showDialog(
      context: context,
      builder: (dialogContext) => _LoginDialog(
        urlController: _urlController,
        usuariController: _usuariController,
        contrasenyaController: _contrasenyaController,
        onEntrar: _guardarDades,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isMobile ? 88 : 160,
        title: const LogoHeader(),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : 32.0,
              vertical: isMobile ? 24.0 : 32.0,
            ),
            child: SizedBox(
              width: isMobile ? screenWidth - 32 : 280,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 16 : 20,
                    horizontal: isMobile ? 24 : 32,
                  ),
                ),
                onPressed: _mostrarDialogLogin,
                child: Text(
                  'Logejar-se',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LOGIN DIALOG
// ============================================================================

class _LoginDialog extends StatelessWidget {
  final TextEditingController urlController;
  final TextEditingController usuariController;
  final TextEditingController contrasenyaController;
  final Future<void> Function() onEntrar;

  const _LoginDialog({
    required this.urlController,
    required this.usuariController,
    required this.contrasenyaController,
    required this.onEntrar,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      title: const Center(child: Text('Inici de sessió')),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 20,
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 280 : 400,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                controller: urlController,
                label: 'URL del servidor',
                icon: Icons.cloud,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              InputField(
                controller: usuariController,
                label: 'Nom d\'usuari',
                icon: Icons.person,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              InputField(
                controller: contrasenyaController,
                label: 'Contrasenya',
                obscureText: true,
                icon: Icons.lock,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            await onEntrar();
            Navigator.of(context).pop();
          },
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}
