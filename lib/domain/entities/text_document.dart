import 'package:equatable/equatable.dart';
import 'package:plainpad/domain/value_objects/document_uri.dart';

/// A plain-text document accessible through a SAF-granted URI.
///
/// Identity is the [uri] — two documents are the same when their URIs match,
/// regardless of content.
final class TextDocument extends Equatable {
  const TextDocument({
    required this.uri,
    required this.displayName,
    required this.content,
  });

  final DocumentUri uri;
  final String displayName;
  final String content;

  TextDocument copyWith({String? content}) => TextDocument(
        uri: uri,
        displayName: displayName,
        content: content ?? this.content,
      );

  @override
  List<Object?> get props => [uri];
}
