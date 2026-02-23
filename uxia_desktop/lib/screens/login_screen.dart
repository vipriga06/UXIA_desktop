import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/server_discovery.dart';
import '../services/settings_manager.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import '../logo_widget.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final SettingsManager settingsManager;
  final AuthService? authService;
  final ServerDiscovery? serverDiscovery;

  const LoginScreen({
    super.key,
    required this.settingsManager,
    this.authService,
    this.serverDiscovery,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final _urlCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _savedUrl;

  bool _showPassword = false;
  bool _isLoading = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService =
        widget.authService ??
        AuthService(settingsManager: widget.settingsManager);
    _loadSavedUrl();
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
          ],
        ),
      ),
    );
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
    if (mounted && savedUrl != null && savedUrl.isNotEmpty) {
      _savedUrl = savedUrl;
      _urlCtrl.text = savedUrl;
    }
    final savedUser = await widget.settingsManager.getUser();
    if (mounted && savedUser != null && savedUser.isNotEmpty) {
      _userCtrl.text = savedUser;
    }
  }

  Future<void> _handleLogin() async {
    final urlToUse = _savedUrl ?? _urlCtrl.text;
    final error = Validators.validateLoginFields(
      url: urlToUse,
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
      // Guardar usuario introducido
      await widget.settingsManager.saveUser(_userCtrl.text);

      String discoveredUrl;
      if (_savedUrl != null && _savedUrl!.isNotEmpty) {
        discoveredUrl = _savedUrl!;
      } else {
        final inputUrl = _urlCtrl.text.trim();
        final foundUrl = await ServerDiscovery.discoverServer(inputUrl);
        if (foundUrl == null) {
          if (mounted) {
            CommonWidgets.showErrorDialog(
              context: context,
              message: '${AppConstants.msgServerError} $inputUrl',
            );
          }
          setState(() => _isLoading = false);
          return;
        }
        discoveredUrl = foundUrl;
        await widget.settingsManager.saveUrl(discoveredUrl);
        _savedUrl = discoveredUrl;
      }

      var email = _userCtrl.text;
      if (!_userCtrl.text.contains('@')) {
        final foundEmail = await _authService.getEmailFromUsername(
          discoveredUrl,
          _userCtrl.text,
        );
        if (foundEmail != null) {
          email = foundEmail;
        }
      }

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
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        Navigator.of(context).pop();
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
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        CommonWidgets.showErrorDialog(
          context: context,
          message: '${AppConstants.msgConnectionError}: $e',
        );
        setState(() => _isLoading = false);
      }
      if (kDebugMode) debugPrint('Login error: $e');
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
                if (_savedUrl == null)
                  TextField(
                    controller: _urlCtrl,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      labelText: 'URL del servidor',
                      prefixIcon: Icon(Icons.cloud),
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (_savedUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _savedUrl!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Cambiar URL',
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  await widget.settingsManager.saveUrl('');
                                  setStateDialog(() {
                                    _savedUrl = null;
                                    _urlCtrl.text = '';
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _userCtrl,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: "Nom d'usuari o email",
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
