import 'dart:async';

import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:writer/widgets/saving_indicator.dart';

import '../contexts/tab_context_menu.dart';
import '../helpers/general_helper.dart';
import '../models/file_tab.dart';
import '../pages/tools/confirm_close_dialog.dart';
import '../providers/project_state.dart';

class TabTile extends StatefulWidget {
  const TabTile({
    super.key,
    required this.index,
    required this.tab,
    this.duration = const Duration(milliseconds: 2000),
  });
  final int index;
  final FileTab tab;
  final Duration duration;

  @override
  State<TabTile> createState() => _TabTileState();
}

class _TabTileState extends State<TabTile> {
  Timer? _timer;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<ProjectState>(context);
    final projectProvider = Provider.of<ProjectState>(context, listen: false);
    final theme = Theme.of(context);

    final tabName = widget.tab.id != null
        ? widget.tab.type == FileType.characterEditor
            ? project.characters[widget.tab.id] ?? ''
            : widget.tab.type == FileType.threadEditor
                ? project.threads[widget.tab.id] ?? ''
                : widget.tab.type == FileType.editor
                    ? project.chaptersAsMap[widget.tab.id] ?? ''
                    : ''
        : GeneralHelper().getFileName(widget.tab.type, widget.tab.path).tr();
    final fileType = widget.tab.type == FileType.characterEditor
        ? 'file_types.character'
        : widget.tab.type == FileType.threadEditor
            ? 'file_types.thread'
            : widget.tab.type == FileType.timelineEditor
                ? 'file_types.chapters'
                : widget.tab.type == FileType.editor
                    ? 'file_types.chapter'
                    : widget.tab.type == FileType.general ||
                            widget.tab.type == FileType.plotDevelopment
                        ? 'file_types.project'
                        : widget.tab.type == FileType.system
                            ? 'file_types.app'
                            : widget.tab.type == FileType.userFile
                                ? 'file_types.user_file'
                                : 'file_types.tab';

    final tabWidget = MouseRegion(
      onEnter: (_) {
        if (_timer?.isActive ?? false) return;
        _timer = Timer(const Duration(milliseconds: 800), () {
          setState(() {
            _hovering = true;
          });
        });
      },
      onExit: (event) {
        _timer?.cancel();
        setState(() {
          _hovering = false;
        });
      },
      child: ContextMenuRegion(
        enableLongPress: false,
        contextMenu: TabContextMenu(tab: project.openedTabs[widget.index]),
        child: Container(
          width: 180.0,
          height: 45.0,
          color: project.isSelected(widget.index)
              ? const Color(0xFF191919)
              : const Color(0xFF242424),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: project.isSelected(widget.index)
                  ? const Color(0xFF101010)
                  : Colors.grey[900],
              onTap: () {
                if (!projectProvider.isSelected(widget.index)) {
                  projectProvider.switchTab(widget.index);
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
                      GeneralHelper()
                          .getTypeIcon(widget.tab.type, widget.tab.path)
                          .icon,
                      color: project.isSelected(widget.index)
                          ? Colors.white
                          : Colors.grey,
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: MouseRegion(
                        onEnter: (_) {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tabName,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: project.isSelected(widget.index)
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                            if (_hovering)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  fileType.tr(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                    if (project.isTabBeingSaved(widget.tab))
                      const SavingIndicator()
                    else if (project.hasUnsavedChanges(widget.index))
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
                            if (project.isTabPinned(
                                project.openedTabs[widget.index])) {
                              project.unpinTab(widget.tab);
                              return;
                            }

                            if (project.hasUnsavedChanges(widget.index)) {
                              final wantToSave = await showDialog<bool?>(
                                context: context,
                                builder: (context) {
                                  return const ConfirmCloseDialog();
                                },
                              );

                              if (wantToSave != null) {
                                if (wantToSave) {
                                  projectProvider.save();
                                  project.closeTab(widget.index);
                                } else {
                                  projectProvider.revertChanges(widget.tab);
                                  project.closeTab(widget.index);
                                }
                              }
                            } else {
                              project.closeTab(widget.index);
                            }
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: project
                                  .isTabPinned(project.openedTabs[widget.index])
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
      ),
    );
    return Draggable<FileTab>(
      data: widget.tab,
      maxSimultaneousDrags: 1,
      onDragStarted: () {
        setState(() {
          _hovering = false;
          _timer?.cancel();
        });
      },
      feedback: Container(
        key: Key('dragging_feedback_tab_$tabName'),
        width: 180.0,
        height: 45.0,
        color: const Color(0xFF191919),
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 10.0,
        ),
        child: Row(
          children: [
            Icon(
              GeneralHelper()
                  .getTypeIcon(widget.tab.type, widget.tab.path)
                  .icon,
              color:
                  project.isSelected(widget.index) ? Colors.white : Colors.grey,
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                tabName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: project.isSelected(widget.index)
                      ? Colors.white
                      : Colors.grey,
                ),
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
      child: DragTarget<FileTab>(
        builder: (context, candidateData, rejectedData) {
          if (candidateData.isNotEmpty) {
            final candidate = candidateData.first;
            if (candidate != null) {
              return Stack(
                children: [
                  tabWidget,
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1638E2),
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          }
          return tabWidget;
        },
        onWillAccept: (data) {
          if (data == null) return false;
          final draggableIdentifier = data.id ?? data.path ?? data.type.name;
          final tabIdenfitier =
              widget.tab.id ?? widget.tab.path ?? widget.tab.type.name;
          return draggableIdentifier != tabIdenfitier;
        },
        onAccept: (data) {
          final draggableIdentifier = data.id ?? data.path ?? data.type.name;
          final tabIdenfitier =
              widget.tab.id ?? widget.tab.path ?? widget.tab.type.name;

          if (draggableIdentifier == tabIdenfitier) return;
          projectProvider.swapTabsOrder(widget.index, data);
          projectProvider.switchTab(widget.index);
        },
      ),
    );
  }
}
