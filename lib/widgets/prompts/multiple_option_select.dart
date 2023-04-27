import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../contexts/text_context_menu.dart';

Future<Object?> showMultipleOptionSelectPrompt(
    Map<String, Object> labelsAndValues,
    String message,
    BuildContext context) async {
  final value = await showDialog<Object?>(
    context: context,
    builder: (context) {
      return _MultipleOptionSelect(
        labels: labelsAndValues.keys.toList(),
        values: labelsAndValues.values.toList(),
        message: message,
      );
    },
  );

  return value;
}

class _MultipleOptionSelect extends StatefulWidget {
  const _MultipleOptionSelect({
    required this.labels,
    required this.values,
    required this.message,
  });

  final List<String> labels;
  final List<Object> values;
  final String message;

  @override
  State<_MultipleOptionSelect> createState() => __MultipleOptionSelectState();
}

class __MultipleOptionSelectState extends State<_MultipleOptionSelect> {
  final _searchNode = FocusNode(
    descendantsAreTraversable: false,
  );
  final _commandsScroll = ScrollController();
  late final TextEditingController _fieldController;
  int _index = 0;
  Duration _lastEventDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fieldController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = _fieldController.text.trim().isEmpty
        ? widget.labels
        : widget.labels
            .where(
              (element) => element.contains(
                _fieldController.text.toLowerCase().trim(),
              ),
            )
            .toList();

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(
        top: 40.0,
      ),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Container(
        width: 500.0,
        height: 350.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: theme.colorScheme.surfaceVariant,
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: KeyboardListener(
          focusNode: _searchNode,
          onKeyEvent: (value) {
            if (_lastEventDuration != Duration.zero) {
              if (value.timeStamp.inMilliseconds -
                      _lastEventDuration.inMilliseconds <
                  300) {
                return;
              }
            }
            if (value.logicalKey == LogicalKeyboardKey.enter) {
              final value = widget.values[widget.labels.indexOf(
                options[_index],
              )];
              Navigator.of(context).pop(value);
            } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                _index = _index + 1 == options.length ? 0 : _index + 1;
                _lastEventDuration = value.timeStamp;
              });
            } else if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                _index = _index - 1 == -1 ? options.length - 1 : _index - 1;
                _lastEventDuration = value.timeStamp;
              });
            }

            final newOffset = 20.0 * _index;
            final min = _commandsScroll.position.minScrollExtent;
            final max = _commandsScroll.position.maxScrollExtent;
            if (newOffset > 150.0) {
              if ((newOffset - 150.0) >= max) {
                _commandsScroll.jumpTo(max);
              } else {
                _commandsScroll.jumpTo(newOffset - 150.0);
              }
            } else {
              _commandsScroll.jumpTo(min);
            }
            _fieldController.selection.expandTo(
              TextPosition(
                offset: _fieldController.text.length - 1,
              ),
            );
          },
          child: Focus(
            canRequestFocus: true,
            descendantsAreTraversable: false,
            child: Column(
              children: [
                SizedBox(
                  height: 50.0,
                  child: TextField(
                    controller: _fieldController,
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        _index = 0;
                      });
                      _commandsScroll.jumpTo(
                        _commandsScroll.position.minScrollExtent,
                      );
                    },
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
                Expanded(
                  child: ListView.builder(
                    controller: _commandsScroll,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final value = widget.values[widget.labels.indexOf(
                        options[_index],
                      )];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.of(context).pop(value);
                          },
                          child: Container(
                            color: index == _index
                                ? const Color.fromARGB(132, 22, 56, 226)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 15.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    options[index],
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
