import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:provider/provider.dart';

import '../models/file_tab.dart';
import '../providers/project_state.dart';
import 'tab.dart';

class WrtTabs extends StatefulWidget {
  const WrtTabs({super.key});

  @override
  State<WrtTabs> createState() => _WrtTabsState();
}

class _WrtTabsState extends State<WrtTabs> {
  final _tabScrollController = ScrollController();

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

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
          itemCount: project.openedTabs.length + 1,
          itemBuilder: (context, index) {
            if (index == project.openedTabs.length) {
              return DragTarget<FileTab>(
                builder: (context, candidate, declined) {
                  if (candidate.isNotEmpty) {
                    return Container(
                      width: 180.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF1638E2),
                          width: 3.0,
                        ),
                      ),
                    );
                  }
                  return const SizedBox(
                    width: 180.0,
                    height: 35.0,
                  );
                },
                onWillAccept: (data) {
                  return data != null;
                },
                onAccept: (data) {
                  if (data.type == FileType.characterEditor) {
                    if (data.id == null) return;
                    project.openCharacter(data.id!);
                  } else if (data.type == FileType.threadEditor) {
                    if (data.id == null) return;
                    project.openThread(data.id!);
                  } else if (data.type == FileType.editor) {
                    if (data.id == null) return;
                    project.openChapterEditor(data.id!);
                  } else {
                    project.openTab(data);
                  }
                },
              );
            }
            final tab = project.openedTabs[index];
            return TabTile(index: index, tab: tab);
          },
        ),
      ),
    );
  }
}
