import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../helpers/general_helper.dart';
import '../models/chapters/chapter.dart';
import '../models/file_tab.dart';
import '../models/sidebar_tab.dart';
import '../providers/project_state.dart';
import '../providers/version_control.dart';
import '../widgets/prompts/command_palette.dart';
import '../widgets/prompts/new_file.dart';
import '../widgets/prompts/tab_switcher_dialog.dart';
import 'system_pages.dart';

enum WrtCommandCategory {
  goTo,
  switchTo,
  file,
  edit,
  search,
  version,
  tools,
  view,
  help,
}

enum WrtCommand {
  // "go to" commands
  goToGeneral,
  goToTimeline,
  goToPlotDevelopment,
  goToEdior,
  goToThread,
  goToCharacter,
  goToSystemPage,

  // "file" commands
  fileSave,
  fileSaveAll,
  fileLookForErrors,
  fileClose,
  fileCloseAll,
  fileCloseOthers,
  fileCloseSaved,
  filePin,
  fileNew,
  fileOpen,
  fileOpenRecent,
  fileReload,
  fileExport,
  fileCloseProject,
  fileExit,

  // "edit" commands
  editUndo,
  editRedo,

  // "View" commands
  switchToProject,
  switchToProjectSearch,
  switchToResources,
  switchToVersionControl,
  switchToLayoutSettings,
  switchToErrors,
  switchToSecondarySidebar,
  viewCommandPalette,

  // "Version" commands
  versionSwitchToVersionControl,
  versionStartVersioning,
  versionCommit,

  // "Tools" commands
  toolsCreateCharacter,
  toolsCreateThread,
  toolsAddChapter,

  // "Help" commands
  helpReleaseNotes,
  helpReportIssue,
  helpLicenses,
  helpAbout,

  // EXTRA COMMANDS
  extraSearch,

  // SHORTCUTS ONLY
  shortcutTabSwitch,
  shortcutTabSwitchReverse,
  shortcutGoTo,
}

class Command {
  /// Comand representing the command
  final WrtCommand command;

  /// Localized name
  final String name;

  /// Callback of this command
  final void Function(BuildContext context) callback;

  /// Keyboard shortcut, if present
  final String? shortcut;

  /// actual shortcut
  final SingleActivator? keySet;

  Command({
    required this.command,
    required this.callback,
    required this.name,
    this.shortcut,
    this.keySet,
  }) : assert(
          keySet != null && shortcut != null ||
              keySet == null && shortcut == null ||
              (shortcut != null &&
                  keySet == null &&
                  shortcut.characters.elementAt(shortcut.length - 2) == ' '),
        );
}

Map<WrtCommandCategory, String> _categoryNames = {
  WrtCommandCategory.goTo: 'command_palette.go_to'.tr(),
  WrtCommandCategory.switchTo: 'command_palette.switch_to'.tr(),
  WrtCommandCategory.file: 'taskbar.file'.tr(),
  WrtCommandCategory.edit: 'taskbar.edit'.tr(),
  WrtCommandCategory.tools: 'taskbar.tools'.tr(),
  WrtCommandCategory.search: 'command_palette.search_in_project'.tr(),
  WrtCommandCategory.version: 'command_palette.version'.tr(),
  WrtCommandCategory.help: 'taskbar.help'.tr(),
  WrtCommandCategory.view: 'taskbar.view'.tr(),
};

String getCommandCategoryName(WrtCommandCategory category) {
  return _categoryNames[category] ?? '';
}

List<String> getCommandKeys() => [
      _categoryNames[WrtCommandCategory.goTo]!,
      _categoryNames[WrtCommandCategory.switchTo]!,
      _categoryNames[WrtCommandCategory.file]!,
      _categoryNames[WrtCommandCategory.edit]!,
      _categoryNames[WrtCommandCategory.search]!,
      _categoryNames[WrtCommandCategory.version]!,
      _categoryNames[WrtCommandCategory.help]!,
      _categoryNames[WrtCommandCategory.tools]!,
      _categoryNames[WrtCommandCategory.edit]!,
    ];

