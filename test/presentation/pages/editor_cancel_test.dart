import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plainpad/app/di/service_locator.dart';
import 'package:plainpad/presentation/viewmodels/editor_viewmodel.dart';
import 'package:plainpad/shared/l10n/app_strings.dart';

import '../../helpers/app_harness.dart';

/// The × (cancel editing) button must not throw edits away silently — it asks
/// the same question as Back and Open do.
void main() {
  tearDown(tearDownApp);

  Future<void> startEditing(WidgetTester tester) async {
    await pumpApp(tester, initialDocument: 'hello');
    await tester.tap(find.byTooltip(AppStrings.editorEditTooltip));
    await settle(tester);
    expect(sl<EditorViewModel>().editing, isTrue);
  }

  Future<void> tapCancel(WidgetTester tester) async {
    await tester.tap(find.byTooltip(AppStrings.editorCancelTooltip));
    await settle(tester);
  }

  testWidgets('asks before discarding changed text', (tester) async {
    await startEditing(tester);
    await tester.enterText(find.byType(TextField), 'hello world');
    await settle(tester);

    await tapCancel(tester);

    expect(find.text(AppStrings.editorDiscardTitle), findsOneWidget);
  });

  testWidgets('keeping on editing leaves the changed text', (tester) async {
    await startEditing(tester);
    await tester.enterText(find.byType(TextField), 'hello world');
    await settle(tester);
    await tapCancel(tester);

    await tester.tap(find.text(AppStrings.editorKeepEditing));
    await settle(tester);

    final vm = sl<EditorViewModel>();
    expect(find.text(AppStrings.editorDiscardTitle), findsNothing);
    expect(vm.editing, isTrue);
    expect(vm.draft, 'hello world');
    expect(find.text('hello world'), findsOneWidget);
  });

  testWidgets('discarding goes back to the saved text', (tester) async {
    await startEditing(tester);
    await tester.enterText(find.byType(TextField), 'hello world');
    await settle(tester);
    await tapCancel(tester);

    await tester.tap(find.text(AppStrings.editorDiscard));
    await settle(tester);

    final vm = sl<EditorViewModel>();
    expect(vm.editing, isFalse);
    expect(vm.document?.content, 'hello');
    expect(find.text(AppStrings.editorStatusViewing), findsOneWidget);
  });

  testWidgets('closes without asking when nothing changed', (tester) async {
    await startEditing(tester);

    await tapCancel(tester);

    expect(find.text(AppStrings.editorDiscardTitle), findsNothing);
    expect(sl<EditorViewModel>().editing, isFalse);
  });
}
