import 'package:plainpad/domain/entities/text_document.dart';
import 'package:plainpad/domain/repositories/text_document_repository.dart';

/// Prompts the user to create a new document and returns a handle to it.
///
/// Returns `null` if the user cancelled the picker.
final class CreateDocumentUseCase {
  const CreateDocumentUseCase(this._repository);

  final TextDocumentRepository _repository;

  Future<TextDocument?> execute({String suggestedName = 'untitled.txt'}) =>
      _repository.createNew(suggestedName: suggestedName);
}
