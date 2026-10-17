import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plainpad/presentation/pages/main_page.dart';
import 'package:plainpad/presentation/pages/system/about_page.dart';
import 'package:plainpad/presentation/widgets/ui/widgets.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/screenshot.dart';

/// The About and Licenses pages show the app's own icon — the launcher's
/// notepad — not the template's generic placeholder (task #451).
void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'PlainPad',
      packageName: 'com.nolumia.plainpad',
      version: '1.7.1',
      buildNumber: '54',
      buildSignature: '',
    );
  });
  tearDown(tearDownApp);

  Future<BuildContext> startApp(WidgetTester tester) async {
    await preparePhoneScreen(tester);
    await pumpApp(tester);
    return tester.element(find.byType(MainPage));
  }

  testWidgets('About shows the app icon', (tester) async {
    final context = await startApp(tester);

    unawaited(Navigator.of(context).pushNamed('/about'));
    await settle(tester);

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.byType(AppIconMark), findsOneWidget);
    expect(find.byIcon(Icons.web_asset), findsNothing);
    await saveScreenshot(find.byType(AboutPage), 'about');
  });

  testWidgets('Licenses shows the app icon', (tester) async {
    final context = await startApp(tester);

    openAppLicensePage(context);
    await settle(tester);

    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.byType(AppIconMark), findsOneWidget);
    expect(find.byIcon(Icons.web_asset), findsNothing);
    await saveScreenshot(find.byType(LicensePage), 'licenses');
  });
}
