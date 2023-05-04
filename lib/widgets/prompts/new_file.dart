import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/commands.dart';

class NewFilePrompt extends StatefulWidget {
  const NewFilePrompt({super.key});

  @override
  State<NewFilePrompt> createState() => _NewFilePromptState();
}

class _NewFilePromptState extends State<NewFilePrompt> {
  final _focus = FocusNode();
  bool _visible = false;
  bool _error = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _timer = null;
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commands = getAllCommands();

    return Dialog(
      alignment: _visible ? Alignment.topCenter : Alignment.bottomCenter,
      insetPadding: const EdgeInsets.only(
        top: 40.0,
      ),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: KeyboardListener(
        autofocus: true,
        onKeyEvent: (value) {
          if (value.logicalKey == LogicalKeyboardKey.keyN ||
              value.logicalKey == LogicalKeyboardKey.controlLeft ||
              value.logicalKey == LogicalKeyboardKey.controlRight) return;
          _timer?.cancel();
          if (value.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return;
          }
          if (value.logicalKey == LogicalKeyboardKey.keyC) {
            commands[WrtCommand.toolsCreateCharacter]!.callback(context);
            Navigator.of(context).pop();
            setState(() {
              _timer = null;
            });
            return;
          } else if (value.logicalKey == LogicalKeyboardKey.keyT) {
            commands[WrtCommand.toolsCreateThread]!.callback(context);
            Navigator.of(context).pop();
            setState(() {
              _timer = null;
            });
            return;
          } else if (value.logicalKey == LogicalKeyboardKey.keyE) {
            commands[WrtCommand.toolsAddChapter]!.callback(context);
            Navigator.of(context).pop();
            setState(() {
              _timer = null;
            });
            return;
          }

          setState(() {
            _visible = true;
            _error = true;
            _timer = null;
          });
        },
        focusNode: _focus,
        child: Focus(
          autofocus: true,
          canRequestFocus: true,
          descendantsAreTraversable: false,
          child: !_visible
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 1.0),
                  child: Text(
                    'new_file.ctrl_n_pressed'
                        .tr(args: [Platform.isMacOS ? '⌘' : 'Ctrl']),
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : Container(
                  width: 500.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: theme.colorScheme.surfaceVariant,
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 3.0,
                        color: Colors.black45,
                        blurRadius: 20.0,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'new_file.new_file'.tr().toUpperCase(),
                                textAlign: TextAlign.left,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.white10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 15.0,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    '- C',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.white10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.upcoming_outlined,
                                    size: 15.0,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    '- T',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: 5.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: Colors.white10,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history_edu,
                                    size: 15.0,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    '- E',
                                    style: theme.textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15.0),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 8.0,
                        thickness: 2.0,
                        indent: 4.0,
                        endIndent: 4.0,
                        color: Color(0xFF242424),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            if (_error)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Text(
                                  'new_file.command_not_recognized'.tr(),
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  commands[WrtCommand.toolsCreateCharacter]!
                                      .callback(
                                    context,
                                  );
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: theme.colorScheme.primary,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    top: 4.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    'new_file.create_character'.tr(),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  commands[WrtCommand.toolsCreateThread]!
                                      .callback(
                                    context,
                                  );
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: theme.colorScheme.primary,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    top: 4.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    'new_file.create_thread'.tr(),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  commands[WrtCommand.toolsAddChapter]!
                                      .callback(
                                    context,
                                  );
                                  Navigator.of(context).pop();
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: theme.colorScheme.primary,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    top: 4.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    'new_file.add_chapter'.tr(),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
