import 'package:package_info_plus/package_info_plus.dart';
import 'package:plainpad/application/dto/app_info_dto.dart';
import 'package:plainpad/domain/repositories/app_info_repository.dart';
import 'package:plainpad/shared/build_info.dart';

/// Retrieves app version and build number from [PackageInfo] and the rest
/// of the build metadata from [BuildInfo].
final class PackageInfoAppInfoRepository implements AppInfoRepository {
  const PackageInfoAppInfoRepository();

  @override
  Future<AppInfoDto> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    // Prefer PackageInfo.version (reflects actual installed build),
    // fall back to the compile-time constant from BuildInfo.
    final version = packageInfo.version.isNotEmpty
        ? packageInfo.version
        : BuildInfo.version;

    // Same for the build number (task #468): BuildInfo's copy in the
    // repository is a stale placeholder until the release regenerates it,
    // whereas PackageInfo is the versionCode the device actually installed.
    final buildNumber = packageInfo.buildNumber.isNotEmpty
        ? packageInfo.buildNumber
        : BuildInfo.buildNumber;

    return AppInfoDto(
      version: version,
      buildNumber: buildNumber,
      gitCommit: BuildInfo.gitCommit,
      gitCommitFull: BuildInfo.gitCommitFull,
      flutterVersion: BuildInfo.flutterVersion,
      dartVersion: BuildInfo.dartVersion,
      buildDate: BuildInfo.buildDate,
      isDebug: BuildInfo.isDebug,
    );
  }
}
