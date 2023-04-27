import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

import '../../constants/colors.dart';
import '../../helpers/general_helper.dart';
import '../../models/chapters/chapter.dart';
import '../../models/chapters/scene.dart';
import '../../pages/tools/confirm_delete_dialog.dart';
import '../../providers/project_state.dart';
import '../checkbox.dart';
import '../hover_box.dart';
import '../snippets/thread_snippet.dart';
import '../text_field.dart';
import '../tooltip.dart';
import 'add_thread_tile.dart';

class ChapterTileEditor extends StatefulWidget {
  const ChapterTileEditor({super.key, required this.chapter});

  final Chapter chapter;

  @override
  State<ChapterTileEditor> createState() => _ChapterTileEditorState();
}

class _ChapterTileEditorState extends State<ChapterTileEditor> {
  OverlayEntry? _overlayEntry;
  final _globalFocus = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _globalFocus.addListener(() {
      if (_globalFocus.hasFocus && !_hasFocus) {
        _overlayEntry = _getOverlay();
        Overlay.of(context).insert(_overlayEntry!);
        setState(() {
          _hasFocus = true;
        });
      } else if (!_globalFocus.hasFocus && _hasFocus) {
        setState(() {
          _hasFocus = false;
          _overlayEntry?.remove();
        });
      }
    });
  }

  OverlayEntry _getOverlay() {
    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Positioned(
          top: 90.0,
          right: 8.0,
          height: 35.0,
          child: Container(
            height: 35.0,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2.0),
              borderRadius: BorderRadius.circular(6.0),
              color: const Color(0xFF242424),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10.0,
                  offset: Offset(-5.0, 3.0),
                  spreadRadius: 2.0,
                )
              ],
            ),
            child: Text(
              'timeline.you_are_editing'.tr(
                args: [widget.chapter.name],
              ),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _overlayEntry?.remove();
  }

  void _updateScene(Scene scene) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final scenes = [...widget.chapter.scenes];
    final index = scenes.indexWhere((element) => element.id == scene.id);
    scenes.removeAt(index);
    scenes.insert(index, scene);
    provider.updateChapter(
      widget.chapter.copyWith(scenes: scenes),
    );
  }

  Map<String, Color> _assignColors(List<String> threads) {
    Map<String, Color> result = {};
    for (int i = 0; i < threads.length; i++) {
      var threadId = threads[i];
      int index = i >= wrtColors.length ? i - wrtColors.length : i;
      index = i >= wrtColors.length ? wrtColors.length - 1 : i;
      result[threadId] = wrtColors[index];
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    final colors = _assignColors(provider.chapters.map((e) => e.id).toList());

    return Focus(
      focusNode: _globalFocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 370.0,
            height: 65.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(width: 10.0),
                Expanded(
                  child: SizedBox(
                    height: 55.0,
                    child: WrtTextField(
                      initialValue: widget.chapter.name,
                      onEdit: (val) {
                        provider.updateChapter(widget.chapter.copyWith(
                          name: val,
                        ));
                      },
                      altText: 'timeline.unset'.tr(),
                      title: 'timeline.chapter_name'.tr(),
                      maxLines: 1,
                      minLines: 1,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final wantToDelete = await showDialog<bool?>(
                        context: context,
                        builder: (context) => const ConfirmDeleteDialog(),
                      );

                      if (wantToDelete == true) {
                        provider.deleteChapter(widget.chapter.id);
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: const SizedBox(
                      width: 30.0,
                      height: 30.0,
                      child: Icon(
                        Icons.delete_outline,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: 370.0,
            height: 35.0,
            child: WrtCheckbox(
              callback: () {
                if (widget.chapter.index != 0) {
                  provider.updateChapter(
                    widget.chapter.copyWith(
                      startsNewPart: !widget.chapter.startsNewPart,
                    ),
                  );
                }
              },
              value: widget.chapter.index == 0
                  ? true
                  : widget.chapter.startsNewPart,
              label: 'timeline.starts_new_part'.tr(),
            ),
          ),
          SizedBox(
            height: 450.0,
            child: FixedTimeline.tileBuilder(
              theme: TimelineThemeData.horizontal().copyWith(
                nodeItemOverlap: true,
              ),
              builder: TimelineTileBuilder(
                nodePositionBuilder: (context, index) => 0.15,
                indicatorBuilder: (context, index) {
                  return Container(
                    width: 30.0,
                    height: 30.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == widget.chapter.scenes.length
                          ? Colors.grey
                          : colors.values.toList()[widget.chapter.index],
                      border: Border.all(
                        width: 4.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                itemCount: widget.chapter.scenes.length + 1,
                oppositeContentsBuilder: (context, index) {
                  if (widget.chapter.scenes.length == index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      width: 350.0,
                      height: 55.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF242424).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: const Color(0xFF5D5D5D),
                          width: 2.0,
                        ),
                      ),
                    );
                  }
                  final scene = widget.chapter.scenes[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    width: 350.0,
                    height: 55.0,
                    child: WrtTextField(
                      initialValue: scene.name,
                      onEdit: (val) {
                        _updateScene(
                          scene.copyWith(name: val),
                        );
                      },
                      altText: 'timeline.unset'.tr(),
                      title: 'timeline.scene_name'.tr(),
                      maxLines: 3,
                    ),
                  );
                },
                contentsBuilder: (context, index) {
                  if (widget.chapter.scenes.length == index) {
                    return Container(
                      width: 350.0,
                      height: 80.0,
                      margin: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 2.0,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            provider.updateChapter(
                              widget.chapter.copyWith(
                                scenes: [
                                  ...widget.chapter.scenes,
                                  Scene(
                                    id: GeneralHelper().id(),
                                    index: index,
                                  ),
                                ],
                              ),
                            );
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Center(
                            child: Text(
                              'timeline.add_scene'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  final scene = widget.chapter.scenes[index];
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          width: 350.0,
                          child: WrtTextField(
                            initialValue: scene.description,
                            onEdit: (val) {
                              _updateScene(
                                scene.copyWith(description: val),
                              );
                            },
                            altText: 'timeline.unset'.tr(),
                            title: 'timeline.description'.tr(),
                            maxLines: 3,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 65.0,
                        width: 350.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            WrtTooltip(
                              key: Key('${scene.id}_ctn_last_thread'),
                              content: 'timeline.continue_last_thread'.tr(),
                              showOnTheBottom: true,
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[900],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(180.0),
                                    onTap: () {},
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 20.0,
                                      color: index == 0
                                          ? Colors.grey[700]
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            WrtTooltip(
                              key: Key('${scene.id}_remove'),
                              content: 'timeline.remove'.tr(),
                              showOnTheBottom: true,
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[900],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(180.0),
                                    onTap: () {
                                      final scenesCopy = [
                                        ...widget.chapter.scenes
                                      ];
                                      scenesCopy.remove(scene);
                                      provider.updateChapter(
                                        widget.chapter.copyWith(
                                          scenes: scenesCopy,
                                        ),
                                      );
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 20.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            WrtTooltip(
                              key: Key('${scene.id}_start_ctn'),
                              content: 'timeline.start_continuation'.tr(),
                              showOnTheBottom: true,
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[900],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(180.0),
                                    onTap: () {},
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: 20.0,
                                      color: index ==
                                              widget.chapter.scenes.length - 1
                                          ? Colors.grey[700]
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
                startConnectorBuilder: (context, index) {
                  return Connector.solidLine(
                    color: colors.values
                        .toList()[widget.chapter.index]
                        .withOpacity(0.4),
                    thickness: 20.0,
                  );
                },
                endConnectorBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    color: colors.values
                        .toList()[widget.chapter.index]
                        .withOpacity(0.4),
                    height: 20.0,
                    padding: const EdgeInsets.only(left: 30.0),
                    child: index.isOdd
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.chapter.name.toUpperCase().substring(
                                        0,
                                        widget.chapter.name.length > 18
                                            ? 18
                                            : null,
                                      ) +
                                  (widget.chapter.name.length > 18
                                      ? '...'
                                      : ''),
                              style: theme.textTheme.labelSmall,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: widget.chapter.scenes.map((scene) {
              return Container(
                width: 360.0,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'timeline.implemented_threads'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ...List.generate(
                          scene.threads.length,
                          (index) {
                            final element =
                                scene.threads.entries.toList()[index];
                            return SizedBox(
                              height: 25.0,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: HoverBox(
                                      autoDecideIfLeft: true,
                                      autoDecideIfBottom: true,
                                      content: ThreadSnippet(
                                        threadId: element.key,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10.0,
                                        ),
                                        child: Text(
                                          element.value,
                                          style: theme.textTheme.bodyMedium,
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        final threadsCopy = {...scene.threads};
                                        threadsCopy.remove(element.key);
                                        _updateScene(
                                          scene.copyWith(
                                            threads: threadsCopy,
                                          ),
                                        );
                                      },
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      child: const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.delete_outlined,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AddThreadTile(
                          chapter: widget.chapter,
                          scene: scene,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              const SizedBox(width: 10.0),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  provider.openChapterEditor(widget.chapter.id);
                },
                child: Text(
                  'errors.open_in_editor'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color.fromARGB(255, 88, 111, 230),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50.0),
        ],
      ),
    );
  }
}
