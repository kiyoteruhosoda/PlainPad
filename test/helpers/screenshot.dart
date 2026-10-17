import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where [saveScreenshot] writes. CI uploads this folder as an artifact so a
/// reviewer can look at the screen, not just at a passing assertion.
const String screenshotDir = 'build/screenshots';

/// Sizes the test screen like a phone (390 × 844 logical px at 3×) and loads
/// the app font and Material icons, so screenshots read like the real thing
/// instead of the test font's boxes.
Future<void> preparePhoneScreen(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.runAsync(_loadFonts);
}

var _fontsLoaded = false;

Future<void> _loadFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  final noto = FontLoader('NotoSansJP')
    ..addFont(_file('assets/fonts/NotoSansJP-Regular.ttf'))
    ..addFont(_file('assets/fonts/NotoSansJP-Bold.ttf'));
  await noto.load();
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!icons.existsSync()) return;
  await (FontLoader('MaterialIcons')..addFont(_file(icons.path))).load();
}

Future<ByteData> _file(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

/// Writes what [finder] shows to `build/screenshots/<name>.png`.
///
/// Goes through `matchesGoldenFile` for the capture, with a comparator that
/// saves the image instead of comparing it: nothing is checked in, so the
/// test never fails on a pixel difference.
Future<void> saveScreenshot(Finder finder, String name) async {
  final previous = goldenFileComparator;
  goldenFileComparator = _SavingComparator();
  try {
    await expectLater(finder, matchesGoldenFile('$name.png'));
  } finally {
    goldenFileComparator = previous;
  }
}

class _SavingComparator extends GoldenFileComparator {
  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    await update(golden, imageBytes);
    return true;
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) async {
    final file = File('$screenshotDir/${golden.path}');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(imageBytes);
  }
}
