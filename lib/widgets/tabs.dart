import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:provider/provider.dart';
import '../contexts/tab_context_menu.dart';
import '../helpers/general_helper.dart';
import '../pages/tools/confirm_close_dialog.dart';

import '../models/file_tab.dart';
import '../providers/project_state.dart';
import 'saving_indicator.dart';

class WrtTabs extends StatefulWidget {
  const WrtTabs({super.key});

  @override
  State<WrtTabs> createState() => _WrtTabsState();
}

class _WrtTabsState extends State<WrtTabs> {
  final _tabScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<ProjectState>(context);

    return Container(
      height: 45.0,
      color: const Color(0xFF242424),
      child: ImprovedScrolling(
        enableKeyboardScrolling: true,
        enableCustomMouseWheelScrolling: true,
        scrollController: _tabScrollController,
        child: ListView.builder(
          controller: _tabScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: project.openedTabs.length,
          itemBuilder: (context, index) {
            final tab = project.openedTabs[index];
            return _buildTab(index, tab);
          },
        ),
      ),
    );
  }

  Widget _buildTab(int index, FileTab tab) {
    final project = Provider.of<ProjectState>(context);
    final projectProvider = Provider.of<ProjectState>(context, listen: false);
    final theme = Theme.of(context);

    return ContextMenuRegion(
      contextMenu: TabContextMenu(tab: project.openedTabs[index]),
      child: Container(
        width: 180.0,
        height: 45.0,
        color: project.isSelected(index)
            ? const Color(0xFF191919)
            : const Color(0xFF242424),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: project.isSelected(index)
                ? const Color(0xFF101010)
                : Colors.grey[900],
            onTap: () {
              if (!projectProvider.isSelected(index)) {
                projectProvider.switchTab(index);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 10.0,
              ),
              child: Row(
                children: [
                  Icon(
                    GeneralHelper().getTypeIcon(tab.type, tab.path).icon,
                    color: project.isSelected(index)
                        ? Colors.white
                        : Colors.grey[300],
                    size: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      tab.id != null
                          ? tab.type == FileType.characterEditor
                              ? project.characters[tab.id] ?? ''
                              : tab.type == FileType.threadEditor
                                  ? project.threads[tab.id] ?? ''
                                  : tab.type == FileType.editor
                                      ? project.chaptersAsMap[tab.id] ?? ''
                                      : ''
                          : GeneralHelper()
                              .getFileName(tab.type, tab.path)
                              .tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: project.isSelected(index)
                            ? Colors.white
                            : Colors.grey[300],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  if (project.isTabBeingSaved(tab))
                    const SavingIndicator()
                  else if (project.hasUnsavedChanges(index))
                    Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.only(
                        left: 6.0,
                      ),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.only(
                      left: 6.0,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        onTap: () async {
                          if (project.isTabPinned(project.openedTabs[index])) {
                            project.unpinTab(tab);
                            return;
                          }

                          if (project.hasUnsavedChanges(index)) {
                            final wantToSave = await showDialog<bool?>(
                              context: context,
                              builder: (context) {
                                return const ConfirmCloseDialog();
                              },
                            );

                            if (wantToSave != null) {
                              if (wantToSave) {
                                projectProvider.save();
                                project.closeTab(index);
                              } else {
                                projectProvider.revertChanges(tab);
                                project.closeTab(index);
                              }
                            }
                          } else {
                            project.closeTab(index);
                          }
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: project.isTabPinned(project.openedTabs[index])
                            ? const Icon(
                                Icons.push_pin_outlined,
                                size: 20.0,
                                color: Colors.grey,
                              )
                            : Icon(
                                Icons.close,
                                size: 20.0,
                                color: Colors.grey[700],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
