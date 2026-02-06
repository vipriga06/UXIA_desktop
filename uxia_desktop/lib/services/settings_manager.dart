import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

class SettingsManager {
  static const String _fileName = 'settings.xml';
  late File _settingsFile;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _settingsFile = File('${directory.path}/$_fileName');
  }

  Future<bool> fileExists() async {
    return _settingsFile.exists();
  }

  Future<void> _ensureFileExists() async {
    if (!await fileExists()) {
      final builder = xml.XmlBuilder();
      builder.element('settings', nest: () {
        builder.element('url', nest: () {
          builder.text('');
        });
        builder.element('token', nest: () {
          builder.text('');
        });
      });
      await _settingsFile.writeAsString(builder.buildDocument().toXmlString(pretty: true));
    }
  }

  Future<Map<String, String>> loadSettings() async {
    await _ensureFileExists();
    
    try {
      final content = await _settingsFile.readAsString();
      final document = xml.XmlDocument.parse(content);
      final root = document.rootElement;

      String url = root.findElements('url').isNotEmpty
          ? root.findElements('url').first.innerText
          : '';
      String token = root.findElements('token').isNotEmpty
          ? root.findElements('token').first.innerText
          : '';

      return {
        'url': url,
        'token': token,
      };
    } catch (e) {
      return {'url': '', 'token': ''};
    }
  }

  Future<void> saveUrl(String url) async {
    await _ensureFileExists();
    final settings = await loadSettings();
    
    final builder = xml.XmlBuilder();
    builder.element('settings', nest: () {
      builder.element('url', nest: () {
        builder.text(url);
      });
      builder.element('token', nest: () {
        builder.text(settings['token'] ?? '');
      });
    });
    
    await _settingsFile.writeAsString(builder.buildDocument().toXmlString(pretty: true));
  }

  Future<void> saveToken(String token) async {
    await _ensureFileExists();
    final settings = await loadSettings();
    
    final builder = xml.XmlBuilder();
    builder.element('settings', nest: () {
      builder.element('url', nest: () {
        builder.text(settings['url'] ?? '');
      });
      builder.element('token', nest: () {
        builder.text(token);
      });
    });
    
    await _settingsFile.writeAsString(builder.buildDocument().toXmlString(pretty: true));
  }

  Future<void> deleteToken() async {
    await _ensureFileExists();
    final settings = await loadSettings();
    
    final builder = xml.XmlBuilder();
    builder.element('settings', nest: () {
      builder.element('url', nest: () {
        builder.text(settings['url'] ?? '');
      });
      builder.element('token', nest: () {
        builder.text('');
      });
    });
    
    await _settingsFile.writeAsString(builder.buildDocument().toXmlString(pretty: true));
  }

  Future<String?> getToken() async {
    final settings = await loadSettings();
    final token = settings['token'];
    return token != null && token.isNotEmpty ? token : null;
  }

  Future<String?> getUrl() async {
    final settings = await loadSettings();
    final url = settings['url'];
    return url != null && url.isNotEmpty ? url : null;
  }
}
