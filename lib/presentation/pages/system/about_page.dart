import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/viewmodels/about_viewmodel.dart';
import 'package:flutterbase/presentation/viewmodels/debug_settings_viewmodel.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/config/app_config.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// About / version information page.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const int _debugUnlockTapCount = 7;

  late final AboutViewModel _viewModel;
  int _versionTapCount = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<AboutViewModel>();
    _viewModel.addListener(_onViewModelChange);
    _viewModel.loadAppInfo();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  Future<void> _onVersionTapped() async {
    final debugVm = sl<DebugSettingsViewModel>();
    if (debugVm.debugEnabled) {
      _versionTapCount = 0;
      return;
    }
    _versionTapCount++;
    if (_versionTapCount < _debugUnlockTapCount) return;
    _versionTapCount = 0;
    await debugVm.setDebugEnabled(true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.aboutDebugUnlocked)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppMainHeader(title: AppStrings.aboutTitle),
      body: switch (_viewModel.state) {
        AboutState.loading => const AppLoadingView(),
        AboutState.error => AppErrorView(
            message: _viewModel.appError?.message ?? AppStrings.commonError,
            onRetry: _viewModel.loadAppInfo,
          ),
        AboutState.loaded => _buildContent(context, colorScheme),
      },
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final info = _viewModel.appInfo!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: AppSpacing.aboutIconContainer,
            height: AppSpacing.aboutIconContainer,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.xlBorder,
            ),
            child: Icon(Icons.web_asset, size: AppSpacing.aboutIconSize, color: colorScheme.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            AppConfig.appDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppCard(
          child: Column(
            children: [
              _VersionInfoRow(
                label: AppStrings.aboutVersion,
                value: info.version,
                onTap: _onVersionTapped,
              ),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutBuildNumber, value: info.buildNumber),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutGitCommit, value: info.gitCommit),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutFlutterVersion, value: info.flutterVersion),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutDartVersion, value: info.dartVersion),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: AppStrings.aboutPlatform,
                value: AppStrings.aboutPlatformValue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

/// Version row with a secret 7-tap gesture that re-enables debug mode.
class _VersionInfoRow extends StatelessWidget {
  const _VersionInfoRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _InfoRow(label: label, value: value),
    );
  }
}
