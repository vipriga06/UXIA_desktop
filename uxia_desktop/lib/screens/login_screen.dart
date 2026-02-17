import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/server_discovery.dart';
import '../services/settings_manager.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import '../logo_widget.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final SettingsManager settingsManager;

  const LoginScreen({super.key, required this.settingsManager});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    // Permite login directo con token
    Future<void> _loginWithToken(String token) async {
      const url = 'https://uxia3.ieti.site';
      try {
        // Guardar token y url
        await widget.settingsManager.saveToken(token);
        await widget.settingsManager.saveUrl(url);

        // Verificar token llamando a getAuthUser
        final apiService = ApiService(baseUrl: url, token: token);
        final authUser = await apiService.getAuthUser();
        if (authUser != null) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  settingsManager: widget.settingsManager,
                  urlServidor: url,
                  token: token,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            CommonWidgets.showErrorDialog(
              context: context,
              message: 'Token inválido o expirado.',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          CommonWidgets.showErrorDialog(
            context: context,
            message: 'Error verificando token: $e',
          );
        }
      }
    }
  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WidgetLogo(),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showLoginDialog,
              icon: const Icon(Icons.login),
              label: const Text('Logejar-se'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 16 : 20,
                  horizontal: isMobile ? 24 : 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loginWithToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2MjJmZDgwNi05NmU1LTRhZWItOTkyNC1mNDlmNjE1N2E1YjYiLCJ0aW1lc3RhbXAiOjE3NzEzNTI0MzkxMzQsImlhdCI6MTc3MTM1MjQzOSwiZXhwIjoxNzcxOTU3MjM5fQ.pgsflap7WgyttFrjhW2dYzp72a4yTjcaVh3B3RNlwlE'),
              icon: const Icon(Icons.vpn_key),
              label: const Text('Login con token'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 16 : 20,
                  horizontal: isMobile ? 24 : 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final _urlCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(settingsManager: widget.settingsManager);
    _loadSavedUrl();
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUrl() async {
    final savedUrl = await widget.settingsManager.getUrl();
    if (mounted && savedUrl != null) {
      _urlCtrl.text = savedUrl;
    }
  }

  Future<void> _handleLogin() async {
    // Validaciones
    final error = Validators.validateLoginFields(
      url: _urlCtrl.text,
      user: _userCtrl.text,
      password: _passCtrl.text,
    );

    if (error != null) {
      if (mounted) {
        CommonWidgets.showErrorDialog(context: context, message: error);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Agregar esquema si falta
      // Forzar siempre la URL base a https://uxia3.ieti.site
      const url = 'https://uxia3.ieti.site';
      await widget.settingsManager.saveUrl(url);
      // Descubrir servidor (probar diferentes puertos)
      final discoveredUrl = await ServerDiscovery.discoverServer(url);
      if (discoveredUrl == null) {
        if (mounted) {
          CommonWidgets.showErrorDialog(
            context: context,
            message: '${AppConstants.msgServerError} $url',
          );
        }
        return;
      }
      // Guardar URL descubierta
      await widget.settingsManager.saveUrl(discoveredUrl);

      // Obtener email si se proporciona nickname
      var email = _userCtrl.text;
      if (!_userCtrl.text.contains('@')) {
        final foundEmail = await _authService.getEmailFromUsername(
          discoveredUrl,
          _userCtrl.text,
        );
        if (foundEmail == null) {
          if (mounted) {
            CommonWidgets.showErrorDialog(
              context: context,
              message: 'Usuari no trobat',
            );
          }
          return;
        }
        email = foundEmail;
      }

      // Login
      final result = await _authService.loginAdmin(
        urlBase: discoveredUrl,
        email: email,
        password: _passCtrl.text,
      );

      if (!result.success) {
        if (mounted) {
          CommonWidgets.showErrorDialog(
            context: context,
            message: result.message,
          );
        }
        return;
      }

      // Guardar token
      if (result.token != null) {
        await widget.settingsManager.saveToken(result.token!);
      }

      if (mounted) {
        // Mostrar diálogo de éxito y navegar
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Login correcte'),
            content: const Text('Benvingut'),
          ),
        );

        await Future.delayed(AppConstants.loginDialogDuration);
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar diálogo
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                settingsManager: widget.settingsManager,
                urlServidor: discoveredUrl,
                token: result.token!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CommonWidgets.showErrorDialog(
          context: context,
          message: '${AppConstants.msgConnectionError}: $e',
        );
      }
      if (kDebugMode) debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Inici de sessió'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _urlCtrl,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'URL del servidor',
                    prefixIcon: Icon(Icons.cloud),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _userCtrl,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'usuari o email',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CommonWidgets.secureTextField(
                  controller: _passCtrl,
                  label: 'Contrasenya',
                  icon: Icons.lock,
                  obscureText: !_showPassword,
                  onToggleObscure: _isLoading
                      ? null
                      : () => setStateDialog(
                          () => _showPassword = !_showPassword,
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
