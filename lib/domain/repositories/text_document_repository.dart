import 'package:plainpad/domain/entities/text_document.dart';
import 'package:plainpad/domain/value_objects/document_uri.dart';

/// Abstraction over document I/O performed via the Storage Access Framework.
///
/// All operations operate on [DocumentUri]s — never on filesystem paths.
/// Implementations live in `infrastructure/`.
abstract interface class TextDocumentRepository {
  /// Prompts the user to pick an existing document.
  ///
  /// Returns `null` if the user cancelled the picker.
  Future<TextDocument?> pickAndRead();

  /// Prompts the user to create a new document with [suggestedName].
  ///
  /// Returns `null` if the user cancelled the picker.
  /// The returned document starts with empty content.
  Future<TextDocument?> createNew({required String suggestedName});

  /// Writes [content] back to the document identified by [uri].
  Future<void> save({
    required DocumentUri uri,
    required String content,
  });
}
