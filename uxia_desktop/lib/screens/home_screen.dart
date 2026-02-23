import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/settings_manager.dart';
import '../widgets/common_widgets.dart';
import '../utils/validators.dart';
import 'login_screen.dart';
import 'tag_stats_screen.dart';

class HomeScreen extends StatefulWidget {
  final SettingsManager settingsManager;
  final String urlServidor;
  final String token;

  const HomeScreen({
    super.key,
    required this.settingsManager,
    required this.urlServidor,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiService _apiService;
  late final AuthService _authService;
  AuthUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.urlServidor, token: widget.token);
    _authService = AuthService(settingsManager: widget.settingsManager);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _apiService.getAuthUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await CommonWidgets.showConfirmDialog(
      context: context,
      title: 'Logout',
      message: '¿Seguro que deseas cerrar la sesión?',
      confirmLabel: 'Si, logout',
    );

    if (!confirm) return;

    try {
      await _authService.logout(widget.urlServidor, widget.token);
      await widget.settingsManager.deleteToken();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                LoginScreen(settingsManager: widget.settingsManager),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CommonWidgets.showErrorDialog(
          context: context,
          message: 'Error en logout: $e',
        );
      }
    }
  }

  Future<void> _showTokenInfo() async {
    if (_currentUser == null) {
      await CommonWidgets.showErrorDialog(
        context: context,
        message: 'No s\'ha pogut carregar la informació de l\'usuari',
      );
      return;
    }

    final info =
        '''
ID: ${_currentUser!.userId}
Usuari: ${_currentUser!.nickname}
Email: ${_currentUser!.email}
Telèfon: ${_currentUser!.telefon ?? 'N/A'}
Rol: ${_currentUser!.role}
Validat: ${_currentUser!.validat ? 'Si' : 'No'}
TOS: ${_currentUser!.tos ? 'Si' : 'No'}
    ''';

    if (mounted) {
      await CommonWidgets.showInfoDialog(
        context: context,
        title: 'Informació de Token',
        message: info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
    final buttonWidth = isMobile ? double.infinity : 300.0;

    return Scaffold(
      appBar: CommonWidgets.buildAppBar(title: 'Menú Principal'),
      backgroundColor: const Color(AppConstants.bgColorValue),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Menú Principal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _UsersScreen(
                          settingsManager: widget.settingsManager,
                          urlServidor: widget.urlServidor,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Gestionar Usuaris'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  onPressed: _showTokenInfo,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Informació Token'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TagStatsScreen(apiService: _apiService),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Estadístiques d\'etiquetes'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: CommonWidgets.dangerButton(
                  label: 'Logout',
                  onPressed: _handleLogout,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersScreen extends StatefulWidget {
  final SettingsManager settingsManager;
  final String urlServidor;
  final String token;

  const _UsersScreen({
    required this.settingsManager,
    required this.urlServidor,
    required this.token,
  });

  @override
  State<_UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<_UsersScreen> {
  late final ApiService _apiService;
  List<User> _users = [];
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(baseUrl: widget.urlServidor, token: widget.token);
    _loadData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final user = await _apiService.getAuthUser();
      final users = await _apiService.getUsers();

      if (mounted) {
        setState(() {
          _currentUserId = user?.userId;
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        CommonWidgets.showErrorDialog(
          context: context,
          message: 'Error carregant usuaris: $e',
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createUser() async {
    final emailCtrl = TextEditingController();
    final nicknameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    bool emailValid = false;
    bool nicknameValid = false;
    bool passwordValid = false;
    bool phoneValid = false;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void validate() {
              setState(() {
                emailValid = Validators.isValidEmail(emailCtrl.text);
                nicknameValid = nicknameCtrl.text.trim().isNotEmpty;
                passwordValid = passwordCtrl.text.length >= 6;
                phoneValid = Validators.isValidPhone(phoneCtrl.text);
              });
            }
            final allValid = emailValid && nicknameValid && passwordValid && phoneValid;
            return AlertDialog(
              title: const Text('Crear Usuari'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: emailCtrl.text.isEmpty || emailValid ? null : AppConstants.msgInvalidEmail,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: emailValid || emailCtrl.text.isEmpty ? Colors.blue : Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => validate(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nicknameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nom d\'usuari',
                        errorText: nicknameCtrl.text.isEmpty || nicknameValid ? null : 'El nom d\'usuari és obligatori',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: nicknameValid || nicknameCtrl.text.isEmpty ? Colors.blue : Colors.red),
                        ),
                      ),
                      onChanged: (_) => validate(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contrasenya',
                        errorText: passwordCtrl.text.isEmpty || passwordValid ? null : 'La contrasenya ha de tenir almenys 6 caràcters',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: passwordValid || passwordCtrl.text.isEmpty ? Colors.blue : Colors.red),
                        ),
                      ),
                      onChanged: (_) => validate(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: 'Telèfon',
                        errorText: phoneCtrl.text.isEmpty || phoneValid ? null : 'El telèfon no és vàlid',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: phoneValid || phoneCtrl.text.isEmpty ? Colors.blue : Colors.red),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => validate(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel·lar'),
                ),
                ElevatedButton(
                  onPressed: allValid ? () => Navigator.pop(context, true) : null,
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) async {
      if (result != true) return;
      try {
        final user = await _apiService.createUser(
          email: emailCtrl.text,
          nickname: nicknameCtrl.text,
          password: passwordCtrl.text,
          telefon: phoneCtrl.text,
        );
        await _loadData();

        if (mounted) {
          if (user != null) {
            await CommonWidgets.showInfoDialog(
              context: context,
              title: 'Usuari creat',
              message: 'Usuari creat correctament. Rebràs un SMS amb el codi de validació. El nou usuari no apareixerà a la llista fins que es valide.',
            );
          } else {
            await CommonWidgets.showErrorDialog(
              context: context,
              message: 'El servidor no ha creat el usuari. Revisa los datos o consulta los logs del backend.',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          await CommonWidgets.showErrorDialog(
            context: context,
            message: 'Error creant usuari: $e',
          );
        }
      }
    });

    try {
      final user = await _apiService.createUser(
        email: emailCtrl.text,
        nickname: nicknameCtrl.text,
        password: passwordCtrl.text,
        telefon: phoneCtrl.text,
      );
      await _loadData();

      if (mounted) {
        if (user != null) {
          await CommonWidgets.showInfoDialog(
            context: context,
            title: 'Usuari creat',
            message: 'Usuari creat correctament. Rebràs un SMS amb el codi de validació. El nou usuari no apareixerà a la llista fins que es valide.',
          );
        } else {
          await CommonWidgets.showErrorDialog(
            context: context,
            message: 'El servidor no ha creat el usuari. Revisa los datos o consulta los logs del backend.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await CommonWidgets.showErrorDialog(
          context: context,
          message: 'Error creant usuari: $e',
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await CommonWidgets.showConfirmDialog(
      context: context,
      title: 'Eliminar Usuari',
      message: 'Segur que vols eliminar ${user.nickname}?',
      confirmLabel: 'Eliminar',
    );

    if (!confirm) return;

    try {
      final deleted = await _apiService.deleteUser(user.id);
      await _loadData();
      if (mounted) {
        if (deleted) {
          CommonWidgets.showSnackbar(
            context: context,
            message: 'Usuari eliminat correctament',
            isError: false,
          );
        } else {
          CommonWidgets.showErrorDialog(
            context: context,
            message:
                'No s’ha pogut eliminar el usuari. Potser segueix existint.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CommonWidgets.showErrorDialog(
          context: context,
          message: 'Error eliminant usuari: $e',
        );
      }
    }
  }

  Future<void> _changeRole(User user) async {
    String selectedRole = user.role;
    final newRole = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Canviar Rol'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Admin'),
                value: 'admin',
                groupValue: selectedRole,
                onChanged: (v) => setState(() => selectedRole = v ?? 'admin'),
              ),
              RadioListTile<String>(
                title: const Text('Usuari'),
                value: 'user',
                groupValue: selectedRole,
                onChanged: (v) => setState(() => selectedRole = v ?? 'user'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedRole),
              child: const Text('Acceptar'),
            ),
          ],
        ),
      ),
    );

    if (newRole == null || newRole == user.role) return;

    try {
      await _apiService.updateUserRole(user.id, newRole);
      await _loadData();

      if (mounted) {
        CommonWidgets.showSnackbar(
          context: context,
          message: 'Rol actualitzat correctament',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        CommonWidgets.showErrorDialog(
          context: context,
          message: 'Error canviant rol: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CommonWidgets.buildAppBar(title: 'Gestionar Usuaris'),
        backgroundColor: const Color(AppConstants.bgColorValue),
        body: CommonWidgets.loadingWidget(),
      );
    }

    if (_users.isEmpty) {
      return Scaffold(
        appBar: CommonWidgets.buildAppBar(title: 'Gestionar Usuaris'),
        backgroundColor: const Color(AppConstants.bgColorValue),
        body: CommonWidgets.emptyWidget(message: 'Cap usuari'),
        floatingActionButton: FloatingActionButton(
          onPressed: _createUser,
          backgroundColor: const Color(AppConstants.primaryColorValue),
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      appBar: CommonWidgets.buildAppBar(title: 'Gestionar Usuaris'),
      backgroundColor: const Color(AppConstants.bgColorValue),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isCurrentUser = user.id == _currentUserId;

          return ListTile(
            title: Text(user.nickname),
            subtitle: Text(
              '${user.email} - ${user.telefon ?? 'N/A'} - ${user.role}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _changeRole(user),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(user),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        backgroundColor: const Color(AppConstants.primaryColorValue),
        child: const Icon(Icons.add),
      ),
    );
  }
}
