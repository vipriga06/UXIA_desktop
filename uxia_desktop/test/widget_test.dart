// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:uxia_desktop/main.dart';
import 'package:uxia_desktop/services/settings_manager.dart';

void main() {
  testWidgets('App launches with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final settingsManager = SettingsManager();
    await settingsManager.initialize();
    
    await tester.pumpWidget(LaMenuApp(settingsManager: settingsManager));

    // Verify that the login button is displayed
    expect(find.text('Logejar-se'), findsOneWidget);
  });
}
