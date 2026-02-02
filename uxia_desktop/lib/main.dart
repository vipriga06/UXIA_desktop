import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uxia_desktop/theme/app_styles.dart';

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
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class LogoHeader extends StatefulWidget {
  const LogoHeader({super.key});

  @override
  State<LogoHeader> createState() => _LogoHeaderState();
}

class _LogoHeaderState extends State<LogoHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SvgPicture.asset(
          'assets/logos/logo_completo.svg',
          height: isMobile ? AppSizes.logoHeightMobile : AppSizes.logoHeightDesktop,
          fit: BoxFit.contain,
        ),
      ),
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
      theme: AppTheme.light,
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

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  late final PreferencesService _preferencesService;
  late final TextEditingController _urlController;
  late final TextEditingController _usuariController;
  late final TextEditingController _contrasenyaController;
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _preferencesService = PreferencesService();
    _urlController = TextEditingController();
    _usuariController = TextEditingController();
    _contrasenyaController = TextEditingController();
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOut),
    );
    _carregarDades();
    _blurController.forward();
  }

  @override
  void dispose() {
    _blurController.dispose();
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _LoginDialog(
          urlController: _urlController,
          usuariController: _usuariController,
          contrasenyaController: _contrasenyaController,
          onEntrar: _guardarDades,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final blurAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(curvedAnimation);
        return AnimatedBuilder(
          animation: blurAnimation,
          builder: (context, dialogChild) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurAnimation.value,
                sigmaY: blurAnimation.value,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
                child: FadeTransition(
                  opacity: curvedAnimation,
                  child: dialogChild,
                ),
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          isMobile ? AppSizes.appBarHeightMobile : AppSizes.appBarHeightDesktop,
        ),
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _blurAnimation.value,
                  sigmaY: _blurAnimation.value,
                ),
                child: child,
              );
            },
            child: AppBar(
              toolbarHeight: isMobile
                  ? AppSizes.appBarHeightMobile
                  : AppSizes.appBarHeightDesktop,
              title: const LogoHeader(),
              centerTitle: true,
              backgroundColor: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: AppInsets.screenPadding(isMobile: isMobile),
              child: SizedBox(
                width: isMobile ? screenWidth - (AppSpacing.md * 2) : AppSizes.buttonWidthDesktop,
                child: ElevatedButton(
                  style: AppButtonStyles.elevated(isMobile: isMobile),
                  onPressed: _mostrarDialogLogin,
                  child: Text(
                    'Logejar-se',
                    style: AppTextStyles.headlineSmall(
                      context,
                      fontSize: isMobile
                          ? AppSizes.buttonFontMobile
                          : AppSizes.buttonFontDesktop,
                    ),
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

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: AlertDialog(
        backgroundColor: AppColors.background.withValues(alpha: 0.9),
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
              _AnimatedInputField(
                controller: urlController,
                label: 'URL del servidor',
                icon: Icons.cloud,
                delay: 0,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _AnimatedInputField(
                controller: usuariController,
                label: 'Nom d\'usuari',
                icon: Icons.person,
                delay: 100,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _AnimatedInputField(
                controller: contrasenyaController,
                label: 'Contrasenya',
                obscureText: true,
                icon: Icons.lock,
                delay: 200,
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
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Entrar'),
        ),
      ],
        ),
      );
  }
}

class _AnimatedInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final IconData icon;
  final int delay;

  const _AnimatedInputField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    required this.icon,
    this.delay = 0,
  });

  @override
  State<_AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<_AnimatedInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: InputField(
          controller: widget.controller,
          label: widget.label,
          obscureText: widget.obscureText,
          icon: widget.icon,
        ),
      ),
    );
  }
}
