import 'package:flutter/material.dart';
import 'package:uxia_desktop/services/credentials_service.dart';
import 'package:uxia_desktop/services/auth_service.dart';

class LoginController {
  final CredentialsService _credentialsService;
  final IAuthService _authService;

  final TextEditingController urlController;
  final TextEditingController usuariController;
  final TextEditingController contrasenyaController;

  LoginController({
    required CredentialsService credentialsService,
    required IAuthService authService,
  }) : _credentialsService = credentialsService,
       _authService = authService,
       urlController = TextEditingController(),
       usuariController = TextEditingController(),
       contrasenyaController = TextEditingController();

  Future<void> loadSavedCredentials() async {
    final credentials = await _credentialsService.loadCredentials();
    urlController.text = credentials.urlServidor;
    usuariController.text = credentials.nomUsuari;
    contrasenyaController.text = credentials.contrasenya;
  }

  Future<bool> login() async {
    final credentials = LoginCredentials(
      urlServidor: urlController.text.trim(),
      nomUsuari: usuariController.text.trim(),
      contrasenya: contrasenyaController.text,
    );

    if (!credentials.isValid) {
      return false;
    }

    await _credentialsService.saveCredentials(credentials);

    final user = await _authService.login(
      credentials.urlServidor,
      credentials.nomUsuari,
      credentials.contrasenya,
    );

    return user != null;
  }

  void dispose() {
    urlController.dispose();
    usuariController.dispose();
    contrasenyaController.dispose();
  }
}
