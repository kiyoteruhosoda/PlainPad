import 'package:plainpad/domain/entities/text_document.dart';
import 'package:plainpad/domain/repositories/text_document_repository.dart';

/// Persists the given document's content back to the same SAF URI.
final class SaveDocumentUseCase {
  const SaveDocumentUseCase(this._repository);

  final TextDocumentRepository _repository;

  Future<void> execute(TextDocument document) =>
      _repository.save(uri: document.uri, content: document.content);
}
