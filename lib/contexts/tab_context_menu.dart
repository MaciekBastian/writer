import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../helpers/general_helper.dart';
import '../models/file_tab.dart';
import '../pages/tools/confirm_close_dialog.dart';
import '../providers/project_state.dart';
import 'context_menu_button.dart';

class TabContextMenu extends StatelessWidget {
  const TabContextMenu({
    super.key,
    required this.tab,
  });
  final FileTab tab;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);
    final theme = Theme.of(context);

    return Container(
      width: 200.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.canvasColor, width: 2.0),
      ),
      child: Column(
        children: [
          ContextMenuButton(
            label: 'taskbar.open'.tr(),
            callback: () {
              final index = provider.indexOfTab(tab);
              provider.switchTab(index);
            },
          ),
          ContextMenuButton(
            label: 'taskbar.save'.tr(),
            callback: () async {
              provider.save(tab);
            },
          ),
          const Divider(
            color: Color(0xFF212121),
            height: 10.0,
            thickness: 2.0,
            indent: 5.0,
            endIndent: 5.0,
          ),
          ContextMenuButton(
            label: 'taskbar.close'.tr(),
            callback: () async {
              final index = provider.indexOfTab(tab);
              if (provider.hasUnsavedChanges(index)) {
                final wantToSave = await showDialog<bool?>(
                  context: context,
                  builder: (context) {
                    return const ConfirmCloseDialog();
                  },
                );

                if (wantToSave != null) {
                  if (wantToSave) {
                    provider.save();
                    provider.closeTab(index);
                  } else {
                    provider.revertChanges(tab);
                    provider.closeTab(index);
                  }
                }
              } else {
                provider.closeTab(index);
              }
            },
          ),
          ContextMenuButton(
            label: 'context_menu.close_others'.tr(),
            callback: () async {
              provider.closeOthers(tab);
            },
          ),
          ContextMenuButton(
            label: 'context_menu.close_to_the_right'.tr(),
            callback: () async {
              final index = provider.indexOfTab(tab);
              provider.closeToTheRight(index);
            },
          ),
          ContextMenuButton(
            label: 'context_menu.close_saved'.tr(),
            callback: () async {
              provider.closeSaved();
            },
          ),
          ContextMenuButton(
            label: 'taskbar.close_all'.tr(),
            callback: () async {
              provider.closeAll();
            },
          ),
          const Divider(
            color: Color(0xFF212121),
            height: 10.0,
            thickness: 2.0,
            indent: 5.0,
            endIndent: 5.0,
          ),
          if (provider.isTabPinned(tab))
            ContextMenuButton(
              label: 'context_menu.unpin'.tr(),
              callback: () async {
                provider.unpinTab(tab);
              },
            )
          else
            ContextMenuButton(
              label: 'context_menu.pin'.tr(),
              callback: () async {
                provider.pinTab(tab);
              },
            ),
          ContextMenuButton(
            label: 'context_menu.copy_name'.tr(),
            callback: () async {
              await Clipboard.setData(
                ClipboardData(
                  text: tab.id != null
                      ? tab.type == FileType.characterEditor
                          ? provider.characters[tab.id] ?? ''
                          : tab.type == FileType.threadEditor
                              ? provider.threads[tab.id] ?? ''
                              : tab.type == FileType.editor
                                  ? provider.chaptersAsMap[tab.id] ?? ''
                                  : ''
                      : GeneralHelper().getFileName(tab.type, tab.path).tr(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
