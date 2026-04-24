import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plainpad/application/usecases/app_info/get_app_info_usecase.dart';
import 'package:plainpad/application/usecases/debug/get_debug_settings_usecase.dart';
import 'package:plainpad/application/usecases/debug/set_debug_mode_usecase.dart';
import 'package:plainpad/application/usecases/debug/set_log_level_usecase.dart';
import 'package:plainpad/application/usecases/editor/create_document_usecase.dart';
import 'package:plainpad/application/usecases/editor/open_document_usecase.dart';
import 'package:plainpad/application/usecases/editor/save_document_usecase.dart';
import 'package:plainpad/application/usecases/theme/get_theme_preference_usecase.dart';
import 'package:plainpad/application/usecases/theme/set_theme_preference_usecase.dart';
import 'package:plainpad/domain/repositories/app_info_repository.dart';
import 'package:plainpad/domain/repositories/debug_settings_repository.dart';
import 'package:plainpad/domain/repositories/text_document_repository.dart';
import 'package:plainpad/domain/repositories/theme_preference_repository.dart';
import 'package:plainpad/infrastructure/logging/persistent_app_logger.dart';
import 'package:plainpad/infrastructure/repositories/package_info_app_info_repository.dart';
import 'package:plainpad/infrastructure/repositories/saf_text_document_repository.dart';
import 'package:plainpad/infrastructure/repositories/shared_preferences_debug_settings_repository.dart';
import 'package:plainpad/infrastructure/repositories/shared_preferences_theme_preference_repository.dart';
import 'package:plainpad/presentation/viewmodels/about_viewmodel.dart';
import 'package:plainpad/presentation/viewmodels/debug_settings_viewmodel.dart';
import 'package:plainpad/presentation/viewmodels/debug_viewmodel.dart';
import 'package:plainpad/presentation/viewmodels/editor_viewmodel.dart';
import 'package:plainpad/presentation/viewmodels/theme_viewmodel.dart';
import 'package:plainpad/shared/logging/app_logger.dart';

final GetIt sl = GetIt.instance;

/// Wires up all dependencies. Call once at app startup before [runApp].
Future<void> setupServiceLocator() async {
  // ─── Infrastructure singletons ───────────────────────────────────────

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ignore: avoid_print — logger not yet available
  print('[DI] SharedPreferences ready');

  // ─── Debug settings repository (needed before logger init) ──────────
  final debugSettingsRepo = SharedPreferencesDebugSettingsRepository(prefs);
  sl.registerSingleton<DebugSettingsRepository>(debugSettingsRepo);

  // Logging — restore saved level so filtering is correct from first log
  final logger = PersistentAppLogger();
  await logger.init(savedLevel: debugSettingsRepo.getMinLogLevel());
  sl.registerSingleton<AppLogger>(logger);
  logger.info('[DI] Logger ready (minLevel: ${logger.minLevel.name})');

  // ─── Repository bindings ─────────────────────────────────────────────

  sl.registerSingleton<ThemePreferenceRepository>(
    SharedPreferencesThemePreferenceRepository(prefs),
  );

  sl.registerSingleton<AppInfoRepository>(
    const PackageInfoAppInfoRepository(),
  );

  sl.registerSingleton<TextDocumentRepository>(
    SafTextDocumentRepository(),
  );

  // ─── Use cases ───────────────────────────────────────────────────────

  sl.registerFactory<GetThemePreferenceUseCase>(
    () => GetThemePreferenceUseCase(sl<ThemePreferenceRepository>()),
  );
  sl.registerFactory<SetThemePreferenceUseCase>(
    () => SetThemePreferenceUseCase(sl<ThemePreferenceRepository>()),
  );
  sl.registerFactory<GetAppInfoUseCase>(
    () => GetAppInfoUseCase(sl<AppInfoRepository>()),
  );
  sl.registerFactory<GetDebugSettingsUseCase>(
    () => GetDebugSettingsUseCase(sl<DebugSettingsRepository>()),
  );
  sl.registerFactory<SetDebugModeUseCase>(
    () => SetDebugModeUseCase(sl<DebugSettingsRepository>()),
  );
  sl.registerFactory<SetLogLevelUseCase>(
    () => SetLogLevelUseCase(sl<DebugSettingsRepository>(), sl<AppLogger>()),
  );
  sl.registerFactory<OpenDocumentUseCase>(
    () => OpenDocumentUseCase(sl<TextDocumentRepository>()),
  );
  sl.registerFactory<CreateDocumentUseCase>(
    () => CreateDocumentUseCase(sl<TextDocumentRepository>()),
  );
  sl.registerFactory<SaveDocumentUseCase>(
    () => SaveDocumentUseCase(sl<TextDocumentRepository>()),
  );

  // ─── ViewModels ──────────────────────────────────────────────────────

  sl.registerSingleton<ThemeViewModel>(
    ThemeViewModel(
      sl<GetThemePreferenceUseCase>(),
      sl<SetThemePreferenceUseCase>(),
    ),
  );
  sl.registerSingleton<DebugSettingsViewModel>(
    DebugSettingsViewModel(
      sl<GetDebugSettingsUseCase>(),
      sl<SetDebugModeUseCase>(),
      sl<SetLogLevelUseCase>(),
    ),
  );
  sl.registerFactory<AboutViewModel>(
    () => AboutViewModel(sl<GetAppInfoUseCase>()),
  );
  sl.registerFactory<DebugViewModel>(
    () => DebugViewModel(sl<GetAppInfoUseCase>(), sl<AppLogger>()),
  );
  sl.registerSingleton<EditorViewModel>(
    EditorViewModel(
      sl<OpenDocumentUseCase>(),
      sl<CreateDocumentUseCase>(),
      sl<SaveDocumentUseCase>(),
      sl<AppLogger>(),
    ),
  );

  // ─── Infrastructure (DB, Repositories) ──────────────────────────────
  // TODO: add when features are implemented
  // sl.registerSingleton<AppDatabase>(AppDatabase());

  // ─── Application (UseCases) ─────────────────────────────────────────
  // TODO: add when features are implemented

  sl<AppLogger>().info('[DI] Service locator setup complete');
}
