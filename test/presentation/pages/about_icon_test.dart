import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plainpad/presentation/pages/main_page.dart';
import 'package:plainpad/presentation/pages/system/about_page.dart';
import 'package:plainpad/presentation/widgets/ui/widgets.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/screenshot.dart';

/// `version: <name>+<build>` from pubspec.yaml, handed to PackageInfo as the
/// installed version (task #468).
final ({String name, String build}) _pubspecVersion = () {
  final line = File('pubspec.yaml')
      .readAsLinesSync()
      .firstWhere((l) => l.startsWith('version:'));
  final parts = line.substring('version:'.length).trim().split('+');
  return (name: parts[0], build: parts[1]);
}();

/// The About and Licenses pages show the app's own icon — the launcher's
/// notepad — not the template's generic placeholder (task #451).
void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'PlainPad',
      packageName: 'com.nolumia.plainpad',
      version: _pubspecVersion.name,
      buildNumber: _pubspecVersion.build,
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

  testWidgets('About shows the installed version and build number',
      (tester) async {
    // Not BuildInfo's placeholder ("26"), which only the release regenerates
    // (task #468).
    final context = await startApp(tester);

    unawaited(Navigator.of(context).pushNamed('/about'));
    await settle(tester);

    expect(find.text(_pubspecVersion.name), findsOneWidget);
    expect(find.text(_pubspecVersion.build), findsOneWidget);
    await saveScreenshot(find.byType(AboutPage), 'about_version');
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
