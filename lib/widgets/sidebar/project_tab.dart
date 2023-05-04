import 'package:context_menus/context_menus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/file_tab.dart';

import '../../contexts/tab_context_menu.dart';
import '../../helpers/general_helper.dart';
import '../../models/chapters/chapter.dart';
import '../../providers/project_state.dart';
import '../dropdown_menu.dart';
import '../saving_indicator.dart';
import 'sidebar_files.dart';
import '../tooltip.dart';

class SidebarProjectTab extends StatefulWidget {
  const SidebarProjectTab({super.key, required this.width});
  final double width;

  @override
  State<SidebarProjectTab> createState() => _SidebarProjectTabState();
}

class _SidebarProjectTabState extends State<SidebarProjectTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    final openEditors = provider.openedTabs;

    return Column(
      children: [
        SizedBox(
          height: 45.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'taskbar.project'.tr().toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Row(
                children: [
                  if (provider.containsUnsaved && widget.width > 300)
                    Container(
                      margin: const EdgeInsets.only(right: 10.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: const Color(0xFFFFC107),
                        border: Border.all(
                          color: const Color(0xFFFF8241),
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.only(right: 10.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'unsaved changes'.tr().toUpperCase(),
                            style: theme.textTheme.labelSmall,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  WtrMenuButton(
                    items: [
                      WrtMenuItem(
                        label: 'taskbar.create_character'.tr(),
                        callback: () {
                          if (provider.isProjectOpened) {
                            provider.addCharacter(
                              'character.new_character'.tr(),
                            );
                          }
                        },
                      ),
                      WrtMenuItem(
                        label: 'taskbar.create_thread'.tr(),
                        callback: () {
                          if (provider.isProjectOpened) {
                            provider.addThread('thread.new_thread'.tr());
                          }
                        },
                      ),
                      WrtMenuItem(
                        label: 'taskbar.add_chapter'.tr(),
                        callback: () {
                          if (provider.isProjectOpened) {
                            final chapters = provider.chapters.length;
                            provider.createChapterAndOpenEditor(
                              Chapter(
                                id: GeneralHelper().id(),
                                name:
                                    '${'timeline.chapter'.tr()} ${chapters + 1}.',
                                index: chapters,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (provider.isProjectOpened)
          const Expanded(
            child: SidebarFiles(),
          ),
        if (provider.openEditors)
          Container(
            constraints: const BoxConstraints(maxHeight: 250.0),
            height: 25.0 * openEditors.length + 30.0,
            child: Column(
              children: [
                Container(
                  height: 25.0,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    left: 20.0,
                  ),
                  margin: const EdgeInsets.only(bottom: 5.0),
                  decoration: const BoxDecoration(
                    color: Color(0xff242424),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        offset: Offset(0, 10.0),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'project.open_editors'.tr().toUpperCase(),
                        style: theme.textTheme.labelSmall,
                      ),
                      Row(
                        children: [
                          WrtTooltip(
                            content: 'project.save_all'.tr(),
                            key: const Key('save_all_button__open_editors'),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6.0),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  provider.saveAll();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.save,
                                    size: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          WrtTooltip(
                            content: 'project.close_all'.tr(),
                            key: const Key('close_all_button__open_editors'),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6.0),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  provider.saveAll();
                                  provider.closeAll();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.disabled_by_default_outlined,
                                    size: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: openEditors.map((e) {
                      return ContextMenuRegion(
                        contextMenu: TabContextMenu(tab: e),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              provider.switchTab(provider.indexOfTab(e));
                            },
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            child: Container(
                              color: provider.isSelected(provider.indexOfTab(e))
                                  ? Colors.grey[800]
                                  : Colors.transparent,
                              height: 25.0,
                              child: Row(
                                children: [
                                  const SizedBox(width: 20.0),
                                  Icon(
                                    GeneralHelper()
                                        .getTypeIcon(
                                          e.type,
                                          e.path,
                                        )
                                        .icon,
                                    size: 15.0,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Expanded(
                                    child: Text(
                                      e.type == FileType.characterEditor
                                          ? provider.characters[e.id!]!
                                          : e.type == FileType.threadEditor
                                              ? provider.threads[e.id!]!
                                              : e.type == FileType.editor
                                                  ? provider
                                                      .chaptersAsMap[e.id!]!
                                                  : GeneralHelper()
                                                      .getFileName(
                                                          e.type, e.path)
                                                      .tr(),
                                      style: theme.textTheme.labelMedium,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  if (provider.isTabPinned(e))
                                    Container(
                                      width: 20.0,
                                      alignment: Alignment.center,
                                      height: 20.0,
                                      margin: const EdgeInsets.only(
                                        right: 10.0,
                                      ),
                                      child: const Icon(
                                        Icons.push_pin_outlined,
                                        size: 20.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (provider.highlightErrors &&
                                      provider.fileContainsErrors(e))
                                    Container(
                                      width: 20.0,
                                      alignment: Alignment.center,
                                      height: 20.0,
                                      margin: const EdgeInsets.only(
                                        right: 10.0,
                                      ),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: Text(
                                        '${provider.errorsForFile(e).length}',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (provider.isTabBeingSaved(e))
                                    const SavingIndicator()
                                  else if (!provider
                                      .isSaved(provider.indexOfTab(e)))
                                    Container(
                                      width: 10.0,
                                      height: 10.0,
                                      margin: const EdgeInsets.only(
                                        right: 10.0,
                                      ),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
