import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dropdown_select.dart';
import 'sidebar/project_search.dart';

import '../helpers/general_helper.dart';
import '../models/sidebar_tab.dart';
import '../models/settings_enums.dart';
import '../providers/project_state.dart';
import 'checkbox.dart';
import 'sidebar/project_tab.dart';
import 'sidebar/resources_tab.dart';
import 'sidebar/version_control_tab.dart';
import 'tooltip.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  double _width = 350.0;
  bool _hovering = false;
  bool _hidden = false;
  bool _dragging = false;

  Widget _buildTab(SidebarTab tab) {
    switch (tab) {
      case SidebarTab.project:
        return _buildProjectTab();
      case SidebarTab.projectSearch:
        return _buildSearchTab();
      case SidebarTab.resources:
        return _buildResourcesTab();
      case SidebarTab.layoutSettings:
        return _buildLayoutSettingsTab();
      case SidebarTab.versionControl:
        return _buildVersionControlTab();
    }
  }

  Widget _buildVersionControlTab() {
    return const VersionControlTab();
  }

  Widget _buildProjectTab() {
    return SidebarProjectTab(
      width: _width,
    );
  }

  Widget _buildSearchTab() {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

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
                  'taskbar.project_search'.tr().toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (provider.isProjectOpened)
          const Expanded(
            child: ProjectSearchTab(),
          ),
      ],
    );
  }

  Widget _buildResourcesTab() {
    return const ResourcesTab();
  }

  Widget _buildLayoutSettingsTab() {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

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
                  'taskbar.layout_settings'.tr().toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (provider.isProjectOpened)
          Expanded(
            child: ListView(
              children: [
                WrtCheckbox(
                  label: 'preferences.layout.tooltips'.tr(),
                  value: provider.tooltips,
                  callback: () {
                    provider.toggleTooltips();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.error_pannel'.tr(),
                  value: provider.isErrorPanelOpened,
                  callback: () {
                    provider.switchErrorPanel();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.highlight_errors'.tr(),
                  value: provider.highlightErrors,
                  callback: () {
                    provider.toggleHighlighErrors();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.allow_multiwindow'.tr(),
                  value: provider.allowMultiwindow,
                  callback: () {
                    provider.toggleMultiwindow();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.show_open_editors'.tr(),
                  value: provider.openEditors,
                  callback: () {
                    provider.toggleOpenEditors();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.command_palette_button'.tr(),
                  value: provider.commandPaletteButton,
                  callback: () {
                    provider.toggleComandPaletteButton();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.tab_switcher_auto_close'.tr(),
                  value: provider.ctrlTabAutoClose,
                  callback: () {
                    provider.toggleCtrlTabAutoClose();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.secondary_sidebar'.tr(),
                  value: provider.showRightSidebar,
                  callback: () {
                    provider.toggleShowRightSidebar();
                  },
                ),
                const SizedBox(height: 10.0),
                WrtCheckbox(
                  label: 'preferences.layout.small_screen_view'.tr(),
                  value: provider.smallScreenView,
                  callback: () {
                    provider.toggleSmallScreenView();
                  },
                ),
                // TODO: MACOS SPECIFIC
                if (Platform.isMacOS)
                  const Column(
                    children: [],
                  ),
                const SizedBox(height: 10.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  height: 50.0,
                  child: WrtDropdownSelect(
                    values: TabBarVisibility.values,
                    initiallySelected: provider.tabBarVisibility,
                    labels: {
                      TabBarVisibility.top:
                          'preferences.layout.tab_bar.top'.tr(),
                      TabBarVisibility.bottom:
                          'preferences.layout.tab_bar.bottom'.tr(),
                      TabBarVisibility.hidden:
                          'preferences.layout.tab_bar.hidden'.tr(),
                    },
                    onSelected: (value) {
                      provider.changeTabBarVisibility(value);
                    },
                    title: 'preferences.layout.tab_bar_position'.tr(),
                    smaller: true,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'preferences.layout.status_bar_elements'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 10.0,
                        ),
                        child: Column(
                          children: [
                            WrtCheckbox(
                              label: 'preferences.layout.status_bar.save_button'
                                  .tr(),
                              value: provider.statusBarSave,
                              callback: () {
                                provider.toggleStatusBar(0);
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.status_bar.errors'.tr(),
                              value: provider.statusBarErrors,
                              callback: () {
                                provider.toggleStatusBar(1);
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label: 'preferences.layout.status_bar.word_count'
                                  .tr(),
                              value: provider.statusBarWordCount,
                              callback: () {
                                provider.toggleStatusBar(2);
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.status_bar.current_version'
                                      .tr(),
                              value: provider.statusBarVersion,
                              callback: () {
                                provider.toggleStatusBar(3);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'preferences.layout.project_tab_elements'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 10.0,
                        ),
                        child: Column(
                          children: [
                            WrtCheckbox(
                              label: 'preferences.layout.project_tab.chapters'
                                  .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.chapters,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.chapters,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.project_tab.general'.tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.general,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.general,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label: 'preferences.layout.project_tab.timeline'
                                  .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.timeline,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.timeline,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.project_tab.plot_development'
                                      .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.plotDevelopment,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.plotDevelopment,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.project_tab.threads'.tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.threads,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.threads,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label: 'preferences.layout.project_tab.characters'
                                  .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.characters,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.characters,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label: 'preferences.layout.project_tab.calendar'
                                  .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.calendar,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.calendar,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label: 'preferences.layout.project_tab.dictionary'
                                  .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.dictionary,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.dictionary,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.project_tab.characters_report'
                                      .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.charactersReport,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.charactersReport,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                            WrtCheckbox(
                              label:
                                  'preferences.layout.project_tab.file_explorer'
                                      .tr(),
                              value: provider.visibilityForProjectTabFile(
                                SidebarProjectTabElement.fileExplorer,
                              ),
                              callback: () {
                                provider.toggleVisibilityForProjectTabFile(
                                  SidebarProjectTabElement.fileExplorer,
                                );
                              },
                            ),
                            const SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  height: 50.0,
                  child: WrtDropdownSelect(
                    values: FilesOrder.values,
                    initiallySelected: provider.filesOrder,
                    labels: {
                      FilesOrder.defaultOrder:
                          'preferences.layout.elements_order.default'.tr(),
                      FilesOrder.alphabetic:
                          'preferences.layout.elements_order.alphabetic'.tr(),
                      FilesOrder.custom:
                          'preferences.layout.elements_order.custom'.tr(),
                    },
                    onSelected: (value) {
                      provider.changeFilesOrderMode(value);
                    },
                    title: 'preferences.layout.project_tab_elements_order'.tr(),
                    smaller: true,
                  ),
                ),
                const SizedBox(height: 10.0),
                if (provider.filesOrder == FilesOrder.custom)
                  Builder(builder: (context) {
                    final allFiles = provider.getCustomOrder();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'preferences.layout.change_order'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Container(
                            height: allFiles.length * 30.0 + 10.0,
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              top: 10.0,
                            ),
                            child: ReorderableListView(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(0.0),
                              onReorder: (oldIndex, updatedIndex) {
                                // TODO: reorder
                                final files = allFiles;
                                final newIndex = updatedIndex > oldIndex
                                    ? updatedIndex - 1
                                    : updatedIndex;
                                final element = files.removeAt(oldIndex);
                                files.insert(newIndex, element);

                                provider.changeFilesOrder(files);
                              },
                              children: allFiles.map((e) {
                                return SizedBox(
                                  key: Key(e.path ?? e.type.name),
                                  height: 30.0,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 20.0),
                                      Icon(
                                        GeneralHelper()
                                            .getTypeIcon(e.type, e.path)
                                            .icon,
                                        color: Colors.white,
                                        size: 15.0,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        GeneralHelper()
                                            .getFileName(
                                              e.type,
                                              e.path,
                                            )
                                            .tr(),
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 50.0),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final projectState = Provider.of<ProjectState>(context);
    final currentTab = projectState.currentSidebarTab;

    return Row(
      children: [
        Container(
          width: 60.0,
          color: const Color(0xFF363636),
          child: Column(
            children: SidebarTab.values.map((e) {
              return _SidebarButton(
                toggleHidden: () {
                  setState(() {
                    _hidden = !_hidden;
                  });
                },
                callback: (tab) {
                  provider.switchSidebarTab(tab);
                  if (_hidden) {
                    setState(() {
                      _width = 350.0;
                      _hidden = false;
                    });
                  }
                },
                currentTab: currentTab,
                tab: e,
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: _hidden ? 10.0 : _width,
          child: Row(
            children: [
              if (!_hidden)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFF242424),
                    child: _buildTab(currentTab),
                  ),
                ),
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
                      _hidden = false;
                      _width = 350.0;
                    });
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
                    setState(() {
                      if (details.delta.direction >= 0 &&
                          details.delta.direction <= (math.pi / 2)) {
                        if (_hidden) {
                          _hidden = false;
                        } else if (_width <= 450.0) {
                          _width = _width + details.delta.distance;
                        }
                      } else {
                        if (_width >= 250.0) {
                          _width = _width - details.delta.distance;
                        } else {
                          if (details.globalPosition.dx <= 150.0) {
                            _hidden = true;
                          }
                        }
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 8.0,
                    color: _hovering || _dragging
                        ? Colors.grey[800]
                        : _hidden
                            ? const Color(0xFF363636)
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
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarButton extends StatefulWidget {
  const _SidebarButton({
    required this.tab,
    required this.currentTab,
    required this.callback,
    required this.toggleHidden,
  });

  final SidebarTab tab;
  final SidebarTab currentTab;
  final void Function(SidebarTab tab) callback;
  final void Function() toggleHidden;

  @override
  State<_SidebarButton> createState() => __SidebarButtonState();
}

class __SidebarButtonState extends State<_SidebarButton> {
  bool _hovering = false;

  Icon _getTabIcon(SidebarTab tab) {
    switch (tab) {
      case SidebarTab.project:
        return const Icon(Icons.folder_outlined);
      case SidebarTab.projectSearch:
        return const Icon(Icons.search);
      case SidebarTab.resources:
        return const Icon(Icons.library_books_outlined);
      case SidebarTab.layoutSettings:
        return const Icon(Icons.settings_outlined);
      case SidebarTab.versionControl:
        return const Icon(Icons.mediation);
    }
  }

  String _getTabName() {
    switch (widget.tab) {
      case SidebarTab.project:
        return 'taskbar.project'.tr();
      case SidebarTab.projectSearch:
        return 'taskbar.project_search'.tr();
      case SidebarTab.resources:
        return 'taskbar.resources'.tr();
      case SidebarTab.layoutSettings:
        return 'taskbar.layout_settings'.tr();
      case SidebarTab.versionControl:
        return 'taskbar.version_control'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: WrtTooltip(
        key: Key(widget.tab.name),
        content: _getTabName(),
        onMouseEvent: (hovering) {
          setState(() {
            _hovering = hovering;
          });
        },
        child: InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            widget.callback(widget.tab);
          },
          onDoubleTap: widget.toggleHidden,
          child: Row(
            children: [
              Container(
                width: 3.0,
                height: 60.0,
                color: widget.currentTab == widget.tab
                    ? Colors.white
                    : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 10.0,
                  ),
                  child: Icon(
                    _getTabIcon(widget.tab).icon,
                    color: _hovering || widget.currentTab == widget.tab
                        ? Colors.white
                        : Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
