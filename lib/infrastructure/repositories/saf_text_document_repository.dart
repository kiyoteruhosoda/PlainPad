import 'package:flutter/services.dart';
import 'package:plainpad/domain/entities/text_document.dart';
import 'package:plainpad/domain/repositories/text_document_repository.dart';
import 'package:plainpad/domain/value_objects/document_uri.dart';
import 'package:plainpad/shared/errors/app_error.dart';

/// [TextDocumentRepository] backed by the native Android Storage Access
/// Framework bridge exposed on the `com.nolumia.plainpad/saf` method channel.
///
/// All file I/O happens in Kotlin; Dart only exchanges URIs and UTF-8
/// strings with the native side.
final class SafTextDocumentRepository implements TextDocumentRepository {
  SafTextDocumentRepository({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(_channelName);

  static const String _channelName = 'com.nolumia.plainpad/saf';

  final MethodChannel _channel;

  @override
  Future<TextDocument?> pickAndRead() async {
    final picked = await _invokePicker('pickDocument');
    if (picked == null) return null;
    final content = await _readContent(picked.uri);
    return TextDocument(
      uri: picked.uri,
      displayName: picked.displayName,
      content: content,
    );
  }

  @override
  Future<TextDocument?> createNew({required String suggestedName}) async {
    final picked = await _invokePicker(
      'createDocument',
      arguments: {'suggestedName': suggestedName, 'mimeType': 'text/plain'},
    );
    if (picked == null) return null;
    return TextDocument(
      uri: picked.uri,
      displayName: picked.displayName,
      content: '',
    );
  }

  @override
  Future<void> save({
    required DocumentUri uri,
    required String content,
  }) async {
    try {
      await _channel.invokeMethod<void>('writeDocument', {
        'uri': uri.value,
        'content': content,
      });
    } on PlatformException catch (e) {
      throw InfrastructureError('Failed to save document: ${e.message}',
          cause: e);
    }
  }

  Future<_PickedDocument?> _invokePicker(
    String method, {
    Map<String, Object?>? arguments,
  }) async {
    try {
      final raw = await _channel
          .invokeMapMethod<String, dynamic>(method, arguments);
      if (raw == null) return null;
      final uri = raw['uri'] as String?;
      final displayName = raw['displayName'] as String?;
      if (uri == null) return null;
      return _PickedDocument(
        uri: DocumentUri(uri),
        displayName: displayName ?? 'untitled',
      );
    } on PlatformException catch (e) {
      throw InfrastructureError('Document picker failed: ${e.message}',
          cause: e);
    }
  }

  Future<String> _readContent(DocumentUri uri) async {
    try {
      final content = await _channel.invokeMethod<String>(
        'readDocument',
        {'uri': uri.value},
      );
      return content ?? '';
    } on PlatformException catch (e) {
      throw InfrastructureError('Failed to read document: ${e.message}',
          cause: e);
    }
  }
}

class _PickedDocument {
  _PickedDocument({required this.uri, required this.displayName});
  final DocumentUri uri;
  final String displayName;
}
