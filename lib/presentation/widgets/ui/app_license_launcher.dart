import 'package:flutter/material.dart';
import 'package:plainpad/presentation/widgets/ui/app_icon_mark.dart';
import 'package:plainpad/shared/build_info.dart';
import 'package:plainpad/shared/config/app_config.dart';
import 'package:plainpad/shared/theme/theme.dart';

/// Opens the built-in [showLicensePage] with the app's branding applied.
///
/// License entries are sourced from [LicenseRegistry]; Flutter auto-registers
/// package licenses, and additional in-app entries are contributed via
/// `AppLicenseRegistrar.register()` during startup.
void openAppLicensePage(BuildContext context) {
  showLicensePage(
    context: context,
    applicationName: AppConfig.appName,
    applicationVersion: BuildInfo.version,
    applicationIcon: const _AppLicenseIcon(),
    applicationLegalese: '© ${AppConfig.appName}',
  );
}

class _AppLicenseIcon extends StatelessWidget {
  const _AppLicenseIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: AppIconMark(),
    );
  }
}
