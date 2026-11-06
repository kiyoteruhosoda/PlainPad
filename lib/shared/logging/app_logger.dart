import 'dart:io';

import 'package:plainpad/shared/logging/log_entry.dart';
import 'package:plainpad/shared/logging/log_level.dart';

export 'log_entry.dart';
export 'log_level.dart';

/// Cross-cutting logging contract.
///
/// The concrete implementation lives in `infrastructure/logging/`.
/// Access via the service locator: `sl<AppLogger>()`.
abstract interface class AppLogger {
  void verbose(String message, {Object? error, StackTrace? stackTrace});
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// All entries currently in the in-memory buffer (oldest first).
  List<LogEntry> get entries;

  /// Entries filtered by [level]; null returns all.
  List<LogEntry> entriesForLevel(LogLevel? level);

  /// Current minimum log level. Messages below this level are silently dropped.
  LogLevel get minLevel;

  /// Changes the minimum log level at runtime.
  void setMinLevel(LogLevel level);

  /// Clears the in-memory buffer. Persistent files are unaffected.
  void clearBuffer();

  /// Saves the buffer as a text file where the person chooses — Android's
  /// "save to" screen (Downloads, a Drive folder…) — so they can open it
  /// later from the Files app (task #913, template flutterbase ADR-0018).
  ///
  /// Answers [LogExportCancelled] when they backed out of the screen, and
  /// [LogExportFailed] when nothing could be written.
  Future<LogExportResult> exportLogs();

  /// Hands the buffer, as a text file, to Android's share sheet (mail it to
  /// yourself, a chat, Drive…). Answers false when the sheet could not be
  /// opened.
  Future<bool> shareLogs();

  /// Returns all persisted log file paths (newest first).
  Future<List<File>> logFiles();
}

/// What became of [AppLogger.exportLogs].
sealed class LogExportResult {
  const LogExportResult();
}

/// The file was written. [fileName] is the name it was saved under (the
/// person may have changed it), [folder] the place as the platform names it
/// — "Download", "Documents", a Drive folder — or null when it does not say.
final class LogExportSaved extends LogExportResult {
  const LogExportSaved({required this.fileName, this.folder});

  final String fileName;
  final String? folder;
}

/// The person closed the "save to" screen without choosing a place.
final class LogExportCancelled extends LogExportResult {
  const LogExportCancelled();
}

/// The file could not be written.
final class LogExportFailed extends LogExportResult {
  const LogExportFailed();
}
