import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plainpad/app/bootstrap/app_widget.dart';
import 'package:plainpad/app/di/service_locator.dart';

/// The native Storage Access Framework bridge, as the app names it.
const MethodChannel safChannel = MethodChannel('com.nolumia.plainpad/saf');

/// Starts the real app the way `main()` does — real service locator, real
/// [AppWidget] — with empty preferences and a SAF bridge that hands over a
/// document holding [initialDocument] (or nothing) on start.
///
/// Pair with [tearDownApp] in `tearDown`.
Future<void> pumpApp(WidgetTester tester, {String? initialDocument}) async {
  SharedPreferences.setMockInitialValues({});
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(safChannel, (call) async {
    switch (call.method) {
      case 'getInitialDocument':
        if (initialDocument == null) return null;
        return <String, Object?>{
          'uri': 'content://test/document/1',
          'displayName': 'note.txt',
        };
      case 'readDocument':
        return initialDocument ?? '';
    }
    return null;
  });
  await tester.runAsync(setupServiceLocator);
  await tester.pumpWidget(const AppWidget());
  await settle(tester);
}

/// Pumps until the pending frames, dialogs and channel calls are done.
///
/// Avoids `pumpAndSettle`: a focused text field keeps its cursor blinking,
/// which would never settle.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tearDownApp() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(safChannel, null);
  await sl.reset();
}
