import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'logo_widget.dart';
import 'services/settings_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsManager = SettingsManager();
  await settingsManager.initialize();
  runApp(LaMenuApp(settingsManager: settingsManager));
}

class LaMenuApp extends StatelessWidget {
  final SettingsManager settingsManager;

  const LaMenuApp({super.key, required this.settingsManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.I.D.A administrator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8bc6cc)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFB),
        fontFamily: 'dinnextw1g',
      ),
      home: PantallaLogin(settingsManager: settingsManager),
    );
  }
}

class PantallaLogin extends StatefulWidget {
  final SettingsManager settingsManager;

  const PantallaLogin({super.key, required this.settingsManager});

  @override
  State<PantallaLogin> createState() => _EstatPantallaLogin();
}

class _EstatPantallaLogin extends State<PantallaLogin> {
  final _controladorUrl = TextEditingController();
  final _controladorUsuari = TextEditingController();
  final _controladorContrasenya = TextEditingController();
  bool _mostrarContrasenya = false;

  @override
  void initState() {
    super.initState();
    _carregarCredencials();
  }

  Future<void> _carregarCredencials() async {
    final url = await widget.settingsManager.getUrl();
    setState(() {
      _controladorUrl.text = url ?? '';
    });
  }

  Future<void> _gestionarLogin() async {
    String url = _controladorUrl.text.trim();
    String usuari = _controladorUsuari.text.trim();
    String contrasenya = _controladorContrasenya.text;

    // Validar camps buits
    if (url.isEmpty || usuari.isEmpty || contrasenya.isEmpty) {
      _mostrarError('Per favor, omple tots els camps');
      return;
    }

    // Afegir esquema si falta
    if (!_teEsquema(url)) {
      url = 'http://$url';
    }

    // Validar format URL
    if (!_esUrlValida(url)) {
      if (kDebugMode) {
        print('URL que falla validació: $url');
      }
      _mostrarError('Format d\'URL invàlid. Exemple: uxia3.ieti.site');
      return;
    }

    // Acceptar email o nom d'usuari
    if (usuari.contains('@') && !_esEmailValid(usuari)) {
      _mostrarError('Email invàlid. Exemple: usuari@exemple.com');
      return;
    }

    // Guardar URL
    await widget.settingsManager.saveUrl(url);

    // Tancar diàleg
    if (mounted) {
      Navigator.pop(context);
    }

    // Comprovar connexió amb el servidor
    bool servidorDisponible = await _comprovarServidor(url);

    if (!servidorDisponible) {
      // No es pot connectar al servidor
      if (mounted) {
        _mostrarError('No es pot connectar al servidor $url. Comprova que la URL sigui correcta i que el servidor estigui actiu.');
      }
      return;
    }

    // Obtenir la URL correcta que va funcionar amb el port correcte
    final urlCorrecta = await widget.settingsManager.getUrl() ?? url;

    // Si no és email, buscar l'email real per l'usuari
    String email = usuari;
    if (!usuari.contains('@')) {
      final emailTrobat = await _obtenirEmailDeUsuari(urlCorrecta, usuari);
      if (emailTrobat == null) {
        if (mounted) {
          _mostrarError('Usuari no trobat.');
        }
        return;
      }
      email = emailTrobat;
    }

    // Fer login d'administrador
    final resultat = await _loginAdmin(urlCorrecta, email, contrasenya);
    if (!resultat['ok']) {
      if (mounted) {
        _mostrarError(resultat['missatge'] ?? 'Error de login');
      }
      return;
    }

    // Guardar token si arriba
    if (resultat['token'] != null) {
      await widget.settingsManager.saveToken(resultat['token']);
    }

    if (mounted) {
      // Mostrar mensatge d'èxit i navegar a pantalla principal
      _mostrarMissatgeINavegar('Login correcte', urlCorrecta, resultat['token']);
    }
  }

