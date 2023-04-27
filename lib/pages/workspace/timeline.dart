import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:provider/provider.dart';

import '../../helpers/general_helper.dart';
import '../../models/chapters/chapter.dart';
import '../../providers/project_state.dart';
import '../../widgets/plot_editor/chapter_tile.dart';

class TimelineEditor extends StatefulWidget {
  const TimelineEditor({super.key});

  @override
  State<TimelineEditor> createState() => _TimelineEditorState();
}

class _TimelineEditorState extends State<TimelineEditor> {
  final _horizontalController = ScrollController();

  final List<String> _foldedChapters = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = Provider.of<ProjectState>(context);
    final chapters = project.chapters;

    return ImprovedScrolling(
      scrollController: _horizontalController,
      enableKeyboardScrolling: true,
      enableCustomMouseWheelScrolling: true,
      child: Scrollbar(
        controller: _horizontalController,
        scrollbarOrientation: ScrollbarOrientation.bottom,
        interactive: true,
        thumbVisibility: true,
        trackVisibility: true,
        radius: const Radius.circular(2.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          restorationId: 'timeline_tab_horizontal',
          controller: _horizontalController,
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            restorationId: 'timeline_tab_vertical',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                chapters.length + 1,
                (index) {
                  if (index == chapters.length) {
                    return _newChapterTile();
                  }
                  final chapter = chapters[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chapter.startsNewPart || index == 0)
                        Container(
                          width: 14.0,
                          height: 195.0,
                          color: Colors.white30,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                if (_foldedChapters.contains(chapter.id)) {
                                  final nextPartStart =
                                      chapters.where((element) {
                                    return element.startsNewPart &&
                                        element.index > chapter.index;
                                  }).toList();
                                  _foldedChapters.removeWhere((element) {
                                    final chData = chapters.firstWhere((el) {
                                      return el.id == element;
                                    });
                                    return chData.index >= chapter.index &&
                                        chData.index <
                                            (nextPartStart.isEmpty
                                                ? chapters.length
                                                : nextPartStart.first.index);
                                  });
                                } else {
                                  final nextPartStart =
                                      chapters.where((element) {
                                    return element.startsNewPart &&
                                        element.index > chapter.index;
                                  }).toList();

                                  _foldedChapters.addAll(
                                    chapters
                                        .getRange(
                                          chapter.index,
                                          nextPartStart.isEmpty
                                              ? chapters.length
                                              : nextPartStart.first.index,
                                        )
                                        .toList()
                                        .map((e) {
                                      return e.id;
                                    }),
                                  );
                                }
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    _foldedChapters.contains(chapter.id)
                                        ? 'timeline.expand_this_part'.tr()
                                        : 'timeline.fold_this_part'.tr(),
                                    style: theme.textTheme.labelSmall,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!_foldedChapters.contains(chapter.id))
                        ChapterTileEditor(
                          chapter: chapter,
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _newChapterTile() {
    final theme = Theme.of(context);
    final project = Provider.of<ProjectState>(context);
    final provider = Provider.of<ProjectState>(context, listen: false);

    final chapters = project.chapters;

    return Column(
      children: [
        Container(
          width: 350.0,
          height: 170.0,
          key: const Key('add_new_chapter_tile'),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 350.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey[900]!,
                width: 2.0,
              ),
              color: Colors.grey[800],
            ),
            margin: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  provider.addChapter(
                    Chapter(
                      id: GeneralHelper().id(),
                      name:
                          '${'timeline.chapter'.tr()} ${chapters.length + 1}.',
                      index: chapters.length,
                    ),
                  );
                },
                onDoubleTap: () {
                  provider.addChapter(
                    Chapter(
                      id: GeneralHelper().id(),
                      name:
                          '${'timeline.chapter'.tr()} ${chapters.length + 1}.',
                      index: chapters.length,
                      startsNewPart: true,
                    ),
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 15.0,
                  ),
                  child: Text(
                    'timeline.add_chapter'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Container(
          height: 20.0,
          width: 350.0,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(10, (index) {
              return Container(
                width: 15.0,
                height: 20.0,
                color: const Color(0xFF303030),
              );
            }),
          ),
        ),
      ],
    );
  }
}
