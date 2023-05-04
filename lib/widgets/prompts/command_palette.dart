import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_similarity/string_similarity.dart';
import '../../helpers/general_helper.dart';

import '../../constants/commands.dart';
import '../../contexts/text_context_menu.dart';

class CommandPalette extends StatefulWidget {
  static const pageName = '/command-palette';
  const CommandPalette({super.key, this.initialCommand});

  final String? initialCommand;

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
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
    _fieldController = TextEditingController(text: widget.initialCommand);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final altCommands = getAltCommands(_fieldController.text).values.toList();
    final commands = [
      ...getAllCommands().values.toList(),
      ...getExtraCommands(context),
    ];
    final Map<String, double> commandsAvgSimilarity = {};
    final availableCommands = commands.where(
      (element) {
        if (_fieldController.text.trim().isEmpty) return true;
        final regexp = RegExp(
          r'[^\p{Alphabetic}\p{Mark}\p{Decimal_Number}\p{Connector_Punctuation}\p{Join_Control}\s]+',
          unicode: true,
          caseSensitive: false,
        );
        final query = _fieldController.text
            .substring(
              _fieldController.text.contains(':')
                  ? _fieldController.text.indexOf(':')
                  : 0,
            )
            .toLowerCase()
            .trim()
            .replaceAll(regexp, '')
            .trim();
        final name = element.name.toLowerCase().replaceAll(regexp, '').trim();
        final similarities = GeneralHelper().getUnifiedList(
          name.split(' ').map((e) {
            return query.split(' ').map((el) {
              return StringSimilarity.compareTwoStrings(e, el);
            }).toList();
          }).toList(),
        );
        final avg = GeneralHelper().average(similarities).toDouble();
        commandsAvgSimilarity[element.name] = avg;
        if (similarities.any((element) => element >= 0.65)) {
          return true;
        } else if (avg > 0.5) {
          return true;
        } else {
          return element.name.toLowerCase().contains(query);
        }
      },
    ).toList();
    if (_fieldController.text.contains(':')) {
      final commandWord = _fieldController.text
          .trim()
          .toLowerCase()
          .substring(0, _fieldController.text.indexOf(':'));
      final commandKeys = getCommandKeys();
      final bestMatch = StringSimilarity.findBestMatch(
        commandWord,
        commandKeys,
      ).bestMatch;

      availableCommands.clear();
      availableCommands.addAll(commands.where((element) {
        final command = element.name.substring(0, element.name.indexOf(':'));
        return command == bestMatch.target;
      }));
      final restOfQuery = _fieldController.text
          .trim()
          .substring(_fieldController.text.indexOf(':') + 1)
          .trim();
      if (restOfQuery.isEmpty) {
        commandsAvgSimilarity.clear();
      }
    }
    availableCommands.sort(
      (a, b) {
        if (commandsAvgSimilarity[b.name] == null ||
            commandsAvgSimilarity[a.name] == null) {
          return a.name.compareTo(b.name);
        }
        return commandsAvgSimilarity[b.name]!.compareTo(
          commandsAvgSimilarity[a.name]!,
        );
      },
    );
    availableCommands.removeWhere(
      (element) => element.command == WrtCommand.viewCommandPalette,
    );
    availableCommands.addAll(altCommands);

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
            if (value.logicalKey == LogicalKeyboardKey.enter ||
                value.logicalKey == LogicalKeyboardKey.numpadEnter) {
              Navigator.of(context).pop();
              availableCommands[_index].callback(context);
            } else if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                _index =
                    _index + 1 == availableCommands.length ? 0 : _index + 1;
                _lastEventDuration = value.timeStamp;
              });
            } else if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                _index = _index - 1 == -1
                    ? availableCommands.length - 1
                    : _index - 1;
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
                      hintText: 'command_palette.search_anything'.tr(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _commandsScroll,
                    itemCount: availableCommands.length,
                    itemBuilder: (context, index) {
                      return _buildCommandTile(availableCommands[index], index);
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

  Material _buildCommandTile(Command command, int index) {
    final theme = Theme.of(context);

    final name = command.name;
    final commandKey = name.substring(
      0,
      command.name.indexOf(':') + 1,
    );
    final restOfCommand = command.name.substring(
      command.name.indexOf(':') + 1,
    );
    final secondaryCommand = restOfCommand.contains(':')
        ? restOfCommand.substring(0, restOfCommand.indexOf(':') + 1)
        : null;
    final restOfSecondaryCommand = secondaryCommand == null
        ? null
        : restOfCommand.substring(restOfCommand.indexOf(':') + 1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pop();
          command.callback(context);
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
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: commandKey,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      if (secondaryCommand != null)
                        TextSpan(
                          text: secondaryCommand,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      TextSpan(
                        text: secondaryCommand == null
                            ? restOfCommand
                            : restOfSecondaryCommand,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(width: 10.0),
              if (command.shortcut != null)
                Row(
                  children: command.shortcut!.split(' ').map((e) {
                    if (e == '+') {
                      return Text(e);
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2.0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 5.0,
                      ),
                      child: Text(
                        e,
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
