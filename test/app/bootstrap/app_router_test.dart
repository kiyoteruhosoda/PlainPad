import 'package:flutter_test/flutter_test.dart';
import 'package:plainpad/app/bootstrap/app_router.dart';

void main() {
  group('AppRouter.resolveInitialRoute', () {
    test('keeps a route the app actually has', () {
      expect(AppRouter.resolveInitialRoute(AppRouter.main), AppRouter.main);
      expect(AppRouter.resolveInitialRoute(AppRouter.about), AppRouter.about);
      expect(AppRouter.resolveInitialRoute(AppRouter.debug), AppRouter.debug);
      expect(AppRouter.resolveInitialRoute(AppRouter.logs), AppRouter.logs);
    });

    test('starts at Home for the document URI Android hands over', () {
      // What a file manager sends when the reader opens a .txt with this app:
      // it is a document to read, not a screen name. Landing on the not-found
      // page here is what made "open with PlainPad" show 404 instead of the
      // file (2026-09-06).
      expect(
        AppRouter.resolveInitialRoute(
          'content://com.android.providers.downloads.documents/document/1',
        ),
        AppRouter.main,
      );
      expect(
        AppRouter.resolveInitialRoute(
          'file:///storage/emulated/0/Download/a.txt',
        ),
        AppRouter.main,
      );
    });

    test('starts at Home for any other name the platform supplies', () {
      expect(AppRouter.resolveInitialRoute('/nope'), AppRouter.main);
      expect(AppRouter.resolveInitialRoute(''), AppRouter.main);
    });
  });
}
