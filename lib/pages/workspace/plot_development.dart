import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';

import '../../models/chapters/chapter.dart';
import '../../models/chapters/scene.dart';
import '../../providers/project_state.dart';
import '../../widgets/hover_box.dart';
import '../../widgets/snippets/thread_snippet.dart';
import '../../widgets/tooltip.dart';

class PlotDevelopment extends StatefulWidget {
  const PlotDevelopment({super.key});

  @override
  State<PlotDevelopment> createState() => _PlotDevelopmentState();
}

class _PlotDevelopmentState extends State<PlotDevelopment> {
  Map<String, int> _getThreadsBeginnings(List<Scene> scenes) {
    final provider = Provider.of<ProjectState>(context);
    Map<String, int> result = {};

    for (var scene in scenes) {
      for (var thread in scene.threads.entries) {
        final threadId = thread.key;
        final hasThread = provider.threads.containsKey(threadId);
        if (hasThread) {
          if (!(result.containsKey(threadId))) {
            result[threadId] = scenes.indexOf(scene);
          }
        }
      }
    }

    return result;
  }

  Map<String, int> _getThreadsEndings(List<Scene> scenes) {
    final provider = Provider.of<ProjectState>(context);
    Map<String, int> result = {};

    for (var scene in scenes) {
      for (var thread in scene.threads.entries) {
        final threadId = thread.key;
        final hasThread = provider.threads.containsKey(threadId);
        if (hasThread) {
          result[threadId] = scenes.indexOf(scene);
        }
      }
    }

    return result;
  }

