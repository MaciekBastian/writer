import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../contexts/text_context_menu.dart';

Future<String?> showTextPrompt(BuildContext context, {String? message}) {
  return showDialog<String?>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      return _TextPrompt(
        message: message,
      );
    },
  );
}

class _TextPrompt extends StatefulWidget {
  const _TextPrompt({
    this.message,
  });
  final String? message;

  @override
  State<_TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<_TextPrompt> {
  final _focus = FocusNode();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.only(top: 50.0),
      alignment: Alignment.topCenter,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.black,
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4.0),
        width: 500.0,
        child: SizedBox(
          height: 55.0,
          child: KeyboardListener(
            focusNode: _focus,
            onKeyEvent: (value) {
              if (value.logicalKey == LogicalKeyboardKey.enter) {
                final text = _textController.text.trim();
                Navigator.of(context).pop(text);
              }
            },
            child: TextField(
              controller: _textController,
              autofocus: true,
              contextMenuBuilder: (context, editableTextState) {
                return TextContextMenu(
                  editableTextState: editableTextState,
                );
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 10.0),
                hintText: widget.message,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
