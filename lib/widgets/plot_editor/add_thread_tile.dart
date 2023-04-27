import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chapters/chapter.dart';
import '../../models/chapters/scene.dart';
import '../../providers/project_state.dart';
import '../dropdown_select.dart';

class AddThreadTile extends StatefulWidget {
  const AddThreadTile({
    super.key,
    required this.chapter,
    required this.scene,
  });
  final Chapter chapter;
  final Scene scene;

  @override
  State<AddThreadTile> createState() => _AddThreadTileState();
}

class _AddThreadTileState extends State<AddThreadTile> {
  String? _selectedThread;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    return Builder(
      builder: (context) {
        final availableThreads = {...provider.threads};
        availableThreads.removeWhere((key, value) {
          return widget.scene.threads.containsKey(key);
        });

        if (availableThreads.isEmpty) {
          return Container();
        }

        return SizedBox(
          height: 55.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: WrtDropdownSelect<String>(
                  title: 'timeline.pick_thread'.tr(),
                  initiallySelected: 'null',
                  onSelected: (val) {
                    if (val == 'null') return;
                    setState(() {
                      _selectedThread = val;
                    });
                  },
                  values: [
                    'null',
                    ...availableThreads.keys.toList(),
                  ],
                  labels: {
                    'null': 'timeline.none'.tr(),
                    ...availableThreads,
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: const Color(0xFF1638E2),
                    width: 2.0,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final threadsCopy = {...widget.scene.threads};
                      threadsCopy.addEntries([
                        availableThreads.entries.firstWhere((element) {
                          return element.key ==
                              (_selectedThread ??
                                  availableThreads.entries.first.key);
                        })
                      ]);
                      _updateScene(
                        widget.scene.copyWith(
                          threads: threadsCopy,
                        ),
                      );
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Container(
                      height: 55.0,
                      width: 40.0,
                      alignment: Alignment.center,
                      child: Text(
                        'timeline.add'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
