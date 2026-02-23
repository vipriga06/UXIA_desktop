import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Widgets reutilizables
class CommonWidgets {
  /// Botón primario estándar
  static Widget primaryButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    double width = double.infinity,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  /// Botón peligroso (rojo)
  static Widget dangerButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    double width = double.infinity,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }

  /// Campo de texto seguro
  static Widget secureTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// Diálogo de confirmación simple
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Acceptar',
    String cancelLabel = 'Cancel·lar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Diálogo de información
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Acceptar'),
          ),
        ],
      ),
    );
  }

  /// Diálogo de error
  static Future<void> showErrorDialog({
    required BuildContext context,
    String title = 'Error',
    required String message,
  }) async {
    await showInfoDialog(context: context, title: title, message: message);
  }

  /// Diálogo de carga
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'Carregant...',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 100,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar snackbar
  static void showSnackbar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// AppBar reutilizable
  static PreferredSizeWidget buildAppBar({
    required String title,
    bool centerTitle = true,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      backgroundColor: const Color(AppConstants.primaryColorValue),
      actions: actions,
    );
  }

  /// Carga circular con mensaje
  static Widget loadingWidget({String message = 'Carregant...'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  /// Mensaje vacío
  static Widget emptyWidget({
    required String message,
    IconData icon = Icons.inbox,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
