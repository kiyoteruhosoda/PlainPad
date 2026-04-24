import 'package:equatable/equatable.dart';
import 'package:plainpad/shared/errors/app_error.dart';

/// Opaque handle to a document exposed via the Storage Access Framework.
///
/// The underlying string is always a `content://` URI. The Domain layer
/// treats it as an opaque identifier — the Infrastructure layer is what
/// turns it back into bytes.
final class DocumentUri extends Equatable {
  const DocumentUri._(this.value);

  factory DocumentUri(String raw) {
    if (raw.isEmpty) {
      throw const DomainError('DocumentUri cannot be empty');
    }
    if (!raw.startsWith('content://')) {
      throw const DomainError('DocumentUri must be a content:// URI');
    }
    return DocumentUri._(raw);
  }

  final String value;

  @override
  List<Object?> get props => [value];

  @override
  String toString() => value;
}
