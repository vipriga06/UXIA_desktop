import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'logo_widget.dart';

void main() => runApp(const LaMenuApp());

class LaMenuApp extends StatelessWidget {
  const LaMenuApp({super.key});

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
      home: const PantallaLogin(),
    );
  }
}

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controladorUrl.text = prefs.getString('url') ?? '';
      _controladorUsuari.text = prefs.getString('username') ?? '';
      _controladorContrasenya.text = prefs.getString('password') ?? '';
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

    // Guardar credencials
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('url', url);
    await prefs.setString('username', usuari);
    await prefs.setString('password', contrasenya);

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
    final urlCorrecta = prefs.getString('url') ?? url;

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
      await prefs.setString('token', resultat['token']);
    }

    if (mounted) {
      _mostrarError('Login correcte.');
    }
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('url', urlProva);
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
      final url = Uri.parse('$urlBase/api/users/login');
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
