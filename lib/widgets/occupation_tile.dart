import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/characters/occupation.dart';
import '../providers/project_state.dart';
import 'dropdown_select.dart';
import 'text_field.dart';

class OccupationTile extends StatefulWidget {
  const OccupationTile({
    super.key,
    required this.characterId,
    required this.occupation,
  });

  final Occupation occupation;
  final String characterId;

  @override
  State<OccupationTile> createState() => _OccupationTileState();
}

class _OccupationTileState extends State<OccupationTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final projectProvider = Provider.of<ProjectState>(context);
    final character = projectProvider.getCharacter(widget.characterId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: theme.colorScheme.surfaceVariant,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55.0,
                  child: WrtTextField(
                    initialValue: widget.occupation.occupation,
                    title: 'character.occupation'.tr(),
                    onEdit: (val) {
                      final occupationHistoryCopy = [
                        ...character.occupationHistory,
                      ];
                      final index = occupationHistoryCopy.indexWhere((el) {
                        return el.id == widget.occupation.id;
                      });
                      occupationHistoryCopy.removeAt(index);
                      occupationHistoryCopy.insert(
                        index,
                        widget.occupation.copyWith(
                          occupation: val,
                        ),
                      );
                      provider.updateCharacter(
                        character.copyWith(
                          occupationHistory: occupationHistoryCopy,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final occupationHistoryCopy = [
                      ...character.occupationHistory
                    ];
                    final index = occupationHistoryCopy.indexWhere((el) {
                      return el.id == widget.occupation.id;
                    });
                    occupationHistoryCopy.removeAt(index);
                    provider.updateCharacter(
                      character.copyWith(
                        occupationHistory: occupationHistoryCopy,
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
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55.0,
                  child: WrtDropdownSelect(
                    initiallySelected: provider.scenes
                            .map((e) => e.id)
                            .contains(widget.occupation.start)
                        ? widget.occupation.start
                        : [
                            Occupation.before,
                            Occupation.after,
                            Occupation.unknown,
                          ].contains(widget.occupation.start)
                            ? widget.occupation.start
                            : Occupation.unknown,
                    title: 'character.start'.tr(),
                    values: [
                      Occupation.before,
                      Occupation.after,
                      Occupation.unknown,
                      ...provider.scenes.map((e) => e.id).toList(),
                    ],
                    labels: {
                      Occupation.before: 'character.before'.tr(),
                      Occupation.after: 'character.after'.tr(),
                      Occupation.unknown: 'character.start_or_end_unknown'.tr(),
                      ...provider.scenes.asMap().map((key, value) {
                        final chapter = provider.chapters.firstWhere((element) {
                          return element.scenes.contains(value);
                        });
                        final name =
                            '${(chapter.name.isNotEmpty) ? chapter.name.trim() : '${'character.chapter'.tr()} ${chapter.index + 1}'}: ${(value.name != null && (value.name?.isNotEmpty ?? false)) ? value.name : '${'character.scene'.tr()} ${value.index + 1}'}';
                        return MapEntry(value.id, name);
                      })
                    },
                    onSelected: (value) {
                      final occupationHistoryCopy = [
                        ...character.occupationHistory
                      ];
                      final index = occupationHistoryCopy.indexWhere((el) {
                        return el.id == widget.occupation.id;
                      });
                      occupationHistoryCopy.removeAt(index);
                      occupationHistoryCopy.insert(
                        index,
                        widget.occupation.copyWith(
                          start: value,
                        ),
                      );
                      provider.updateCharacter(
                        character.copyWith(
                          occupationHistory: occupationHistoryCopy,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: SizedBox(
                  height: 55.0,
                  child: WrtDropdownSelect(
                    initiallySelected: provider.scenes
                            .map((e) => e.id)
                            .contains(widget.occupation.end)
                        ? widget.occupation.end
                        : [
                            Occupation.before,
                            Occupation.after,
                            Occupation.unknown,
                          ].contains(widget.occupation.end)
                            ? widget.occupation.end
                            : Occupation.unknown,
                    title: 'character.end'.tr(),
                    values: [
                      Occupation.before,
                      Occupation.after,
                      Occupation.unknown,
                      ...provider.scenes.map((e) => e.id).toList(),
                    ],
                    labels: {
                      Occupation.before: 'character.before'.tr(),
                      Occupation.after: 'character.after'.tr(),
                      Occupation.unknown: 'character.start_or_end_unknown'.tr(),
                      ...provider.scenes.asMap().map((key, value) {
                        final chapter = provider.chapters.firstWhere((element) {
                          return element.scenes.contains(value);
                        });
                        final name =
                            '${(chapter.name.isNotEmpty) ? chapter.name.trim() : '${'character.chapter'.tr()} ${chapter.index + 1}'}: ${(value.name != null && (value.name?.isNotEmpty ?? false)) ? value.name : '${'character.scene'.tr()} ${value.index + 1}'}';
                        return MapEntry(value.id, name);
                      })
                    },
                    onSelected: (value) {
                      final occupationHistoryCopy = [
                        ...character.occupationHistory
                      ];
                      final index = occupationHistoryCopy.indexWhere((el) {
                        return el.id == widget.occupation.id;
                      });
                      occupationHistoryCopy.removeAt(index);
                      occupationHistoryCopy.insert(
                        index,
                        widget.occupation.copyWith(
                          end: value,
                        ),
                      );
                      provider.updateCharacter(
                        character.copyWith(
                          occupationHistory: occupationHistoryCopy,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
