import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../contexts/text_context_menu.dart';
import '../providers/selection.dart';
import 'models/styled_text_controller.dart';

class WrtTextField extends StatefulWidget {
  const WrtTextField({
    super.key,
    required this.onEdit,
    this.initialValue,
    this.title,
    this.number = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.altText,
    this.borderless = false,
    this.badge,
    this.onSubmit,
    this.nopadding = false,
    this.selectAllOnFocus = false,
    this.selectNextAfterSubmit = false,
  });

  final void Function(String value) onEdit;
  final void Function(String value)? onSubmit;
  final String? initialValue;
  final String? title;
  final bool number;
  final int minLines;
  final int maxLines;
  final String? altText;
  final bool borderless;
  final Widget? badge;
  final bool nopadding;
  final bool selectAllOnFocus;
  final bool selectNextAfterSubmit;

  @override
  State<WrtTextField> createState() => _WrtTextFieldState();
}

class _WrtTextFieldState extends State<WrtTextField> {
  Timer? _timer;
  late final StyledTextController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final selectionManager = Provider.of<SelectionManager>(
      context,
      listen: false,
    );
    _controller = StyledTextController(text: widget.initialValue);
    _controller.addListener(() {
      if (_controller.selection.isCollapsed) {
        selectionManager.clear();
      } else {
        selectionManager.updateSelection(
          _controller.selection,
          _controller.selection.textInside(_controller.text),
        );
      }
    });
    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
            event.logicalKey == LogicalKeyboardKey.controlRight ||
            event.logicalKey == LogicalKeyboardKey.shiftLeft ||
            event.logicalKey == LogicalKeyboardKey.shiftRight ||
            event.logicalKey == LogicalKeyboardKey.metaLeft ||
            event.logicalKey == LogicalKeyboardKey.metaRight) {
          if (_timer?.isActive ?? false) {
            widget.onEdit(_controller.text);
            _timer?.cancel();
          }
        }

        return KeyEventResult.ignored;
      },
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        selectionManager.initializeController(_controller);
      } else {
        selectionManager.removeController();
      }
      if (widget.selectAllOnFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant WrtTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null) {
      if (widget.initialValue != _controller.text) {
        _controller.text = widget.initialValue!;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _registerChange(String _) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(
      const Duration(milliseconds: 600),
      () {
        widget.onEdit(_controller.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(6.0),
          border: widget.borderless
              ? null
              : Border.all(
                  color: const Color(0xFF5D5D5D),
                  width: 2.0,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, bottom: 2.0),
                      child: Text(
                        widget.title!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                  if (widget.badge != null) widget.badge!,
                ],
              ),
            Expanded(
              child: TextField(
                inputFormatters: [
                  if (widget.number)
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                focusNode: _focusNode,
                controller: _controller,
                cursorColor: const Color(0xFF1638E2),
                onChanged: _registerChange,
                onSubmitted: (val) {
                  if (widget.onSubmit != null) {
                    widget.onSubmit!(val);
                  }
                  if (widget.selectNextAfterSubmit) {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        _focusNode.requestFocus();
                        FocusScope.of(context).nextFocus();
                      },
                    );
                  }
                },
                scrollPadding: const EdgeInsets.all(0.0),
                style: theme.textTheme.titleMedium,
                minLines: widget.minLines,
                maxLines: widget.maxLines,
                contextMenuBuilder: (context, editableTextState) {
                  return TextContextMenu(
                    editableTextState: editableTextState,
                  );
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.altText,
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  contentPadding: widget.nopadding
                      ? const EdgeInsets.all(0.0)
                      : const EdgeInsets.only(
                          right: 10.0,
                          left: 5.0,
                          bottom: 3.0,
                          top: 6.0,
                        ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
