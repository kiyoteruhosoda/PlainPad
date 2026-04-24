import 'package:flutter/material.dart';
import 'package:plainpad/app/di/service_locator.dart';
import 'package:plainpad/presentation/viewmodels/editor_viewmodel.dart';
import 'package:plainpad/presentation/widgets/ui/widgets.dart';
import 'package:plainpad/shared/l10n/app_strings.dart';
import 'package:plainpad/shared/theme/theme.dart';

/// Primary page: a SAF-backed text viewer / editor.
///
/// Viewer is the default mode. A floating action button switches into
/// edit mode; a save FAB (plus an inline cancel button) switches back.
class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final EditorViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = sl<EditorViewModel>();
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() {
    final error = _vm.takeErrorMessage();
    if (error == null) return;
    // Defer to the next frame so we don't toggle ScaffoldMessenger state
    // while the widget tree is still being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    });
  }

  Future<bool> _confirmDiscardIfDirty() async {
    if (!_vm.dirty) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.editorDiscardTitle),
        content: const Text(AppStrings.editorDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.editorKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.editorDiscard),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Future<void> _handleOpen() async {
    if (!await _confirmDiscardIfDirty()) return;
    await _vm.openDocument();
  }

  Future<void> _handleNew() async {
    if (!await _confirmDiscardIfDirty()) return;
    await _vm.createDocument();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final vm = _vm;
        return PopScope(
          canPop: !vm.editing || !vm.dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmDiscardIfDirty()) {
              vm.cancelEdit();
            }
          },
          child: Column(
            children: [
              _EditorToolbar(
                vm: vm,
                onOpen: _handleOpen,
                onNew: _handleNew,
              ),
              const Divider(height: 1),
              Expanded(child: _buildBody(vm)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(EditorViewModel vm) {
    if (vm.busy && !vm.hasDocument) {
      return const AppLoadingView(message: AppStrings.commonLoading);
    }
    if (!vm.hasDocument) {
      return const AppEmptyView(
        icon: Icons.description_outlined,
        message: AppStrings.editorEmptyMessage,
      );
    }
    if (vm.editing) {
      return LineNumberedTextEditor(
        key: ValueKey('edit:${vm.document!.uri.value}'),
        initialText: vm.document!.content,
        autofocus: true,
        onChanged: vm.updateDraft,
      );
    }
    return LineNumberedTextView(
      key: ValueKey('view:${vm.document!.uri.value}'),
      text: vm.document!.content,
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.vm,
    required this.onOpen,
    required this.onNew,
  });

  final EditorViewModel vm;
  final VoidCallback onOpen;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final title = vm.document?.displayName ?? AppStrings.editorNoDocument;
    final subtitle = vm.editing
        ? (vm.dirty
            ? AppStrings.editorStatusEditingDirty
            : AppStrings.editorStatusEditing)
        : AppStrings.editorStatusViewing;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppStrings.editorOpenTooltip,
            onPressed: vm.busy ? null : onOpen,
            icon: const Icon(Icons.folder_open_outlined),
          ),
          IconButton(
            tooltip: AppStrings.editorNewTooltip,
            onPressed: vm.busy ? null : onNew,
            icon: const Icon(Icons.note_add_outlined),
          ),
        ],
      ),
    );
  }
}

/// Floating action button rendered by [MainPage] while the editor tab is
/// active. It switches between "Edit" and "Save" depending on ViewModel
/// state, per the product spec ("floating icon to change to edit mode").
class EditorFloatingActions extends StatelessWidget {
  const EditorFloatingActions({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = sl<EditorViewModel>();
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (!vm.hasDocument) return const SizedBox.shrink();
        if (vm.editing) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'editor-cancel',
                tooltip: AppStrings.editorCancelTooltip,
                onPressed: vm.busy ? null : vm.cancelEdit,
                child: const Icon(Icons.close),
              ),
              const SizedBox(height: AppSpacing.sm),
              FloatingActionButton.extended(
                heroTag: 'editor-save',
                onPressed: vm.busy ? null : vm.saveAndExitEditMode,
                icon: const Icon(Icons.save_outlined),
                label: const Text(AppStrings.editorSave),
              ),
            ],
          );
        }
        return FloatingActionButton(
          heroTag: 'editor-edit',
          tooltip: AppStrings.editorEditTooltip,
          onPressed: vm.busy ? null : vm.enterEditMode,
          child: const Icon(Icons.edit_outlined),
        );
      },
    );
  }
}
