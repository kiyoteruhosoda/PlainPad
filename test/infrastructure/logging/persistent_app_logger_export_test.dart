import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plainpad/infrastructure/logging/persistent_app_logger.dart';
import 'package:plainpad/shared/logging/app_logger.dart';

// Saving and sharing go through MainActivity's `nolumia/log_files` channel
// (task #913); `init()` is never called, so no file I/O happens.
PersistentAppLogger _fresh() =>
    PersistentAppLogger()..setMinLevel(LogLevel.verbose);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PersistentAppLogger — saving and sharing', () {
    const channel = MethodChannel('nolumia/log_files');
    late List<MethodCall> calls;

    void answer(Object? Function(MethodCall call) reply) {
      calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return reply(call);
          });
    }

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    test('exportLogs hands the buffer to the "save to" screen', () async {
      answer(
        (_) => <String, Object?>{'name': 'x-log.log', 'folder': 'Download'},
      );
      final log = _fresh()
        ..info('line one')
        ..error('line two');

      final result = await log.exportLogs();

      expect(calls.single.method, 'saveAs');
      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(args['name'], matches(RegExp(r'^log_\d{8}_\d{6}\.txt$')));
      expect(args['text'], contains('line one'));
      expect(args['text'], contains('line two'));
      expect(result, isA<LogExportSaved>());
      final saved = result as LogExportSaved;
      expect(saved.fileName, 'x-log.log');
      expect(saved.folder, 'Download');
    });

    test(
      'exportLogs leaves the folder out when Android does not say',
      () async {
        answer((_) => <String, Object?>{'name': 'x-log.log', 'folder': null});
        final result = await _fresh().exportLogs() as LogExportSaved;
        expect(result.folder, isNull);
      },
    );

    test('exportLogs reports backing out as cancelled', () async {
      answer((_) => null);
      expect(await _fresh().exportLogs(), isA<LogExportCancelled>());
    });

    test('exportLogs reports a write failure as failed', () async {
      answer((_) => throw PlatformException(code: 'log_files'));
      expect(await _fresh().exportLogs(), isA<LogExportFailed>());
    });

    test('exportLogs fails where there is no Android side', () async {
      expect(await _fresh().exportLogs(), isA<LogExportFailed>());
    });

    test('shareLogs hands the buffer to the share sheet', () async {
      answer((_) => null);
      final log = _fresh()..info('shared line');
      expect(await log.shareLogs(), isTrue);
      expect(calls.single.method, 'share');
      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(args['text'], contains('shared line'));
    });

    test('shareLogs answers false when the sheet cannot open', () async {
      answer((_) => throw PlatformException(code: 'log_files'));
      expect(await _fresh().shareLogs(), isFalse);
    });
  });
}