/// Returns commands based on current project (those can't be included in menu bar)
List<Command> getExtraCommands(BuildContext context) {
  final provider = Provider.of<ProjectState>(context, listen: false);

  final goTo = _categoryNames[WrtCommandCategory.goTo]!;

  final extra = [
    ...provider.characters.entries.map((e) {
      return Command(
        command: WrtCommand.goToCharacter,
        callback: (context) {
          if (provider.isProjectOpened) {
            provider.openCharacter(e.key);
          }
        },
        name: '$goTo: ${'command_palette.character'.tr()}: ${e.value}',
      );
    }).toList(),
    ...provider.threads.entries.map((e) {
      return Command(
        command: WrtCommand.goToThread,
        callback: (context) {
          if (provider.isProjectOpened) {
            provider.openThread(e.key);
          }
        },
        name: '$goTo: ${'command_palette.thread'.tr()}: ${e.value}',
      );
    }).toList(),
    ...provider.chaptersAsMap.entries.map((e) {
      return Command(
        command: WrtCommand.goToEdior,
        callback: (context) {
          if (provider.isProjectOpened) {
            provider.openChapterEditor(e.key);
          }
        },
        name: '$goTo: ${'command_palette.chapter'.tr()}: ${e.value}',
      );
    }).toList(),
    ...systemPages.entries.map((e) {
      return Command(
        command: WrtCommand.goToSystemPage,
        callback: (context) {
          if (provider.isProjectOpened) {
            provider.openTab(
              FileTab(id: null, path: e.key, type: FileType.system),
            );
          }
        },
        name: '$goTo: ${(systemPagesNames[e.key])!.tr()}',
      );
    }).toList(),
  ];

  return extra;
}

Map<WrtCommand, Command> getShortcutsOnlyCommands() {
  final ctrl = Platform.isMacOS ? '⌘' : 'Ctrl';
  final shift = Platform.isMacOS ? '⇧' : 'Shift';

  return {
    WrtCommand.shortcutGoTo: Command(
      command: WrtCommand.shortcutGoTo,
      callback: (context) {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (context) {
            return CommandPalette(
              initialCommand: '${'command_palette.go_to'.tr()}: ',
            );
          },
        );
      },
      name: _categoryNames[WrtCommandCategory.goTo]!,
      shortcut: '$ctrl + G',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyG,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    WrtCommand.shortcutTabSwitch: Command(
      command: WrtCommand.shortcutTabSwitch,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.openedTabs.isNotEmpty && !provider.isTabSwitcherOpened) {
            provider.toggleTabSwitcher();
            await showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => const TabSwitcherDialog(),
            );
            provider.toggleTabSwitcher();
          }
        }
      },
      name: 'taskbar.next_tab'.tr(),
      shortcut: '${Platform.isMacOS ? '^' : ctrl} + Tab',
      keySet: const SingleActivator(
        LogicalKeyboardKey.tab,
        control: true,
      ),
    ),
    WrtCommand.shortcutTabSwitchReverse: Command(
      command: WrtCommand.shortcutTabSwitchReverse,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.openedTabs.isNotEmpty && !provider.isTabSwitcherOpened) {
            provider.toggleTabSwitcher();
            await showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) => const TabSwitcherDialog(revert: true),
            );
            provider.toggleTabSwitcher();
          }
        }
      },
      name: 'taskbar.previous_tab'.tr(),
      shortcut: '${Platform.isMacOS ? '^' : ctrl} + $shift + Tab',
      keySet: const SingleActivator(
        LogicalKeyboardKey.tab,
        control: true,
        shift: true,
      ),
    ),
  };
}

