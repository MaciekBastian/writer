import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../contexts/file_context_menu.dart';
import '../../helpers/general_helper.dart';
import '../../models/chapters/chapter.dart';
import '../../models/file_tab.dart';
import '../../models/settings_enums.dart';
import '../../providers/project_state.dart';
import '../tooltip.dart';

class SidebarFiles extends StatefulWidget {
  const SidebarFiles({super.key});

  @override
  State<SidebarFiles> createState() => _SidebarFilesState();
}

class _SidebarFilesState extends State<SidebarFiles> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    List<FileTab> fileTabs = provider.getAllFiles();
    final filesOrder = provider.filesOrder;

    if (filesOrder != FilesOrder.defaultOrder) {
      if (filesOrder == FilesOrder.alphabetic) {
        fileTabs.sort(
          (a, b) {
            final aName = GeneralHelper().getFileName(a.type, a.path).tr();
            final bName = GeneralHelper().getFileName(b.type, b.path).tr();
            return aName.compareTo(bName);
          },
        );
      } else if (filesOrder == FilesOrder.custom) {
        fileTabs = provider.getCustomOrder();
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 4.0,
              ),
              child: Text(
                provider.project!.name.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.left,
              ),
            ),
            if (!provider.initialized)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                minHeight: 4.0,
                color: Color(0xFF1638E2),
              ),
          ],
        ),
        Expanded(
          child: ListView(
            children: List.generate(
              fileTabs.length,
              (index) {
                final tab = fileTabs[index];

                return _ButtonTile(tab: tab);
              },
            ),
          ),
        )
      ],
    );
  }
}

class _ButtonTile extends StatefulWidget {
  const _ButtonTile({
    required this.tab,
  });

  final FileTab tab;

  @override
  State<_ButtonTile> createState() => __ButtonTileState();
}

class __ButtonTileState extends State<_ButtonTile> {
  bool _hovered = false;

  Container _buildButton(FileTab tab, [String? label]) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final selected = provider.selectedTab;
    final theme = Theme.of(context);
    final isSelected = (tab.type != FileType.characterEditor &&
                    tab.type != FileType.threadEditor &&
                    tab.type != FileType.editor) &&
                (tab.type == selected?.type) ||
            tab.path != null
        ? tab.path == selected?.path
        : ((tab.id == selected?.id) && tab.id != null);

    final containsErrors =
        provider.highlightErrors ? provider.fileContainsErrors(tab) : false;

    return Container(
      color: isSelected ? Colors.grey[800] : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: ContextMenuRegion(
          contextMenu: tab.type == FileType.characterEditor && tab.id != null
              ? CharacterFileContextMenu(
                  id: tab.id!,
                )
              : tab.type == FileType.threadEditor && tab.id != null
                  ? ThreadFileContextMenu(
                      id: tab.id!,
                    )
                  : const GenericContextMenu(buttonConfigs: []),
          child: InkWell(
            onTap: () {
              if (tab.id != null) {
                if (provider.selectedTab?.id == tab.id) return;
                if (tab.type == FileType.characterEditor) {
                  provider.openCharacter(tab.id!);
                } else if (tab.type == FileType.threadEditor) {
                  provider.openThread(tab.id!);
                } else if (tab.type == FileType.editor) {
                  provider.openChapterEditor(tab.id!);
                }
              } else {
                _onTabSelected(tab);
              }
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.grey[800],
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 20.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        GeneralHelper().getTypeIcon(tab.type, tab.path).icon,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      const SizedBox(width: 10.0),
                      Flexible(
                        child: Text(
                          label ??
                              GeneralHelper()
                                  .getFileName(
                                    tab.type,
                                    tab.path,
                                  )
                                  .tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: containsErrors ? Colors.red : null,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (containsErrors && tab.id != null)
                  const Positioned(
                    right: 10.0,
                    top: 5.0,
                    child: Icon(
                      Icons.error_outline,
                      size: 20.0,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTabSelected(FileTab tab) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final unclickable = [
      FileType.threadEditor,
      FileType.characterEditor,
      FileType.editor,
    ];
    if (unclickable.contains(tab.type)) return;
    provider.openTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);

    final containsErrors = provider.highlightErrors
        ? provider.fileContainsErrors(widget.tab)
        : false;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.centerRight,
            children: [
              _buildButton(widget.tab),
              Positioned(
                top: 5,
                right: widget.tab.type == FileType.characterEditor ||
                        widget.tab.type == FileType.threadEditor ||
                        widget.tab.type == FileType.editor
                    ? _hovered
                        ? 35
                        : 10
                    : 10,
                child: containsErrors
                    ? const Icon(
                        Icons.error_outline,
                        size: 20.0,
                        color: Colors.red,
                      )
                    : Container(),
              ),
              if (_hovered)
                if (widget.tab.type == FileType.characterEditor)
                  SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: WrtTooltip(
                      key: const Key('new_character_sidebar_button'),
                      content: 'taskbar.create_character'.tr(),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (widget.tab.type == FileType.characterEditor) {
                              provider.addCharacter();
                            }
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: const Icon(
                            Icons.person_add_alt_outlined,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (widget.tab.type == FileType.threadEditor)
                  SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: WrtTooltip(
                      key: const Key('new_thread_sidebar_button'),
                      content: 'taskbar.create_thread'.tr(),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            provider.addThread();
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: const Icon(
                            Icons.post_add_rounded,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (widget.tab.type == FileType.editor)
                  SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: WrtTooltip(
                      key: const Key('new_chapter_sidebar_button'),
                      content: 'taskbar.add_chapter'.tr(),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final chapters = provider.chapters.length;
                            provider.createChapterAndOpenEditor(
                              Chapter(
                                id: GeneralHelper().id(),
                                name:
                                    '${'timeline.chapter'.tr()} ${chapters + 1}.',
                                index: chapters,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: const Icon(
                            Icons.add_box_outlined,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  )
            ],
          ),
          if (widget.tab.type == FileType.characterEditor)
            ...provider.characters.entries.map((e) {
              final isSelected = provider.selectedTab?.id == e.key;
              return Container(
                color: isSelected ? Colors.grey[800] : Colors.transparent,
                padding: const EdgeInsets.only(left: 25.0),
                child: _buildButton(
                  FileTab(type: widget.tab.type, id: e.key, path: null),
                  e.value,
                ),
              );
            }).toList(),
          if (widget.tab.type == FileType.threadEditor)
            ...provider.threads.entries.map((e) {
              final isSelected = provider.selectedTab?.id == e.key;
              return Container(
                color: isSelected ? Colors.grey[800] : Colors.transparent,
                padding: const EdgeInsets.only(left: 25.0),
                child: _buildButton(
                  FileTab(type: widget.tab.type, id: e.key, path: null),
                  e.value,
                ),
              );
            }).toList(),
          if (widget.tab.type == FileType.editor)
            ...provider.chapters.map(
              (e) {
                final isSelected = provider.selectedTab?.id == e.id;
                return Container(
                  color: isSelected ? Colors.grey[800] : Colors.transparent,
                  padding: const EdgeInsets.only(left: 25.0),
                  child: _buildButton(
                    FileTab(type: widget.tab.type, id: e.id, path: null),
                    e.name.isNotEmpty
                        ? e.name
                        : '${'character.chapter'.tr()}: ${e.index + 1}',
                  ),
                );
              },
            ).toList(),
        ],
      ),
    );
  }
}