  Map<String, Color> _assignColorToThread(List<String> threads) {
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
    final provider = Provider.of<ProjectState>(context);

    final scenes = provider.scenes.where((element) {
      return element.threads.isNotEmpty;
    }).toList();

    final threadBeginnings = _getThreadsBeginnings(scenes);
    final threadEndings = _getThreadsEndings(scenes);
    final colors = _assignColorToThread(provider.threads.keys.toList());

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 30.0,
          color: const Color(0xFF1C1C1C),
          padding: const EdgeInsets.only(right: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              WrtTooltip(
                key: const Key('toggle_tooltips_button'),
                showOnTheLeft: true,
                content: 'plot_development.toggle_tooltips'.tr(),
                child: InkWell(
                  onTap: () {
                    provider.toggleTooltips();
                  },
                  borderRadius: BorderRadius.circular(6.0),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(
                    provider.tooltips
                        ? Icons.hide_source
                        : Icons.source_outlined,
                    size: 20.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15.0),
        Expanded(
          child: ListView.builder(
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];
              final chapter = provider.chapters.firstWhere(
                (element) => element.scenes.contains(scene),
              );

              return _PlotDevelopmentTile(
                key: Key(scene.id),
                scene: scene,
                index: index,
                threadBeginnings: threadBeginnings,
                colors: colors,
                chapter: chapter,
                tooltips: provider.tooltips,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlotDevelopmentTile extends StatefulWidget {
  const _PlotDevelopmentTile({
    super.key,
    required this.index,
    required this.scene,
    required this.threadBeginnings,
    required this.colors,
    required this.chapter,
    required this.tooltips,
  });

  final Scene scene;
  final int index;
  final Map<String, int> threadBeginnings;
  final Map<String, Color> colors;
  final Chapter chapter;
  final bool tooltips;

  @override
  State<_PlotDevelopmentTile> createState() => _PlotDevelopmentTileState();
}

class _PlotDevelopmentTileState extends State<_PlotDevelopmentTile> {
  final _threadsScrollController = ScrollController();
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    final scenes = provider.scenes;

    var threadsToThisTime = widget.threadBeginnings.entries.where(
      (element) {
        return element.value <= widget.index;
      },
    ).toList();
    threadsToThisTime = threadsToThisTime
        .getRange(
          0,
          threadsToThisTime.length < 10 ? threadsToThisTime.length : 10,
        )
        .toList();

    final threadTags = widget.scene.threads.entries
        .map((e) {
          if (widget.threadBeginnings[e.key] != widget.index) {
            return null;
          }

          final label = Container(
            height: 30.0,
            width: 140.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.colors[e.key] ?? Colors.grey,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(6.0),
            ),
            margin: const EdgeInsets.only(right: 10.0),
            child: Row(
              children: [
                Icon(
                  Icons.label_outline,
                  color: widget.colors[e.key] ?? Colors.grey,
                  size: 20.0,
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    e.value,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
                const SizedBox(width: 4.0),
              ],
            ),
          );
          if (!widget.tooltips) return label;

          return HoverBox(
            key: Key('${e.key}_thread_tag'),
            showOnTheBottom: widget.index == 0,
            autoDecideIfLeft: true,
            content: ThreadSnippet(
              threadId: e.key,
            ),
            child: label,
          );
        })
        .whereType<Widget>()
        .toList();

    return Row(
      children: [
        Container(
          width: 10.0,
          height: _expanded ? 200.0 : 80.0,
          margin: const EdgeInsets.only(
            left: 10.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: widget.index == 0
                  ? const Radius.circular(80.0)
                  : const Radius.circular(0.0),
              topRight: widget.index == 0
                  ? const Radius.circular(80.0)
                  : const Radius.circular(0.0),
              bottomLeft: widget.index == scenes.length - 1
                  ? const Radius.circular(80.0)
                  : const Radius.circular(0.0),
              bottomRight: widget.index == scenes.length - 1
                  ? const Radius.circular(80.0)
                  : const Radius.circular(0.0),
            ),
            color: Colors.black,
          ),
        ),
        ...threadsToThisTime.map((e) {
          int lastIndexOfThread = scenes.lastIndexWhere(
            (element) {
              return element.threads.containsKey(e.key);
            },
          );
          lastIndexOfThread =
              lastIndexOfThread == -1 ? scenes.length : lastIndexOfThread;

          final includedInThisScene = widget.scene.threads.containsKey(e.key);

          return Container(
            width: 15.0,
            height: _expanded ? 200.0 : 80.0,
            margin: const EdgeInsets.only(
              left: 4.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: widget.index == widget.threadBeginnings[e.key]
                    ? const Radius.circular(80.0)
                    : const Radius.circular(0.0),
                topRight: widget.index == widget.threadBeginnings[e.key]
                    ? const Radius.circular(80.0)
                    : const Radius.circular(0.0),
                bottomLeft: widget.index == lastIndexOfThread
                    ? const Radius.circular(80.0)
                    : const Radius.circular(0.0),
                bottomRight: widget.index == lastIndexOfThread
                    ? const Radius.circular(80.0)
                    : const Radius.circular(0.0),
              ),
              color: widget.index > lastIndexOfThread
                  ? Colors.transparent
                  : widget.colors[e.key] ?? Colors.grey,
            ),
            child: includedInThisScene
                ? Column(
                    children: [
                      SizedBox(height: threadTags.isNotEmpty ? 45.0 : 16.0),
                      Container(
                        width: 13.0,
                        height: 13.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey[800]!,
                            width: 1.0,
                          ),
                        ),
                        child: widget.tooltips
                            ? HoverBox(
                                content: ListView(
                                  children: const [],
                                ),
                                child: Container(),
                              )
                            : null,
                      ),
                    ],
                  )
                : null,
          );
        }).toList(),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (threadTags.isNotEmpty)
                SizedBox(
                  height: 30.0,
                  child: ImprovedScrolling(
                    enableKeyboardScrolling: true,
                    enableCustomMouseWheelScrolling: true,
                    scrollController: _threadsScrollController,
                    child: ListView(
                      controller: _threadsScrollController,
                      scrollDirection: Axis.horizontal,
                      children: threadTags,
                    ),
                  ),
                ),
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  height: (_expanded ? 200.0 : 80.0) -
                      (threadTags.isEmpty ? 0 : 30),
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.chapter.name.isEmpty ? '${'character.chapter'.tr()} ${widget.chapter.index + 1}.' : widget.chapter.name}: ${(widget.scene.name?.isEmpty ?? true) ? '${'character.scene'.tr()} ${widget.scene.index + 1}.' : widget.scene.name}',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (threadTags.isEmpty)
                        Text(
                          '${'timeline.implemented_threads'.tr()}: ${widget.scene.threads.length}${((widget.scene.time?.isNotEmpty ?? false) ? ' • ' : '') + ((widget.scene.time?.isNotEmpty ?? false) ? widget.scene.time! : '')}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if (_expanded && widget.scene.time != null)
                        Text(
                          widget.scene.time!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      if (_expanded)
                        Expanded(
                          child: Text(
                            widget.scene.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
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
