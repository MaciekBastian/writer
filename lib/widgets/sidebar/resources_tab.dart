import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/system_pages.dart';
import '../../models/file_tab.dart';
import '../../providers/project_state.dart';

class ResourcesTab extends StatelessWidget {
  const ResourcesTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'taskbar.resources'.tr().toUpperCase(),
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
            child: Column(
              children: [
                _eduTab(context),
                _toolsTab(context),
                _visualizationsTab(context),
              ],
            ),
          ),
      ],
    );
  }

  Expanded _eduTab(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 15.0,
              bottom: 4.0,
            ),
            child: Text(
              'resources.edu'.tr(),
              style: theme.textTheme.labelLarge,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: resources.keys.length,
              itemBuilder: (context, index) {
                final e = resources.keys.toList()[index];
                final isSelected = provider.selectedTab?.path == e;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      provider.openTab(
                        FileTab(
                          id: null,
                          path: e,
                          type: FileType.system,
                        ),
                      );
                    },
                    child: Draggable<FileTab>(
                      data: FileTab(
                        id: null,
                        path: e,
                        type: FileType.system,
                      ),
                      feedback: Container(
                        height: 35.0,
                        width: 180.0,
                        color: const Color(0xFF121212),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 20.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              systemPagesIcons[e]?.icon ?? Icons.note_outlined,
                              size: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  (systemPagesNames[e] ??
                                          'system_pages.new_tab')
                                      .tr(),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        color:
                            isSelected ? Colors.grey[800] : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              systemPagesIcons[e]?.icon ?? Icons.note_outlined,
                              size: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              (systemPagesNames[e] ?? 'system_pages.new_tab')
                                  .tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Expanded _toolsTab(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20.0,
              bottom: 4.0,
            ),
            child: Text(
              'resources.tools'.tr(),
              style: theme.textTheme.labelLarge,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tools.keys.length,
              itemBuilder: (context, index) {
                final e = tools.keys.toList()[index];
                final isSelected = provider.selectedTab?.path == e;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      provider.openTab(
                        FileTab(
                          id: null,
                          path: e,
                          type: FileType.system,
                        ),
                      );
                    },
                    child: Draggable<FileTab>(
                      data: FileTab(
                        id: null,
                        path: e,
                        type: FileType.system,
                      ),
                      feedback: Container(
                        height: 35.0,
                        width: 180.0,
                        color: const Color(0xFF121212),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 20.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              systemPagesIcons[e]?.icon ?? Icons.note_outlined,
                              size: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  (systemPagesNames[e] ??
                                          'system_pages.new_tab')
                                      .tr(),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        color:
                            isSelected ? Colors.grey[800] : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              systemPagesIcons[e]?.icon ?? Icons.note_outlined,
                              size: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              (systemPagesNames[e] ?? 'system_pages.new_tab')
                                  .tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Expanded _visualizationsTab(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              left: 20.0,
              bottom: 4.0,
            ),
            child: Text(
              'resources.visualize'.tr(),
              style: theme.textTheme.labelLarge,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: visualizationsAndReports.keys.length,
              itemBuilder: (context, index) {
                final e = visualizationsAndReports.keys.toList()[index];
                final isSelected = provider.selectedTab?.path == e;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      provider.openTab(
                        FileTab(
                          id: null,
                          path: e,
                          type: FileType.system,
                        ),
                      );
                    },
                    child: Draggable<FileTab>(
                      data: FileTab(
                        id: null,
                        path: e,
                        type: FileType.system,
                      ),
                      feedback: Container(
                        height: 35.0,
                        width: 180.0,
                        color: const Color(0xFF121212),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 20.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              systemPagesIcons[e]?.icon ?? Icons.note_outlined,
                              size: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Flexible(
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  (systemPagesNames[e] ??
                                          'system_pages.new_tab')
                                      .tr(),
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: Container(
                        color:
                            isSelected ? Colors.grey[800] : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 15.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              systemPagesIcons[e]?.icon ?? Icons.note_outlined,
                              size: 20.0,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              (systemPagesNames[e] ?? 'system_pages.new_tab')
                                  .tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
