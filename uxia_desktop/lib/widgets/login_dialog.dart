import 'package:flutter/material.dart';
import '../widgets/input_field.dart';
import '../theme/app_styles.dart';

class LoginDialog extends StatelessWidget {
  final TextEditingController urlController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const LoginDialog({
    super.key,
    required this.urlController,
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
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
            constraints: BoxConstraints(maxWidth: isMobile ? 280 : 400),
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
                  controller: usernameController,
                  label: 'Nom d\'usuari',
                  icon: Icons.person,
                  delay: 100,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                _AnimatedInputField(
                  controller: passwordController,
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
            child: const Text('Cancel·lar'),
          ),
          FilledButton(
            onPressed: onSubmit,
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
