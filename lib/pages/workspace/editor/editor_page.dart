import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:provider/provider.dart';
import 'package:writer/pages/workspace/editor/editor_scene.dart';
import 'package:writer/widgets/dropdown_select.dart';

import '../../../models/chapters/chapter_file.dart';
import '../../../providers/project_state.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _toolbarScroll = ScrollController();
  String? _selectedScene;

  void _initialize() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);
    final chapter = provider.getChapter(provider.selectedTab!.id!);

    return Column(
      children: [
        // TOOLBAR
        Container(
          color: const Color(0xFF191919),
          height: 40.0,
          child: Row(
            children: [
              Expanded(
                child: ImprovedScrolling(
                  scrollController: _toolbarScroll,
                  enableKeyboardScrolling: true,
                  enableCustomMouseWheelScrolling: true,
                  child: ListView(
                    controller: _toolbarScroll,
                    scrollDirection: Axis.horizontal,
                    children: [
                      // TODO: this toolbar
                    ],
                  ),
                ),
              ),
              if (chapter.scenes.isNotEmpty)
                Container(
                  width: 250.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF191919),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10.0,
                        offset: Offset(-10, 0),
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // TODO: manipulate scenes
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          borderRadius: BorderRadius.circular(6.0),
                          child: const SizedBox(
                            height: 35.0,
                            width: 35.0,
                            child: Icon(
                              Icons.fast_rewind_outlined,
                              size: 20.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 40.0,
                          padding: const EdgeInsets.all(6.0),
                          child: WrtDropdownSelect(
                            onSelected: (value) {
                              setState(() {
                                _selectedScene = value;
                              });
                            },
                            values: chapter.scenes.map((e) => e.id).toList(),
                            smaller: true,
                            labels: chapter.scenes.asMap().map(
                              (key, value) {
                                return MapEntry(
                                  value.id,
                                  value.name == null ||
                                          value.name!.trim().isEmpty
                                      ? '${'right_sidebar.scene'.tr()}: ${value.index + 1}'
                                      : value.name!,
                                );
                              },
                            ),
                            initiallySelected:
                                _selectedScene ?? chapter.scenes.first.id,
                          ),
                        ),
                      ),
                      // TODO: manipulate scenes
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          borderRadius: BorderRadius.circular(6.0),
                          child: const SizedBox(
                            height: 35.0,
                            width: 35.0,
                            child: Icon(
                              Icons.fast_forward_outlined,
                              size: 20.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // working area
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SceneEditor(),
              ),
              if (!provider.smallScreenView && !provider.showRightSidebar)
                Container(
                  color: const Color(0xFF191919),
                  width: 250.0,
                  height: double.infinity,
                  child: Column(
                    children: [
                      // TODO: chapter outline
                      Expanded(
                        child: Container(),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: const Color(0xFF242424),
                          child: ListView(
                            children: [],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