Map<WrtCommand, Command> getAllCommands() {
  final goTo = _categoryNames[WrtCommandCategory.goTo]!;
  final file = _categoryNames[WrtCommandCategory.file]!;
  final edit = _categoryNames[WrtCommandCategory.edit]!;
  final help = _categoryNames[WrtCommandCategory.help]!;
  final switchTo = _categoryNames[WrtCommandCategory.switchTo]!;
  final version = _categoryNames[WrtCommandCategory.version]!;
  final newFile = _categoryNames[WrtCommandCategory.tools]!;

  final ctrl = Platform.isMacOS ? '⌘' : 'Ctrl';
  final shift = Platform.isMacOS ? '⇧' : 'Shift';

  final goToCommands = <Command>[
    Command(
      command: WrtCommand.goToGeneral,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.openTab(
            FileTab(id: null, path: null, type: FileType.general),
          );
        }
      },
      name: '$goTo: ${'project.general'.tr()}',
      shortcut: '$ctrl + 1',
      keySet: SingleActivator(
        LogicalKeyboardKey.digit1,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.goToTimeline,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.openTab(
            FileTab(id: null, path: null, type: FileType.timelineEditor),
          );
        }
      },
      name: '$goTo: ${'project.timeline'.tr()}',
      shortcut: '$ctrl + 2',
      keySet: SingleActivator(
        LogicalKeyboardKey.digit2,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.goToPlotDevelopment,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.openTab(
            FileTab(id: null, path: null, type: FileType.plotDevelopment),
          );
        }
      },
      name: '$goTo: ${'project.plot_development'.tr()}',
      shortcut: '$ctrl + 3',
      keySet: SingleActivator(
        LogicalKeyboardKey.digit3,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
  ];
  final fileCommands = <Command>[
    Command(
      command: WrtCommand.fileSave,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.selectedTab != null) {
            provider.save();
          }
        }
      },
      name: '$file: ${'taskbar.save'.tr()}',
      shortcut: '$ctrl + S',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyS,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.fileSaveAll,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.saveAll();
        }
      },
      name: '$file: ${'taskbar.save_all'.tr()}',
      shortcut: '$ctrl + $shift + S',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyS,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
    Command(
      command: WrtCommand.fileLookForErrors,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.lookForErrors();
        }
      },
      name: '$file: ${'command_palette.look_for_errors'.tr()}',
    ),
    Command(
      command: WrtCommand.fileClose,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.selectedTab == null) return;
          if (provider.isSelectedSaved) {
            provider.closeTab(provider.selectedIndex);
          } else {
            provider.save();
            provider.closeTab(provider.selectedIndex);
          }
        }
      },
      name: '$file: ${'taskbar.close'.tr()}',
      shortcut: '$ctrl + W',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyW,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.fileCloseAll,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.saveAll();
          provider.closeAll();
        }
      },
      name: '$file: ${'taskbar.close_all'.tr()}',
      shortcut: '$ctrl + $shift + W',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyW,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
    Command(
      command: WrtCommand.fileCloseOthers,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.isAnyTabSelected) {
            provider.closeOthers(provider.openedTabs[provider.selectedIndex]);
          }
        }
      },
      name: '$file: ${'context_menu.close_others'.tr()}',
    ),
    Command(
      command: WrtCommand.fileCloseSaved,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.closeSaved();
        }
      },
      name: '$file: ${'context_menu.close_saved'.tr()}',
    ),
    Command(
      command: WrtCommand.filePin,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.isAnyTabSelected) {
            final isPinned = provider.isTabPinned(provider.selectedTab!);
            if (isPinned) {
              provider.unpinTab(provider.selectedTab!);
            } else {
              provider.pinTab(provider.selectedTab!);
            }
          }
        }
      },
      name: '$file: ${'context_menu.pin'.tr()} / ${'context_menu.unpin'.tr()}',
    ),
    Command(
      command: WrtCommand.fileNew,
      callback: (context) async {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (context) => const NewFilePrompt(),
        );
      },
      name: '$file: ${'taskbar.new'.tr()}',
      shortcut: '$ctrl + N',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyN,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.fileOpen,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        // TODO: implement open file
      },
      name: '$file: ${'taskbar.open'.tr()}',
      shortcut: '$ctrl + O',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyO,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.fileOpenRecent,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        // TODO: implement open recent
      },
      name: '$file: ${'taskbar.open_recent'.tr()}',
    ),
    Command(
      command: WrtCommand.fileReload,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.reloadProject();
      },
      name: '$file: ${'taskbar.reload'.tr()}',
      shortcut: 'f5',
      keySet: SingleActivator(LogicalKeyboardKey.f5),
    ),
    Command(
      command: WrtCommand.fileExport,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        // TODO: file export
      },
      name: '$file: ${'taskbar.export'.tr()}',
    ),
    Command(
      command: WrtCommand.fileCloseProject,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.closeProject();
        }
      },
      name: '$file: ${'taskbar.close_project'.tr()}',
    ),
    Command(
      command: WrtCommand.fileExit,
      callback: (context) async {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          /// TODO: closing app
        }
      },
      name: '$file: ${'taskbar.exit'.tr()}',
    ),
  ];
  final editCommands = <Command>[
    Command(
      command: WrtCommand.editUndo,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.undo();
        }
      },
      name: '$edit: ${'taskbar.undo'.tr()}',
      shortcut: '$ctrl + Z',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyZ,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.editRedo,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.redo();
        }
      },
      name: '$edit: ${'taskbar.redo'.tr()}',
      shortcut: '$ctrl + Y',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyY,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
  ];
  final tabsCommands = <Command>[
    Command(
      command: WrtCommand.switchToProject,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.switchSidebarTab(SidebarTab.project);
      },
      name: '$switchTo: ${'taskbar.project'.tr()}',
      shortcut: '$ctrl + P',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyP,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.switchToProjectSearch,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.switchSidebarTab(SidebarTab.projectSearch);
      },
      name: '$switchTo: ${'taskbar.project_search'.tr()}',
      shortcut: '$ctrl + $shift + F',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyF,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
    Command(
      command: WrtCommand.switchToResources,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.switchSidebarTab(SidebarTab.resources);
      },
      name: '$switchTo: ${'taskbar.resources'.tr()}',
      shortcut: '$ctrl + $shift + R',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyR,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
    Command(
      command: WrtCommand.switchToVersionControl,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.switchSidebarTab(SidebarTab.versionControl);
      },
      name: '$switchTo: ${'taskbar.version_control'.tr()}',
      shortcut: '$ctrl + $shift + V',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyV,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
    Command(
      command: WrtCommand.switchToLayoutSettings,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.switchSidebarTab(SidebarTab.layoutSettings);
      },
      name: '$switchTo: ${'taskbar.layout_settings'.tr()}',
      shortcut: '$ctrl + ${'keyboard.comma'.tr()}',
      keySet: SingleActivator(
        LogicalKeyboardKey.comma,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.switchToErrors,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.switchErrorPanel();
        }
      },
      name: '$switchTo: ${'preferences.layout.error_pannel'.tr()}',
      shortcut: '$ctrl + E',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyE,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.switchToSecondarySidebar,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          if (provider.showRightSidebar) {
            provider.toggleRightSidebar();
          } else {
            provider.toggleShowRightSidebar();
            provider.toggleRightSidebar(true);
          }
        }
      },
      name: '$switchTo: ${'preferences.layout.secondary_sidebar'.tr()}',
      shortcut: '$ctrl + /',
      keySet: SingleActivator(
        LogicalKeyboardKey.slash,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
      ),
    ),
    Command(
      command: WrtCommand.viewCommandPalette,
      callback: (BuildContext context) {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (context) {
            return const CommandPalette();
          },
        );
      },
      name: '$switchTo: ${'taskbar.command_palette'.tr()}',
      shortcut: '$ctrl + $shift + P',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyP,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
  ];
  final versionCtrlCommands = <Command>[
    Command(
      command: WrtCommand.versionSwitchToVersionControl,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        provider.switchSidebarTab(SidebarTab.versionControl);
      },
      name: '$version: $switchTo: ${'taskbar.version_control'.tr()}',
      shortcut: '$ctrl + $shift + V',
      keySet: SingleActivator(
        LogicalKeyboardKey.keyV,
        control: Platform.isMacOS ? false : true,
        meta: Platform.isMacOS,
        shift: true,
      ),
    ),
    Command(
      command: WrtCommand.versionStartVersioning,
      callback: (BuildContext context) {
        final versionControl = Provider.of<VersionControl>(
          context,
          listen: false,
        );
        if (versionControl.isLoading) return;
        if (versionControl.isVersioningEnabled) return;
        if (versionControl.current != null) return;
        versionControl.startVersioning();
      },
      name: '$version: ${'version_control.start_versioning'.tr()}',
    ),
    Command(
      command: WrtCommand.versionCommit,
      callback: (BuildContext context) {
        final versionControl = Provider.of<VersionControl>(
          context,
          listen: false,
        );
        if (versionControl.isLoading) return;
        if (!versionControl.isVersioningEnabled) return;
        if (versionControl.current == null) return;
        if (versionControl.current!.commited) return;
        versionControl.commit();
      },
      name: '$version: ${'version_control.commit'.tr()}',
    ),
  ];
  final toolsCommands = <Command>[
    Command(
      command: WrtCommand.toolsCreateCharacter,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.addCharacter();
        }
      },
      name: '$newFile: ${'taskbar.create_character'.tr()}',
      shortcut: '$ctrl + N C',
    ),
    Command(
      command: WrtCommand.toolsCreateThread,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.addThread();
        }
      },
      name: '$newFile: ${'taskbar.create_thread'.tr()}',
      shortcut: '$ctrl + N T',
    ),
    Command(
      command: WrtCommand.toolsAddChapter,
      callback: (BuildContext context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.createChapterAndOpenEditor(
            Chapter(
              id: GeneralHelper().id(),
              name:
                  '${'timeline.chapter'.tr()} ${provider.chapters.length + 1}.',
              index: provider.chapters.length,
            ),
          );
        }
      },
      name: '$newFile: ${'taskbar.add_chapter'.tr()}',
      shortcut: '$ctrl + N E',
    ),
  ];
  final helpCommands = <Command>[
    Command(
      command: WrtCommand.helpReleaseNotes,
      callback: (context) {
        // TODO: Relesase note
      },
      name: '$help: ${'taskbar.release_notes'.tr()}',
    ),
    Command(
      command: WrtCommand.helpReportIssue,
      callback: (context) {
        // TODO: report issuee
      },
      name: '$help: ${'taskbar.report_issue'.tr()}',
    ),
    Command(
      command: WrtCommand.helpLicenses,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.openTab(
            FileTab(
              id: null,
              path: '/about/licenses',
              type: FileType.system,
            ),
          );
        }
      },
      name: '$help: ${'taskbar.licenses'.tr()}',
    ),
    Command(
      command: WrtCommand.helpAbout,
      callback: (context) {
        // TODO: about
      },
      name: '$help: ${'taskbar.about'.tr()}',
    ),
  ];

  return {
    ...goToCommands.asMap().map((_, val) => MapEntry(val.command, val)),
    ...fileCommands.asMap().map((_, val) => MapEntry(val.command, val)),
    ...editCommands.asMap().map((_, val) => MapEntry(val.command, val)),
    ...tabsCommands.asMap().map((_, val) => MapEntry(val.command, val)),
    ...versionCtrlCommands.asMap().map((_, val) => MapEntry(val.command, val)),
    ...toolsCommands.asMap().map((_, val) => MapEntry(val.command, val)),
    ...helpCommands.asMap().map((_, val) => MapEntry(val.command, val)),
  };
}

