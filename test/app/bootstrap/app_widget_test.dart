import 'package:flutter_test/flutter_test.dart';
import 'package:plainpad/app/di/service_locator.dart';
import 'package:plainpad/presentation/pages/main_page.dart';
import 'package:plainpad/presentation/viewmodels/editor_viewmodel.dart';
import 'package:plainpad/shared/config/app_config.dart';
import 'package:plainpad/shared/l10n/app_strings.dart';

import '../../helpers/app_harness.dart';

void main() {
  tearDown(tearDownApp);

  // MaterialApp asserts that `home` and `onGenerateInitialRoutes` are not
  // both given; tests run with asserts on, like a debug build.
  testWidgets('starts on the main page without an assertion', (tester) async {
    await pumpApp(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.text(AppStrings.editorEmptyMessage), findsOneWidget);
  });

  testWidgets('opens the document the platform hands over', (tester) async {
    await pumpApp(tester, initialDocument: 'hello');

    expect(tester.takeException(), isNull);
    expect(sl<EditorViewModel>().document?.content, 'hello');
    expect(find.text(AppStrings.editorStatusViewing), findsOneWidget);
  });

  testWidgets('the drawer shows the app, not the template', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip(AppStrings.commonMenu));
    await settle(tester);

    expect(find.text(AppConfig.appTagline), findsOneWidget);
    expect(find.textContaining('DADS'), findsNothing);
  });

  test('the identity texts no longer carry the template wording', () {
    for (final text in [AppConfig.appDescription, AppConfig.appTagline]) {
      expect(text, isNot(contains('DADS')));
      expect(text, isNot(contains('Flutter base')));
    }
  });
}
