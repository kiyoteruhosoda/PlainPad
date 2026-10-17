import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plainpad/domain/repositories/debug_settings_repository.dart';
import 'package:plainpad/shared/logging/log_level.dart';

/// [DebugSettingsRepository] backed by [SharedPreferences].
final class SharedPreferencesDebugSettingsRepository
    implements DebugSettingsRepository {
  SharedPreferencesDebugSettingsRepository(
    this._prefs, {
    bool debugBuild = kDebugMode,
  }) : _debugBuild = debugBuild;

  final SharedPreferences _prefs;

  /// Whether this is a debug build. Decides the defaults below; tests pass
  /// `false` to see what a release build starts with.
  final bool _debugBuild;

  static const String _keyDebugMode = 'debug_mode_enabled';
  static const String _keyLogLevel = 'min_log_level';

  /// Off in release builds until the reader turns it on (seven taps on the
  /// version in About). Debug builds keep it on for development.
  @override
  bool getDebugModeEnabled() => _prefs.getBool(_keyDebugMode) ?? _debugBuild;

  @override
  LogLevel getMinLogLevel() {
    final saved = _prefs.getString(_keyLogLevel);
    return LogLevel.values.firstWhere(
      (l) => l.name == saved,
      orElse: () => _debugBuild ? LogLevel.debug : LogLevel.info,
    );
  }

  @override
  Future<void> saveDebugModeEnabled(bool enabled) =>
      _prefs.setBool(_keyDebugMode, enabled);

  @override
  Future<void> saveMinLogLevel(LogLevel level) =>
      _prefs.setString(_keyLogLevel, level.name);
}
