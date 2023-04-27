import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/commands.dart';
import '../helpers/window_helper.dart';
import '../widgets/sidebar.dart';
import '../widgets/statusbar.dart';
import '../widgets/taskbar.dart';
import '../widgets/workspace.dart';

class HomeScreen extends StatefulWidget {
  static const String pageName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final _primaryFocus = FocusNode(
    canRequestFocus: true,
    debugLabel: 'PRIMARY',
    descendantsAreFocusable: true,
    descendantsAreTraversable: true,
  );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(() {
      final currentContext = _scaffold.currentContext;
      if (currentContext != null) {
        final hasFocus = _primaryFocus.hasFocus;
        if (hasFocus) return;
        final focusScope = FocusScope.of(currentContext).focusedChild;
        if (focusScope == null) {
          _primaryFocus.requestFocus();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final commands = {...getAllCommands(), ...getShortcutsOnlyCommands()};
    commands.removeWhere((key, value) => value.keySet == null);

    final scaffold = Scaffold(
      key: _scaffold,
      body: CallbackShortcuts(
        key: const Key('global_shortcuts'),
        bindings: {
          ...commands.map((key, value) {
            return MapEntry(
              value.keySet!,
              () {
                final currentContext = _scaffold.currentContext;
                value.callback(currentContext ?? context);
              },
            );
          }),
        },
        child: Focus(
          autofocus: true,
          canRequestFocus: true,
          descendantsAreFocusable: true,
          focusNode: _primaryFocus,
          child: Column(
            children: [
              // general task bar with actions and platform buttons
              const TaskBar(),
              // app
              Expanded(
                child: Row(
                  children: const [
                    // sidebar
                    Sidebar(),
                    // workspace
                    Expanded(
                      child: Workspace(),
                    ),
                  ],
                ),
              ),
              // status bar
              const Statusbar(),
            ],
          ),
        ),
      ),
    );

    if (Platform.isMacOS) {
      final menu = getMenuBarCommands();

      return ContextMenuOverlay(
        child: PlatformMenuBar(
          menus: [
            // TODO: first app menu
            PlatformMenu(
              // label does not matter as MacOS displays it's own value here
              label: 'Plotweaver',
              menus: [
                // TODO: do this menu
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'taskbar.about'.tr(),
                      onSelected: () {
                        // TODO: link to gitbook
                      },
                    ),
                  ],
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'taskbar.exit'.tr(),
                      onSelected: () {
                        // quit
                        WindowHelper().quit();
                      },
                      shortcut: const SingleActivator(
                        LogicalKeyboardKey.keyQ,
                        meta: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ...menu.entries.map((commandsCat) {
              return PlatformMenu(
                label: getCommandCategoryName(commandsCat.key),
                menus: [
                  PlatformMenuItemGroup(
                    members: commandsCat.value.entries.map((value) {
                      final command = value.value;

                      return PlatformMenuItem(
                        label: command.name
                            .substring(command.name.lastIndexOf(':') + 1)
                            .trim(),
                        shortcut: command.keySet,
                        onSelected: () {
                          command.callback(_scaffold.currentContext ?? context);
                        },
                      );
                    }).toList(),
                  ),
                  if (commandsCat.key == WrtCommandCategory.view)
                    PlatformMenuItemGroup(
                      members: getShortcutsOnlyCommands()
                          .map((key, value) {
                            return MapEntry(
                              key,
                              PlatformMenuItem(
                                label: value.name,
                                shortcut: value.keySet,
                                onSelected: () {
                                  value.callback(
                                    _scaffold.currentContext ?? context,
                                  );
                                },
                              ),
                            );
                          })
                          .values
                          .toList(),
                    ),
                ],
              );
            }).toList()
          ],
          child: scaffold,
        ),
      );
    }

    return ContextMenuOverlay(
      child: scaffold,
    );
  }
}
