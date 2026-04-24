/// Centralised English string resources.
/// All user-visible strings must come from this class — never hardcoded inline.
///
/// App identity values (name, tagline, descriptions) live in [AppConfig] —
/// they are configuration, not localised copy.
class AppStrings {
  AppStrings._();

  // ─── Navigation ───────────────────────────────────────────────────────
  static const String navHome = 'Editor';
  static const String navSettings = 'Settings';

  // ─── Drawer ───────────────────────────────────────────────────────────
  static const String drawerClose = 'Close';
  static const String drawerAbout = 'About';
  static const String drawerLicenses = 'Licenses';
  static const String drawerDebug = 'Debug Info';
  static const String drawerLogs = 'Logs';

  // ─── Settings tab ─────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeSystem = 'System default';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsAbout = 'About';
  static const String settingsLicenses = 'Licenses';
  static const String settingsDebug = 'Debug Info';
  static const String settingsLogs = 'Logs';

  // ─── Footer ───────────────────────────────────────────────────────────
  static const String footerAbout = 'About';
  static const String footerLicenses = 'Licenses';

  // ─── About page ───────────────────────────────────────────────────────
  static const String aboutTitle = 'About';
  static const String aboutVersion = 'Version';
  static const String aboutBuildNumber = 'Build Number';
  static const String aboutGitCommit = 'Git Commit';
  static const String aboutFlutterVersion = 'Flutter Version';
  static const String aboutDartVersion = 'Dart Version';
  static const String aboutPlatform = 'Platform';
  static const String aboutPlatformValue = 'Android / iOS';
  static const String aboutDebugUnlocked = 'Debug mode enabled';
  static const String aboutDebugAlreadyOn = 'Debug mode is already on';

  // ─── Debug page ───────────────────────────────────────────────────────
  static const String debugTitle = 'Debug Info';
  static const String debugWarning =
      'This page is for debug purposes only. Do not display in release builds.';
  static const String debugAppInfoSection = 'App Info';
  static const String debugThemeSection = 'Theme Info';
  static const String debugThemeMode = 'Theme Mode';
  static const String debugThemeModeDark = 'Dark Mode';
  static const String debugThemeModeLight = 'Light Mode';
  static const String debugPrimaryColor = 'Primary Color';
  static const String debugSurfaceColor = 'Surface Color';
  static const String debugActionsSection = 'Debug Actions';
  static const String debugClearLogs = 'Clear Logs';
  static const String debugClearLogsSuccess = 'Logs cleared';
  static const String debugClearCache = 'Clear Cache';
  static const String debugClearCacheSuccess = 'Cache cleared';
  static const String debugTestCrash = 'Test Crash';
  static const String debugTestCrashTitle = 'Test Crash';
  static const String debugTestCrashBody =
      'Crash the app for testing purposes?';
  static const String debugCopyAll = 'Copy All';
  static const String debugCopiedToClipboard = 'Copied to clipboard';
  static const String debugCancel = 'Cancel';
  static const String debugCrash = 'Crash';
  static const String debugAppName = 'App Name';
  static const String debugVersion = 'Version';
  static const String debugBuildNumber = 'Build Number';
  static const String debugGitCommit = 'Git Commit';
  static const String debugFlutterVersion = 'Flutter Version';
  static const String debugDartVersion = 'Dart Version';
  static const String debugPlatform = 'Platform';
  static const String debugDesignSystem = 'Design System';
  static const String debugBuildDate = 'Build Date';
  static const String debugIsDebugBuild = 'Debug Build';

  // ─── Logs page ────────────────────────────────────────────────────────
  static const String logsTitle = 'Logs';
  static const String logsAll = 'All';
  static const String logsVerbose = 'Verbose';
  static const String logsDebug = 'Debug';
  static const String logsInfo = 'Info';
  static const String logsWarning = 'Warning';
  static const String logsError = 'Error';
  static const String logsClear = 'Clear';
  static const String logsClearConfirmTitle = 'Clear Logs';
  static const String logsClearConfirmBody =
      'Delete all log entries from memory?';
  static const String logsClearSuccess = 'Logs cleared';
  static const String logsDownload = 'Export';
  static const String logsDownloadSuccess = 'Logs saved to file';
  static const String logsDownloadError = 'Failed to save logs';
  static const String logsEmpty = 'No log entries';
  static const String logsCancel = 'Cancel';
  static const String logsConfirm = 'Clear';
  static const String logsCopied = 'Log entry copied';

  // ─── Developer settings ───────────────────────────────────────────────
  static const String settingsDeveloper = 'Developer';
  static const String settingsDebugMode = 'Debug Mode';
  static const String settingsDebugModeSubtitle =
      'Show Logs and Debug Info menu items';
  static const String settingsLogLevel = 'Log Level';
  static const String logLevelVerbose = 'Verbose';
  static const String logLevelDebug = 'Debug';
  static const String logLevelInfo = 'Info';
  static const String logLevelWarning = 'Warning';
  static const String logLevelError = 'Error';

  // ─── Licenses page ───────────────────────────────────────────────────
  static const String licensesTitle = 'Licenses';
  static const String licensesDetails =
      'Please refer to the package license file for details.';

  // ─── Editor ───────────────────────────────────────────────────────────
  static const String editorTitle = 'Editor';
  static const String editorEmptyMessage =
      'Open or create a text file to get started';
  static const String editorNoDocument = 'No document';
  static const String editorStatusViewing = 'Viewer mode';
  static const String editorStatusEditing = 'Editing';
  static const String editorStatusEditingDirty = 'Editing · unsaved changes';
  static const String editorOpenTooltip = 'Open file';
  static const String editorNewTooltip = 'New file';
  static const String editorEditTooltip = 'Edit';
  static const String editorCancelTooltip = 'Cancel editing';
  static const String editorSave = 'Save';
  static const String editorDiscardTitle = 'Discard changes?';
  static const String editorDiscardBody =
      'Your unsaved edits will be lost. Continue?';
  static const String editorKeepEditing = 'Keep editing';
  static const String editorDiscard = 'Discard';

  // ─── Common ──────────────────────────────────────────────────────────
  static const String commonRetry = 'Retry';
  static const String commonMenu = 'Menu';
  static const String commonNotFound = '404 - Page not found';
  static const String commonPageNotFound = 'Page Not Found';
  static const String commonLoading = 'Loading...';
  static const String commonError = 'An error occurred';
  static const String commonEmpty = 'No data';
}
