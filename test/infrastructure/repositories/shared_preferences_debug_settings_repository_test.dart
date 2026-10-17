import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plainpad/infrastructure/repositories/shared_preferences_debug_settings_repository.dart';
import 'package:plainpad/shared/logging/log_level.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SharedPreferencesDebugSettingsRepository — release build', () {
    test('debug mode is off when nothing is stored', () {
      final repo =
          SharedPreferencesDebugSettingsRepository(prefs, debugBuild: false);
      expect(repo.getDebugModeEnabled(), isFalse);
    });

    test('log level is info when nothing is stored', () {
      final repo =
          SharedPreferencesDebugSettingsRepository(prefs, debugBuild: false);
      expect(repo.getMinLogLevel(), LogLevel.info);
    });

    test('keeps debug mode on once the reader turned it on', () async {
      final repo =
          SharedPreferencesDebugSettingsRepository(prefs, debugBuild: false);
      await repo.saveDebugModeEnabled(true);
      expect(
        SharedPreferencesDebugSettingsRepository(prefs, debugBuild: false)
            .getDebugModeEnabled(),
        isTrue,
      );
    });
  });

  group('SharedPreferencesDebugSettingsRepository — debug build', () {
    test('debug mode is on and log level is debug by default', () {
      final repo =
          SharedPreferencesDebugSettingsRepository(prefs, debugBuild: true);
      expect(repo.getDebugModeEnabled(), isTrue);
      expect(repo.getMinLogLevel(), LogLevel.debug);
    });

    test('saved values win over the defaults', () async {
      final repo =
          SharedPreferencesDebugSettingsRepository(prefs, debugBuild: true);
      await repo.saveDebugModeEnabled(false);
      await repo.saveMinLogLevel(LogLevel.warning);
      expect(repo.getDebugModeEnabled(), isFalse);
      expect(repo.getMinLogLevel(), LogLevel.warning);
    });
  });
}
