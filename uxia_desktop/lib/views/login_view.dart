import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../widgets/logo_header.dart';
import '../widgets/login_dialog.dart';
import '../core/interfaces/i_preferences_service.dart';
import '../services/preferences_service.dart';
import '../models/login_credentials.dart';

/// Login view widget (Single Responsibility: Login UI and orchestration)
/// Follows Dependency Inversion: depends on IPreferencesService interface
class LoginView extends StatefulWidget {
  final IPreferencesService? preferencesService;

  const LoginView({super.key, this.preferencesService});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  late final IPreferencesService _preferencesService;
  late final AnimationController _blurController;
  late final Animation<double> _blurAnimation;

  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
    _loadSavedCredentials();
  }

  /// Initialize services (Dependency Inversion Principle)
  Future<void> _initializeServices() async {
    if (widget.preferencesService != null) {
      _preferencesService = widget.preferencesService!;
    } else {
      _preferencesService = PreferencesService();
    }
  }

  /// Initialize animations
  void _initializeAnimations() {
    _blurController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _blurController, curve: Curves.easeOut));
    _blurController.forward();
  }

  /// Load saved credentials from preferences
  Future<void> _loadSavedCredentials() async {
    final credentials = await _preferencesService.loadCredentials();
    if (credentials.isNotEmpty && mounted) {
      _urlController.text = credentials.url;
      _usernameController.text = credentials.username;
      _passwordController.text = credentials.password;
    }
  }

  /// Save credentials and perform login
  Future<void> _handleLogin() async {
    final credentials = LoginCredentials(
      url: _urlController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!credentials.isValid) {
      _showErrorSnackbar('Per favor, omple tots els camps');
      return;
    }

    await _preferencesService.saveCredentials(credentials);

    if (mounted) {
      _showSuccessSnackbar('Credencials guardades correctament');
    }
  }

  /// Show login dialog with animations
  void _showLoginDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LoginDialog(
          urlController: _urlController,
          usernameController: _usernameController,
          passwordController: _passwordController,
          onSubmit: _handleLogin,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final blurAnimation = Tween<double>(
          begin: 0.0,
          end: 20.0,
        ).animate(curvedAnimation);

        return AnimatedBuilder(
          animation: blurAnimation,
          builder: (context, dialogChild) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurAnimation.value,
                sigmaY: blurAnimation.value,
              ),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(curvedAnimation),
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _blurController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                width: isMobile
                    ? screenWidth - (AppSpacing.md * 2)
                    : AppSizes.buttonWidthDesktop,
                child: ElevatedButton(
                  style: AppButtonStyles.elevated(isMobile: isMobile),
                  onPressed: _showLoginDialog,
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
