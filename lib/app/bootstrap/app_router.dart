import 'package:flutter/material.dart';
import 'package:plainpad/app/di/service_locator.dart';
import 'package:plainpad/presentation/pages/main_page.dart';
import 'package:plainpad/presentation/pages/system/about_page.dart';
import 'package:plainpad/presentation/pages/system/debug_page.dart';
import 'package:plainpad/presentation/pages/system/logs_page.dart';
import 'package:plainpad/shared/l10n/app_strings.dart';
import 'package:plainpad/shared/logging/app_logger.dart';

/// Named route definitions.
class AppRouter {
  AppRouter._();

  static const String main = '/';
  static const String about = '/about';
  static const String debug = '/debug';
  static const String logs = '/logs';

  /// Every screen this app has. Anything else is not one of ours.
  static const Set<String> _knownRoutes = {main, about, debug, logs};

  /// The screen to start on when the platform hands over [initialRoute].
  ///
  /// Android gives Flutter the launch intent's data URI as the initial
  /// route. Opening a text file from a file manager therefore starts the app
  /// at `content://…/document/msf%3A1234`, which matches no screen: the
  /// reader lands on the not-found page and never sees the document, even
  /// though `MainActivity` is holding it. The manifest turns that hand-over
  /// off (`flutter_deeplinking_enabled`), and this is the second half of the
  /// same rule, stated where the route table is: **the app has no URL
  /// routes**, so a name the platform supplies that is not one of our
  /// screens is a document reference, not a location. Home is where the SAF
  /// channel's `getInitialDocument` opens it.
  ///
  /// Named routes pushed from inside the app still reach [onGenerateRoute]
  /// and still get the not-found page — a typo there is a mistake worth
  /// seeing.
  static String resolveInitialRoute(String initialRoute) =>
      _knownRoutes.contains(initialRoute) ? initialRoute : main;

  /// Builds the first navigation stack. See [resolveInitialRoute].
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) =>
      <Route<dynamic>>[
        onGenerateRoute(
          RouteSettings(name: resolveInitialRoute(initialRoute)),
        ),
      ];

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    sl<AppLogger>().debug('[Router] → ${settings.name}');
    return switch (settings.name) {
      main => MaterialPageRoute<void>(
          builder: (_) => const MainPage(),
          settings: settings,
        ),
      about => MaterialPageRoute<void>(
          builder: (_) => const AboutPage(),
          settings: settings,
        ),
      debug => MaterialPageRoute<void>(
          builder: (_) => const DebugPage(),
          settings: settings,
        ),
      logs => MaterialPageRoute<void>(
          builder: (_) => const LogsPage(),
          settings: settings,
        ),
      _ => MaterialPageRoute<void>(
          builder: (_) => const _NotFoundPage(),
          settings: settings,
        ),
    };
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.commonPageNotFound)),
      body: const Center(child: Text(AppStrings.commonNotFound)),
    );
  }
}
