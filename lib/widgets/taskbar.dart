import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/commands.dart';
import '../helpers/window_helper.dart';
import '../providers/project_state.dart';
import 'prompts/command_palette.dart';

class TaskBar extends StatefulWidget {
  const TaskBar({super.key});

  @override
  State<TaskBar> createState() => _TaskBarState();
}

class _TaskBarState extends State<TaskBar> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final commands = getMenuBarCommands();

    final windowColors = WindowButtonColors(
      iconNormal: Colors.grey[400],
      iconMouseDown: Colors.white,
      iconMouseOver: Colors.white,
      mouseDown: Colors.grey[800],
      mouseOver: Colors.grey[900],
      normal: Colors.transparent,
    );

    return Container(
      color: const Color(0xFF1C1C1C),
      child: Row(
        children: [
          if (Platform.isWindows)
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.create,
                    size: 18.0,
                  ),
                ),
                _TaskbarButton(
                  isSomeOptionSelected: _isSelected,
                  callback: (val) {
                    setState(() {
                      _isSelected = val;
                    });
                  },
                  title: 'taskbar.file'.tr(),
                  commands: commands[WrtCommandCategory.file]!.values.toList(),
                ),
                _TaskbarButton(
                  isSomeOptionSelected: _isSelected,
                  callback: (val) {
                    setState(() {
                      _isSelected = val;
                    });
                  },
                  title: 'taskbar.edit'.tr(),
                  commands: commands[WrtCommandCategory.edit]!.values.toList(),
                ),
                _TaskbarButton(
                  isSomeOptionSelected: _isSelected,
                  callback: (val) {
                    setState(() {
                      _isSelected = val;
                    });
                  },
                  title: 'taskbar.tools'.tr(),
                  commands: commands[WrtCommandCategory.tools]!.values.toList(),
                ),
                _TaskbarButton(
                  isSomeOptionSelected: _isSelected,
                  callback: (val) {
                    setState(() {
                      _isSelected = val;
                    });
                  },
                  title: 'taskbar.view'.tr(),
                  commands: commands[WrtCommandCategory.view]!.values.toList(),
                ),
                _TaskbarButton(
                  isSomeOptionSelected: _isSelected,
                  callback: (val) {
                    setState(() {
                      _isSelected = val;
                    });
                  },
                  title: 'taskbar.help'.tr(),
                  commands: commands[WrtCommandCategory.help]!.values.toList(),
                ),
              ],
            ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              height: 32.0,
              child: MoveWindow(),
            ),
          ),
          Row(
            children: [
              Consumer<ProjectState>(
                builder: (context, value, _) {
                  return Row(
                    children: [
                      if (value.commandPaletteButton)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6.0),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                barrierDismissible: true,
                                builder: (context) {
                                  return const CommandPalette();
                                },
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.keyboard_command_key,
                                size: 20.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (Platform.isWindows)
                Row(
                  children: [
                    MinimizeWindowButton(
                      colors: windowColors,
                    ),
                    FutureBuilder(
                      future: WindowHelper().isMaximized,
                      builder: (context, snapshot) {
                        if (snapshot.data ?? false) {
                          return RestoreWindowButton(
                            colors: windowColors,
                            onPressed: () {
                              WindowHelper().restore();
                              setState(() {});
                            },
                          );
                        } else {
                          return MaximizeWindowButton(
                            colors: windowColors,
                            onPressed: () {
                              WindowHelper().maximize();
                              setState(() {});
                            },
                          );
                        }
                      },
                    ),
                    CloseWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: Colors.grey[400],
                        iconMouseDown: Colors.white,
                        iconMouseOver: Colors.white,
                        mouseOver: Colors.red,
                        mouseDown: Colors.red[200],
                        normal: Colors.transparent,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(width: 16.0),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskbarButton extends StatefulWidget {
  const _TaskbarButton({
    required this.callback,
    required this.isSomeOptionSelected,
    required this.title,
    required this.commands,
  });

  final String title;
  final void Function(bool val) callback;
  final bool isSomeOptionSelected;
  final List<Command> commands;

  @override
  State<_TaskbarButton> createState() => __TaskbarButtonState();
}

class __TaskbarButtonState extends State<_TaskbarButton> {
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool showOverlay = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
        widget.callback(true);
      } else {
        widget.callback(false);
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry!.remove();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.grey[900],
        splashColor: Colors.transparent,
        focusColor: Colors.grey[850],
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        focusNode: _focusNode,
        onHover: (val) {
          if (widget.isSomeOptionSelected) {
            if (val) {
              _focusNode.requestFocus();
              showOverlay = true;
            }
          }
        },
        mouseCursor: SystemMouseCursors.basic,
        onTap: () {
          _focusNode.requestFocus();
          showOverlay = true;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Text(
            widget.title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _takbarMenuItem(Command command) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      hoverColor: const Color.fromARGB(146, 80, 59, 173),
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        command.callback(context);
        _focusNode.unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 20.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              command.name.substring(command.name.lastIndexOf(':') + 1).trim(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.grey[400],
              ),
            ),
            if (command.shortcut != null)
              Text(
                command.shortcut!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: 300.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 49, 49, 49),
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(
              color: Colors.grey[600]!,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 5.0,
          ),
          child: MouseRegion(
            onEnter: (_) {
              _focusNode.requestFocus();
            },
            onExit: (_) {
              Future.delayed(const Duration(milliseconds: 150), () {
                _focusNode.unfocus();
              });
            },
            child: Material(
              color: Colors.transparent,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.commands.map((e) {
                  return _takbarMenuItem(e);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
