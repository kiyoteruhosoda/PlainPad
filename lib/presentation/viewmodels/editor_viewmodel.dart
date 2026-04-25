import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:plainpad/application/usecases/editor/create_document_usecase.dart';
import 'package:plainpad/application/usecases/editor/open_document_usecase.dart';
import 'package:plainpad/application/usecases/editor/save_document_usecase.dart';
import 'package:plainpad/domain/entities/text_document.dart';
import 'package:plainpad/shared/errors/app_error.dart';
import 'package:plainpad/shared/logging/app_logger.dart';

/// Drives the Editor page: loads, edits, and saves the current document.
///
/// Responsibilities:
/// * Track whether a document is open (and its last-saved content).
/// * Track whether the UI is in read-only or edit mode.
/// * Expose a `dirty` flag so callers can warn on unsaved changes.
class EditorViewModel extends ChangeNotifier {
  EditorViewModel(
    this._openDocument,
    this._createDocument,
    this._saveDocument,
    this._logger,
  ) {
    _incomingDocsSub = _openDocument.incomingDocuments.listen(
      _onIncomingDocument,
      onError: (Object e) {
        _errorMessage = e is AppError ? e.message : 'Failed to open document';
        _logger.error('[Editor] incoming document error: $e');
        notifyListeners();
      },
    );
  }

  final OpenDocumentUseCase _openDocument;
  final CreateDocumentUseCase _createDocument;
  final SaveDocumentUseCase _saveDocument;
  final AppLogger _logger;

  StreamSubscription<TextDocument>? _incomingDocsSub;
  bool _initialDocumentChecked = false;

  TextDocument? _document;
  String _draft = '';
  bool _editing = false;
  bool _busy = false;
  String? _errorMessage;

  TextDocument? get document => _document;
  bool get editing => _editing;
  bool get busy => _busy;
  bool get hasDocument => _document != null;
  bool get dirty => _editing && _document != null && _draft != _document!.content;

  /// Live in-progress text while in edit mode. Survives widget rebuilds
  /// (e.g. switching tabs and returning) because the ViewModel is a
  /// singleton — the editor widget reseeds from this, not from the last
  /// saved [document.content], to keep UI and saved state in sync.
  String get draft => _editing ? _draft : (_document?.content ?? '');

  /// Consumes and returns the latest error message.
  ///
  /// Returns null on subsequent reads until another error occurs — this lets
  /// the UI show a toast exactly once per failure.
  String? takeErrorMessage() {
    final m = _errorMessage;
    _errorMessage = null;
    return m;
  }

  /// Opens the document that was delivered via a cold-start VIEW intent.
  ///
  /// No-ops if the app was not launched via a VIEW intent, or if already
  /// called once. Safe to call from widget [initState].
  Future<void> openInitialDocument() async {
    if (_initialDocumentChecked || _busy) return;
    _initialDocumentChecked = true;
    await _runBusy(() async {
      final doc = await _openDocument.getInitial();
      if (doc == null) return;
      _logger.info('[Editor] opened initial document ${doc.displayName}');
      _document = doc;
      _draft = doc.content;
      _editing = false;
    });
  }

  Future<void> openDocument() async {
    if (_busy) return;
    await _runBusy(() async {
      final doc = await _openDocument.execute();
      if (doc == null) {
        _logger.debug('[Editor] openDocument cancelled');
        return;
      }
      _logger.info('[Editor] opened ${doc.displayName}');
      _document = doc;
      _draft = doc.content;
      _editing = false;
    });
  }

  Future<void> createDocument() async {
    if (_busy) return;
    await _runBusy(() async {
      final doc = await _createDocument.execute();
      if (doc == null) {
        _logger.debug('[Editor] createDocument cancelled');
        return;
      }
      _logger.info('[Editor] created ${doc.displayName}');
      _document = doc;
      _draft = doc.content;
      _editing = true;
    });
  }

  void enterEditMode() {
    if (_document == null || _editing) return;
    _draft = _document!.content;
    _editing = true;
    notifyListeners();
  }

  void cancelEdit() {
    if (!_editing) return;
    _draft = _document?.content ?? '';
    _editing = false;
    notifyListeners();
  }

  void updateDraft(String value) {
    if (!_editing) return;
    if (_draft == value) return;
    _draft = value;
    notifyListeners();
  }

  Future<bool> saveAndExitEditMode() async {
    if (_document == null || !_editing) return false;
    return _runBusy(() async {
      final updated = _document!.copyWith(content: _draft);
      await _saveDocument.execute(updated);
      _document = updated;
      _editing = false;
      _logger.info('[Editor] saved ${updated.displayName}');
    });
  }

  void _onIncomingDocument(TextDocument doc) {
    _logger.info('[Editor] received incoming document ${doc.displayName}');
    _document = doc;
    _draft = doc.content;
    _editing = false;
    notifyListeners();
  }

  Future<bool> _runBusy(Future<void> Function() action) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AppError catch (e) {
      _errorMessage = e.message;
      _logger.error('[Editor] ${e.message}');
      return false;
    } catch (e, stack) {
      _errorMessage = 'Unexpected error: $e';
      _logger.error('[Editor] $e', error: e, stackTrace: stack);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _incomingDocsSub?.cancel();
    super.dispose();
  }
}