Map<WrtCommand, Command> getAltCommands(String query) {
  final search = _categoryNames[WrtCommandCategory.search];
  return [
    Command(
      command: WrtCommand.extraSearch,
      callback: (context) {
        final provider = Provider.of<ProjectState>(context, listen: false);
        if (provider.isProjectOpened) {
          provider.switchSidebarTab(SidebarTab.projectSearch);
          provider.projectSearch(query.trim());
        }
      },
      name: '$search: ${query.trim()}',
    ),
  ].asMap().map((_, value) => MapEntry(value.command, value));
}

Map<WrtCommandCategory, Map<WrtCommand, Command>> getMenuBarCommands() {
  final allCommands = getAllCommands();

  return {
    /// FILE
    WrtCommandCategory.file: [
      allCommands[WrtCommand.fileNew],
      allCommands[WrtCommand.fileOpen],
      allCommands[WrtCommand.fileOpenRecent],
      allCommands[WrtCommand.fileSave],
      allCommands[WrtCommand.fileSaveAll],
      allCommands[WrtCommand.fileReload],
      allCommands[WrtCommand.fileExport],
      allCommands[WrtCommand.fileClose],
      allCommands[WrtCommand.fileCloseAll],
      allCommands[WrtCommand.fileCloseSaved],
      allCommands[WrtCommand.fileCloseOthers],
      allCommands[WrtCommand.fileCloseProject],
      allCommands[WrtCommand.fileExit],
    ].asMap().map((_, val) => MapEntry(val!.command, val)),

    /// EDIT
    WrtCommandCategory.edit: [
      allCommands[WrtCommand.editUndo],
      allCommands[WrtCommand.editRedo],
    ].asMap().map((_, val) => MapEntry(val!.command, val)),

    /// TOOLS
    WrtCommandCategory.tools: [
      allCommands[WrtCommand.toolsCreateCharacter],
      allCommands[WrtCommand.toolsCreateThread],
      allCommands[WrtCommand.toolsAddChapter],
    ].asMap().map((_, val) => MapEntry(val!.command, val)),

    /// VIEW
    WrtCommandCategory.view: [
      allCommands[WrtCommand.viewCommandPalette],
      allCommands[WrtCommand.switchToProject],
      allCommands[WrtCommand.switchToProjectSearch],
      allCommands[WrtCommand.switchToResources],
      allCommands[WrtCommand.switchToVersionControl],
      allCommands[WrtCommand.switchToLayoutSettings],
      allCommands[WrtCommand.switchToErrors],
    ].asMap().map((_, val) => MapEntry(val!.command, val)),

    /// HELP
    WrtCommandCategory.help: [
      allCommands[WrtCommand.helpReleaseNotes],
      allCommands[WrtCommand.helpReportIssue],
      allCommands[WrtCommand.helpLicenses],
      allCommands[WrtCommand.helpAbout],
    ].asMap().map((_, val) => MapEntry(val!.command, val)),
  };
}
