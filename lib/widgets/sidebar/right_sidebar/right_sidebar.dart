import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/system_pages.dart';
import '../../../models/file_tab.dart';
import '../../../models/sidebar_tab.dart';
import '../../../pages/resources/user_file.dart';
import '../../../pages/tools/calendar.dart';
import '../../../pages/tools/dictionary.dart';
import '../../../pages/tools/spell_check.dart';
import '../../../pages/workspace/empty.dart';
import '../../../pages/workspace/plot_development.dart';
import '../../../providers/project_state.dart';
import '../../dropdown_menu.dart';
import '../../snippets/chapter_snippet.dart';
import '../../snippets/character_snippet.dart';
import '../../snippets/thread_snippet.dart';
import '../../tooltip.dart';

class RightSidebar extends StatefulWidget {
  const RightSidebar({super.key});

  @override
  State<RightSidebar> createState() => _RightSidebarState();
}

class _RightSidebarState extends State<RightSidebar> {
  double _width = 350.0;
  bool _hovering = false;
  bool _dragging = false;
  FileTab? _openedTab;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final provider = Provider.of<ProjectState>(context);
    final functions = Provider.of<ProjectState>(context, listen: false);

    return Row(
      children: [
        if (provider.rightSidebar)
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            onEnter: (_) {
              setState(() {
                _hovering = true;
              });
            },
            onExit: (_) {
              setState(() {
                _hovering = false;
              });
            },
            child: GestureDetector(
              onDoubleTap: () {
                setState(() {
                  _width = 350.0;
                });
                functions.toggleRightSidebar(true);
              },
              onHorizontalDragStart: (_) {
                setState(() {
                  _dragging = true;
                });
              },
              onHorizontalDragEnd: (_) {
                setState(() {
                  _dragging = false;
                });
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.direction <= 0 &&
                    details.delta.direction >= (-math.pi / 2)) {
                  _width -= details.delta.distance;
                  if (_width <= 350.0) {
                    setState(() {
                      _width = 350.0;
                      _dragging = false;
                      _hovering = false;
                    });
                  } else {
                    setState(() {
                      _dragging = false;
                      _hovering = false;
                    });
                  }
                  if ((screenSize.width - details.globalPosition.dx) <= 150.0) {
                    provider.toggleRightSidebar(false);
                  }
                } else {
                  _width += details.delta.distance;
                  if (_width >= 400.0) {
                    setState(() {
                      _width = 400.0;
                      _dragging = false;
                      _hovering = false;
                    });
                  } else {
                    setState(() {
                      _dragging = false;
                      _hovering = false;
                    });
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 8.0,
                color: _hovering || _dragging
                    ? Colors.grey[800]
                    : const Color(0xFF242424),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3.0,
                    vertical: 2.0,
                  ),
                  color: _hovering || _dragging
                      ? Colors.black
                      : Colors.transparent,
                ),
              ),
            ),
          ),
        if (provider.rightSidebar)
          Container(
            width: _width,
            height: double.infinity,
            color: const Color(0xFF303030),
            child: _buildTab(provider.rightSidebarTab),
          ),
        // tabs
        Container(
          color: const Color(0xFF242424),
          height: double.infinity,
          width: 25.0,
          child: ListView(
            children: [
              _RightSidebarTab(
                key: const Key('snippets_tab_button'),
                name: 'right_sidebar.snippets'.tr(),
                icon: const Icon(Icons.text_snippet_outlined),
                tab: RightSidebarTab.snippets,
              ),
              _RightSidebarTab(
                key: const Key('dictionary_tab_button'),
                name: 'right_sidebar.dictionary'.tr(),
                icon: const Icon(Icons.text_fields),
                tab: RightSidebarTab.dictionary,
              ),
              _RightSidebarTab(
                key: const Key('calendar_tab_button'),
                name: 'right_sidebar.calendar'.tr(),
                icon: const Icon(Icons.calendar_month_outlined),
                tab: RightSidebarTab.calendar,
              ),
              _RightSidebarTab(
                key: const Key('spell_check_tab_button'),
                name: 'right_sidebar.spell_check'.tr(),
                icon: const Icon(Icons.spellcheck),
                tab: RightSidebarTab.spellCheck,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(RightSidebarTab tab) {
    switch (tab) {
      case RightSidebarTab.snippets:
        final provider = Provider.of<ProjectState>(context);

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (_openedTab != null)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildWorkspace(_openedTab),
              )
            else
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _buildWorkspace(null),
              ),
            Container(
              height: 30.0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      WrtTooltip(
                        key: const Key('pick_character_button_right_sidebar'),
                        content: 'right_sidebar.pick_character'.tr(),
                        showOnTheLeft: true,
                        child: WtrMenuButton(
                          items: provider.characters
                              .map((key, value) {
                                return MapEntry(
                                  key,
                                  WrtMenuItem(
                                    label: value,
                                    callback: () {
                                      setState(() {
                                        _openedTab = FileTab(
                                          id: key,
                                          path: null,
                                          type: FileType.characterEditor,
                                        );
                                      });
                                    },
                                  ),
                                );
                              })
                              .values
                              .toList(),
                          icon: const Icon(
                            Icons.person_outlined,
                            size: 20.0,
                          ),
                          autoDecideIfShowOnLeft: true,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      WrtTooltip(
                        key: const Key('pick_thread_button_right_sidebar'),
                        content: 'right_sidebar.pick_thread'.tr(),
                        showOnTheLeft: true,
                        child: WtrMenuButton(
                          items: provider.threads
                              .map((key, value) {
                                return MapEntry(
                                  key,
                                  WrtMenuItem(
                                    label: value,
                                    callback: () {
                                      setState(() {
                                        _openedTab = FileTab(
                                          id: key,
                                          path: null,
                                          type: FileType.threadEditor,
                                        );
                                      });
                                    },
                                  ),
                                );
                              })
                              .values
                              .toList(),
                          icon: const Icon(
                            Icons.upcoming_outlined,
                            size: 20.0,
                          ),
                          autoDecideIfShowOnLeft: true,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      WrtTooltip(
                        key: const Key('pick_chapter_button_right_sidebar'),
                        content: 'right_sidebar.pick_chapter'.tr(),
                        showOnTheLeft: true,
                        child: WtrMenuButton(
                          items: provider.chaptersAsMap
                              .map((key, value) {
                                return MapEntry(
                                  key,
                                  WrtMenuItem(
                                    label: value,
                                    callback: () {
                                      setState(() {
                                        _openedTab = FileTab(
                                          id: key,
                                          path: null,
                                          type: FileType.editor,
                                        );
                                      });
                                    },
                                  ),
                                );
                              })
                              .values
                              .toList(),
                          icon: const Icon(
                            Icons.history_edu,
                            size: 20.0,
                          ),
                          autoDecideIfShowOnLeft: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_openedTab != null) {
                              if (_openedTab!.type == FileType.editor) {
                                if (_openedTab?.id == null) return;
                                provider.openChapterEditor(_openedTab!.id!);
                              } else if (_openedTab!.type ==
                                  FileType.characterEditor) {
                                if (_openedTab?.id == null) return;
                                provider.openCharacter(_openedTab!.id!);
                              } else if (_openedTab!.type ==
                                  FileType.threadEditor) {
                                if (_openedTab?.id == null) return;
                                provider.openThread(_openedTab!.id!);
                              }
                              provider.openTab(_openedTab!);
                            }
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.open_in_new,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _openedTab = null;
                            });
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.close,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      case RightSidebarTab.dictionary:
        return const DictionaryPage(compact: true);
      case RightSidebarTab.calendar:
        return const CalendarPage(compact: true);
      case RightSidebarTab.spellCheck:
        return const SpellCheckPage();
    }
  }

  Widget _buildWorkspace(FileTab? tab) {
    final fileType = tab?.type;
    final path = tab?.path;
    final id = tab?.id;
    final provider = Provider.of<ProjectState>(context);

    final empty = Center(
      child: Icon(
        Icons.text_snippet_outlined,
        color: Colors.grey[900],
        size: 180.0,
      ),
    );

    switch (fileType) {
      case FileType.general:
        return empty;
      case FileType.timelineEditor:
        return empty;
      case FileType.threadEditor:
        if (id == null) return empty;
        if (provider.threads[id] == null) return empty;
        return ThreadSnippet(threadId: id);
      case FileType.characterEditor:
        if (id == null) return empty;
        if (provider.characters[id] == null) return empty;
        return CharacterSnippet(characterId: id);
      case FileType.plotDevelopment:
        return const PlotDevelopment();
      case FileType.editor:
        if (id == null) return empty;
        if (provider.chaptersAsMap[id] == null) return empty;
        return ChapterSnippet(chapterId: id);
      case FileType.system:
        break;
      case null:
        return empty;
      case FileType.userFile:
        return const UserFilePage();
    }

    return systemPages[path] ?? empty;
  }
}

class _RightSidebarTab extends StatelessWidget {
  const _RightSidebarTab({
    super.key,
    required this.tab,
    required this.icon,
    required this.name,
  });

  final RightSidebarTab tab;
  final Icon icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final functions = Provider.of<ProjectState>(context, listen: false);
    final provider = Provider.of<ProjectState>(context);

    return RotatedBox(
      quarterTurns: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (provider.rightSidebarTab == tab) {
              functions.toggleRightSidebar();
            } else {
              functions.toggleRightSidebar(true);
            }
            functions.switchRightSidebarTab(
              tab,
            );
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: 6.0,
            ),
            color: provider.rightSidebar
                ? provider.rightSidebarTab == tab
                    ? Colors.black26
                    : Colors.transparent
                : Colors.transparent,
            child: Row(
              children: [
                Icon(
                  icon.icon,
                  color: Colors.grey,
                  size: 20.0,
                ),
                const SizedBox(width: 4.0),
                Text(
                  name.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