  void _mostrarMissatgeINavegar(String missatge, String url, String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login correcte'),
          content: Text(missatge),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaPrincipal(
            settingsManager: widget.settingsManager,
            urlServidor: url,
            token: token,
          ),
        ),
      );
    });
  }

  // Comprovar si es connecta al servidor
  Future<bool> _comprovarServidor(String url) async {
    // Eliminar port si existeix a la URL per provar diferents ports
    final uri = Uri.parse(url);
    final urlSensePort = '${uri.scheme}://${uri.host}';
    
    // Ports a provar: si ja té port, usar aquell; sinó provar 3000, 3307, 80
    List<String> urlsAProvar = [];
    if (uri.hasPort) {
      urlsAProvar.add(url);
    } else {
      // Provar primer HTTPS, després HTTP amb diferents ports
      urlsAProvar = [
        'https://${uri.host}',
        '$urlSensePort:3000',
        '$urlSensePort:3307',
        urlSensePort, // Port per defecte (80/443)
      ];
    }
    
    for (final urlProva in urlsAProvar) {
      try {
        final urlCompleta = '$urlProva/api/users';
        if (kDebugMode) {
          print('Intentant connectar a: $urlCompleta');
        }
        
        final resposta = await http.get(
          Uri.parse(urlCompleta),
        ).timeout(const Duration(seconds: 3));
        
        if (kDebugMode) {
          print('Codi resposta: ${resposta.statusCode}');
        }
        
        // Si respon amb codi 200-299 és vàlid
        if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
          // Guardar la URL correcta
          await widget.settingsManager.saveUrl(urlProva);
          _controladorUrl.text = urlProva;
          if (kDebugMode) {
            print('✓ Connexió exitosa amb: $urlProva');
          }
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('✗ Error amb $urlProva: $e');
        }
        continue;
      }
    }
    
    return false;
  }

  // Login d'administrador
  Future<Map<String, dynamic>> _loginAdmin(
    String urlBase,
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('$urlBase/api/admin/usuaris/login');
      if (kDebugMode) {
        print('Fent login a: $url');
        print('Email: $email');
      }
      
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Status code login: ${resposta.statusCode}');
        print('Body login: ${resposta.body}');
      }

      if (resposta.body.isEmpty) {
        return {
          'ok': false,
          'missatge': 'Resposta buida del servidor',
        };
      }

      final data = jsonDecode(resposta.body);
      if (data is Map && data['status'] == 'OK') {
        return {
          'ok': true,
          'token': data['data']?['token'],
          'missatge': data['message'],
        };
      }

      return {
        'ok': false,
        'missatge': data is Map ? data['message'] : 'Error de resposta',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error en _loginAdmin: $e');
      }
      return {
        'ok': false,
        'missatge': 'Error de connexió: $e',
      };
    }
  }

  Future<String?> _obtenirEmailDeUsuari(String urlBase, String usuari) async {
    try {
      final url = Uri.parse('$urlBase/api/users');
      final resposta = await http.get(url).timeout(const Duration(seconds: 10));

      if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
        return null;
      }

      final data = jsonDecode(resposta.body);
      if (data is List) {
        for (final item in data) {
          if (item is Map && item['nickname'] == usuari) {
            return item['email'] as String?;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  // Verificar si la URL és vàlida
  bool _teEsquema(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  bool _esUrlValida(String url) {
    final regex = RegExp(
      r'^https?:\/\/(localhost|[\w.-]+)(:\d{1,5})?(\/.*)?$',
    );
    return regex.hasMatch(url);
  }

  bool _esEmailValid(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }



  void _mostrarDialegLogin() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Inici de sessió'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controladorUrl,
                    decoration: const InputDecoration(
                      labelText: 'URL del servidor',
                      prefixIcon: Icon(Icons.cloud),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controladorUsuari,
                    decoration: const InputDecoration(
                      labelText: 'Nom d\'usuari',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controladorContrasenya,
                    obscureText: !_mostrarContrasenya,
                    decoration: InputDecoration(
                      labelText: 'Contrasenya',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarContrasenya
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarContrasenya = !_mostrarContrasenya;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel·lar'),
                ),
                ElevatedButton(
                  onPressed: _gestionarLogin,
                  child: const Text('Entrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Acceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controladorUrl.dispose();
    _controladorUsuari.dispose();
    _controladorContrasenya.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool esMobil = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: esMobil ? 60 : 90,
        title: const WidgetLogo(),
        centerTitle: true,
        backgroundColor: const Color(0xFF8bc6cc),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _mostrarDialegLogin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: esMobil ? 16 : 20,
                horizontal: esMobil ? 24 : 32,
              ),
            ),
            child: Text(
              'Logejar-se',
              style: TextStyle(
                fontSize: esMobil ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  final SettingsManager settingsManager;
  final String urlServidor;
  final String token;

  const PantallaPrincipal({
    super.key,
    required this.settingsManager,
    required this.urlServidor,
    required this.token,
  });

  @override
  State<PantallaPrincipal> createState() => _EstatPantallaPrincipal();
}

class _EstatPantallaPrincipal extends State<PantallaPrincipal> {
  @override
  Widget build(BuildContext context) {
    bool esMobil = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: esMobil ? 60 : 90,
        title: const WidgetLogo(),
        centerTitle: true,
        backgroundColor: const Color(0xFF8bc6cc),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Menú Principal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: esMobil ? double.infinity : 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GestioUsuaris(
                          settingsManager: widget.settingsManager,
                          urlServidor: widget.urlServidor,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Gestionar Usuaris'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: esMobil ? double.infinity : 300,
                child: ElevatedButton.icon(
                  onPressed: _verificarToken,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Verificar Token'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: esMobil ? double.infinity : 300,
                child: ElevatedButton.icon(
                  onPressed: _ferLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verificarToken() async {
    try {
      final url = Uri.parse('${widget.urlServidor}/api/admin/usuaris/testtoken');
      final resposta = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (resposta.statusCode == 200) {
        final data = jsonDecode(resposta.body);
        final info = data is Map ? (data['data'] as Map?) : null;
        final nickname = info?['nickname'] ?? 'Desconegut';
        final email = info?['email'] ?? 'Desconegut';
        final role = info?['role'] ?? 'Desconegut';
        final userId = info?['userId']?.toString() ?? 'Desconegut';
        final resum = 'ID: $userId\nUsuari: $nickname\nEmail: $email\nRol: $role';
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Token Vàlid'),
                content: Text(resum),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Acceptar'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Token invàlid o expirat'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Acceptar'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error verificant token: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Acceptar'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _ferLogout() async {
    try {
      final url = Uri.parse('${widget.urlServidor}/api/admin/usuaris/logout');
      final resposta = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (resposta.statusCode == 200) {
        // Eliminar token del settings
        await widget.settingsManager.deleteToken();

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Logout Correcte'),
                content: const Text('Has sortit de la sessió correctament'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaLogin(
                            settingsManager: widget.settingsManager,
                          ),
                        ),
                      );
                    },
                    child: const Text('Acceptar'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        final data = jsonDecode(resposta.body);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error en Logout'),
                content: Text(data['message'] ?? 'Error en logout'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Acceptar'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error en logout: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Acceptar'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

class GestioUsuaris extends StatefulWidget {
  final SettingsManager settingsManager;
  final String urlServidor;
  final String token;

  const GestioUsuaris({
    super.key,
    required this.settingsManager,
    required this.urlServidor,
    required this.token,
  });

  @override
  State<GestioUsuaris> createState() => _EstatGestioUsuaris();
}

class _EstatGestioUsuaris extends State<GestioUsuaris> {
  List<dynamic> usuaris = [];
  bool estaCargandoUsuaris = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuaris();
  }

  Future<void> _carregarUsuaris() async {
    try {
      final url = Uri.parse('${widget.urlServidor}/api/admin/usuaris');
      final resposta = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (resposta.statusCode == 200) {
        final data = jsonDecode(resposta.body);
        setState(() {
          usuaris = data['data'] ?? [];
          estaCargandoUsuaris = false;
        });
      } else {
        if (mounted) {
          _mostrarError('Error carregant usuaris: ${resposta.statusCode}');
        }
        setState(() {
          estaCargandoUsuaris = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error carregant usuaris: $e');
      }
      setState(() {
        estaCargandoUsuaris = false;
      });
    }
  }

  Future<void> _crearUsuari() async {
    final dialogResult = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final emailCtrl = TextEditingController();
        final nicknameCtrl = TextEditingController();
        final passwordCtrl = TextEditingController();

        return AlertDialog(
          title: const Text('Crear Usuari'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nicknameCtrl,
                decoration: const InputDecoration(labelText: 'Nom d\'usuari'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(labelText: 'Contrasenya'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel·lar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'email': emailCtrl.text,
                  'nickname': nicknameCtrl.text,
                  'password': passwordCtrl.text,
                });
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (dialogResult != null) {
      try {
        final url = Uri.parse('${widget.urlServidor}/api/admin/usuaris');
        final resposta = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(dialogResult),
        ).timeout(const Duration(seconds: 10));

        if (resposta.statusCode == 201) {
          _carregarUsuaris();
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const AlertDialog(
                  title: Text('Usuari creat'),
                  content: Text('Usuari creat correctament'),
                );
              },
            );

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        } else {
          final data = jsonDecode(resposta.body);
          if (mounted) {
            _mostrarError(data['message'] ?? 'Error creant usuari');
          }
        }
      } catch (e) {
        if (mounted) {
          _mostrarError('Error creant usuari: $e');
        }
      }
    }
  }

  Future<void> _eliminarUsuari(int usuariId) async {
    try {
      final url = Uri.parse('${widget.urlServidor}/api/admin/usuaris/$usuariId');
      final resposta = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      ).timeout(const Duration(seconds: 10));

      if (resposta.statusCode == 200) {
        _carregarUsuaris();
        if (mounted) {
          _mostrarError('Usuari eliminat correctament');
        }
      } else {
        final data = jsonDecode(resposta.body);
        if (mounted) {
          _mostrarError(data['message'] ?? 'Error eliminant usuari');
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error eliminant usuari: $e');
      }
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Missatge'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Acceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuaris'),
        backgroundColor: const Color(0xFF8bc6cc),
      ),
      body: estaCargandoUsuaris
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuaris.length,
              itemBuilder: (context, index) {
                final usuari = usuaris[index];
                return ListTile(
                  title: Text(usuari['nickname'] ?? 'Sense nom'),
                  subtitle: Text(usuari['email'] ?? 'Sense email'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Eliminar Usuari'),
                            content: Text('Segur que vols eliminar ${usuari['nickname']}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel·lar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _eliminarUsuari(usuari['id']);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearUsuari,
        backgroundColor: const Color(0xFF8bc6cc),
        child: const Icon(Icons.add),
      ),
    );
  }
}
