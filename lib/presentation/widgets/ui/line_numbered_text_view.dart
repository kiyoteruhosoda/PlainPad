import 'package:flutter/material.dart';
import 'package:plainpad/shared/config/app_config.dart';
import 'package:plainpad/shared/theme/app_spacing.dart';

/// Read-only viewer that renders text with a left-hand line-number gutter,
/// emulating a lightweight code editor.
///
/// Line numbers count logical lines (hard `\n` breaks), matching the
/// behaviour of typical editors when soft-wrap is enabled.
class LineNumberedTextView extends StatelessWidget {
  const LineNumberedTextView({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.sm),
  });

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final textStyle = _editorTextStyle(context);
    final gutterStyle = _gutterTextStyle(context);
    final lineCount = _lineCount(text);

    return Scrollbar(
      child: SingleChildScrollView(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Gutter(
              lineCount: lineCount,
              style: gutterStyle,
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 1,
              constraints: const BoxConstraints(minHeight: 24),
              color: Theme.of(context).dividerColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SelectableText(
                text.isEmpty ? ' ' : text,
                style: textStyle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// Edit-capable counterpart of [LineNumberedTextView]. Line numbers update
/// live as the user types. Supports IME composition (Japanese/CJK).
class LineNumberedTextEditor extends StatefulWidget {
  const LineNumberedTextEditor({
    super.key,
    required this.initialText,
    required this.onChanged,
    this.autofocus = false,
  });

  final String initialText;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  State<LineNumberedTextEditor> createState() => _LineNumberedTextEditorState();
}

class _LineNumberedTextEditorState extends State<LineNumberedTextEditor> {
  late final TextEditingController _controller;
  int _lineCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _lineCount = _linesIn(widget.initialText);
    _controller.addListener(_handleChange);
  }

  @override
  void didUpdateWidget(covariant LineNumberedTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialText != oldWidget.initialText &&
        widget.initialText != _controller.text) {
      _controller.text = widget.initialText;
      _lineCount = _linesIn(widget.initialText);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleChange)
      ..dispose();
    super.dispose();
  }

  void _handleChange() {
    final next = _linesIn(_controller.text);
    if (next != _lineCount) {
      setState(() => _lineCount = next);
    }
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _editorTextStyle(context);
    final gutterStyle = _gutterTextStyle(context);

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Gutter(
                lineCount: _lineCount,
                style: gutterStyle,
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: widget.autofocus,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: textStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isCollapsed: true,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _Gutter extends StatelessWidget {
  const _Gutter({required this.lineCount, required this.style});

  final int lineCount;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    for (var i = 1; i <= lineCount; i++) {
      if (i > 1) buffer.write('\n');
      buffer.write(i);
    }
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Text(
        buffer.toString(),
        textAlign: TextAlign.right,
        style: style,
      ),
    );
  }
}

TextStyle _editorTextStyle(BuildContext context) {
  final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
    fontFamily: AppConfig.fontFamily,
    fontSize: 14,
    height: 1.5,
  );
}

TextStyle _gutterTextStyle(BuildContext context) {
  final base = _editorTextStyle(context);
  return base.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

int _lineCount(String text) {
  if (text.isEmpty) return 1;
  return _linesIn(text);
}

int _linesIn(String text) {
  if (text.isEmpty) return 1;
  var count = 1;
  for (var i = 0; i < text.length; i++) {
    if (text.codeUnitAt(i) == 0x0A) count++;
  }
  return count;
}
