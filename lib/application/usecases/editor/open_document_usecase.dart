import 'package:plainpad/domain/entities/text_document.dart';
import 'package:plainpad/domain/repositories/text_document_repository.dart';

/// Prompts the user to pick an existing text document and reads its contents.
///
/// Returns `null` if the user cancelled the picker.
final class OpenDocumentUseCase {
  const OpenDocumentUseCase(this._repository);

  final TextDocumentRepository _repository;

  Future<TextDocument?> execute() => _repository.pickAndRead();
}
