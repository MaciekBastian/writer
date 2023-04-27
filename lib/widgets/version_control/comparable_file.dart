import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/characters/affiliated_person.dart';
import '../../models/file_tab.dart';

import '../../contexts/text_context_menu.dart';
import '../../helpers/general_helper.dart';
import '../../models/characters/character.dart';
import '../../models/version/version.dart';

class ComparableFile extends StatefulWidget {
  const ComparableFile({
    super.key,
    required this.file1,
    required this.file2,
    required this.controller,
    this.selectedId,
    this.selectedType,
    this.compared = false,
  });

  final VersionFile file1;
  final VersionFile file2;
  final FileType? selectedType;
  final String? selectedId;
  final bool compared;
  final FileCompareController controller;

  @override
  State<ComparableFile> createState() => _ComparableFileState();
}

class _ComparableFileState extends State<ComparableFile> {
  List<Widget> _buildFile(VersionFile file1, VersionFile file2,
      [bool compared = false]) {
    switch (widget.selectedType) {
      case FileType.editor:
        final hasChapter1 = file1.chapters.any((el) {
          return el.id == widget.selectedId;
        });
        final hasChapter2 = file2.chapters.any((element) {
          return element.id == widget.selectedId;
        });
        final chapter1 = hasChapter1
            ? file1.chapters.firstWhere((el) {
                return el.id == widget.selectedId;
              })
            : null;
        final chapter2 = hasChapter2
            ? file2.chapters.firstWhere((el) {
                return el.id == widget.selectedId;
              })
            : null;

        // TODO: handle this case

        return [];
      case FileType.general:
        return [
          _buildTile(
            label: 'general.project_name'.tr(),
            string1: file1.config.name,
            string2: file2.config.name,
            compared: compared,
          ),
          _buildTile(
            label: 'general.author'.tr(),
            string1: file1.config.author,
            string2: file2.config.author,
            compared: compared,
          ),
          _buildTile(
            label: 'general.language'.tr(),
            string1:
                'general.language_values.${file1.config.language.name}'.tr(),
            string2:
                'general.language_values.${file2.config.language.name}'.tr(),
            compared: compared,
          ),
        ];
      case FileType.timelineEditor:
        // TODO: Handle this case.
        return [];
      case FileType.threadEditor:
        // TODO: Handle this case.
        return [];
      case FileType.characterEditor:
        return _buildCharacter(file1, file2, compared);
      default:
        return [];
    }
  }

  List<Widget> _buildCharacter(VersionFile file1, VersionFile file2,
      [bool compared = false]) {
    if (widget.selectedId == null) return [];
    final hasCharacter1 = file1.characters.indexWhere((element) {
      return element.id == widget.selectedId;
    });
    final hasCharacter2 = file2.characters.indexWhere((element) {
      return element.id == widget.selectedId;
    });
    if (hasCharacter1 == -1 || hasCharacter2 == -1) {
      if (!compared && hasCharacter1 == -1) {
        return [
          Text('version_control.compare_page.file_was_removed'.tr()),
        ];
      }
      if (compared && hasCharacter1 == -1) {
        return [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'version_control.compare_page.file_did_not_exist'.tr(),
            ),
          ),
        ];
      }
    }
    final character1 =
        hasCharacter1 == -1 ? null : file1.characters[hasCharacter1];
    final character2 =
        hasCharacter2 == -1 ? null : file2.characters[hasCharacter2];

    return [
      _buildTile(
        label: 'character.character_name'.tr(),
        string1: character1?.name,
        string2: character2?.name,
        compared: compared,
      ),
      _buildTile(
        label: 'character.character_age'.tr(),
        string1: character1 == null
            ? null
            : character1.age?.toString() ?? 'character.unset'.tr(),
        string2: character2 == null
            ? null
            : character2.age?.toString() ?? 'character.unset'.tr(),
        compared: compared,
      ),
      _buildTile(
        label: 'character.character_gender'.tr(),
        string1: character1 == null
            ? null
            : character1.gender == Gender.male
                ? 'character.male'.tr()
                : character1.gender == Gender.female
                    ? 'character.female'.tr()
                    : character1.gender == Gender.other
                        ? 'character.gender_other'.tr()
                        : 'character.gender_unknown'.tr(),
        string2: character2 == null
            ? null
            : character2.gender == Gender.male
                ? 'character.male'.tr()
                : character2.gender == Gender.female
                    ? 'character.female'.tr()
                    : character2.gender == Gender.other
                        ? 'character.gender_other'.tr()
                        : 'character.gender_unknown'.tr(),
        compared: compared,
      ),
      _buildTile(
        label: 'character.character_status'.tr(),
        string1: character1 == null
            ? null
            : character1.status == CharacterStatus.alive
                ? 'character.alive'.tr()
                : character1.status == CharacterStatus.dead
                    ? 'character.dead'.tr()
                    : 'character.status_unknown'.tr(),
        string2: character2 == null
            ? null
            : character2.status == CharacterStatus.alive
                ? 'character.alive'.tr()
                : character2.status == CharacterStatus.dead
                    ? 'character.dead'.tr()
                    : 'character.status_unknown'.tr(),
        compared: compared,
      ),
      _buildTile(
        label: 'character.portrayed_by'.tr(),
        string1: character1 == null
            ? null
            : character1.portrayedBy ?? 'character.unset'.tr(),
        string2: character2 == null
            ? null
            : character2.portrayedBy ?? 'character.unset'.tr(),
        compared: compared,
      ),
      _buildTile(
        label: 'character.description'.tr(),
        string1: character1 == null
            ? null
            : character1.description.isEmpty
                ? 'character.unset'.tr()
                : character1.description,
        string2: character2 == null
            ? null
            : character2.description.isEmpty
                ? 'character.unset'.tr()
                : character2.description,
        compared: compared,
      ),
      _buildTile(
        label: 'character.apperance'.tr(),
        string1: character1 == null
            ? null
            : character1.apperance.isEmpty
                ? 'character.unset'.tr()
                : character1.apperance,
        string2: character2 == null
            ? null
            : character2.apperance.isEmpty
                ? 'character.unset'.tr()
                : character2.apperance,
        compared: compared,
      ),
      _buildTile(
        label: 'character.goals'.tr(),
        string1: character1 == null
            ? null
            : character1.goals.isEmpty
                ? 'character.unset'.tr()
                : character1.goals,
        string2: character2 == null
            ? null
            : character2.goals.isEmpty
                ? 'character.unset'.tr()
                : character2.goals,
        compared: compared,
      ),
      _buildTile(
        label: 'character.aliases'.tr(),
        string1: character1?.aliases.join(', '),
        string2: character2?.aliases.join(', '),
        compared: compared,
      ),
      _buildTile(
        label: 'character.family_members'.tr(),
        string1: character1?.familyMembers.map((e) {
          return '${e.name}: ${'character.kinship_values.${e.kinship!.name}'.tr()}';
        }).join(',\n'),
        string2: character2?.familyMembers.map((e) {
          return '${e.name}: ${'character.kinship_values.${e.kinship!.name}'.tr()}';
        }).join(',\n'),
        compared: compared,
      ),
      _buildTile(
        label: 'character.friends'.tr(),
        string1: character1?.friends.map((e) {
          return '${e.name}: ${e.sideChange == SideChange.fromEnemy ? 'character.former_enemy'.tr() : ''}';
        }).join(',\n'),
        string2: character2?.friends.map((e) {
          return '${e.name}: ${e.sideChange == SideChange.fromEnemy ? 'character.former_enemy'.tr() : ''}';
        }).join(',\n'),
        compared: compared,
      ),
      _buildTile(
        label: 'character.enemies'.tr(),
        string1: character1?.enemies.map((e) {
          return '${e.name}: ${e.sideChange == SideChange.toEnemy ? 'character.former_friend'.tr() : ''}';
        }).join(',\n'),
        string2: character2?.enemies.map((e) {
          return '${e.name}: ${e.sideChange == SideChange.toEnemy ? 'character.former_friend'.tr() : ''}';
        }).join(',\n'),
        compared: compared,
      ),
      _buildTile(
        label: 'character.enemies'.tr(),
        string1: character1?.enemies.map((e) {
          return '${e.name}: ${e.sideChange == SideChange.toEnemy ? 'character.former_friend'.tr() : ''}';
        }).join(',\n'),
        string2: character2?.enemies.map((e) {
          return '${e.name}: ${e.sideChange == SideChange.toEnemy ? 'character.former_friend'.tr() : ''}';
        }).join(',\n'),
        compared: compared,
      ),
      _buildTile(
        label: 'character.occupation_history'.tr(),
        string1: character1?.occupationHistory.map((e) {
          return e.occupation;
        }).join(',\n'),
        string2: character2?.occupationHistory.map((e) {
          return e.occupation;
        }).join(',\n'),
        compared: compared,
      ),
    ];
  }

  Widget _buildTile({
    required String label,
    required String? string1,
    required String? string2,
    required bool compared,
  }) {
    final theme = Theme.of(context);
    final text = Text.rich(
      _textComparison(
        compared ? string1 ?? '' : string2 ?? '',
        compared ? string2 ?? '' : string1 ?? '',
        theme.textTheme.bodyMedium,
        compared,
      ),
    );

    final key = GlobalKey();

    if (!compared) {
      if (string1 != string2) {
        widget.controller.registerChange(key);
      }
    }

    return Column(
      key: key,
      children: [
        Container(
          color: widget.controller.isSelected(key)
              ? Colors.white10
              : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (compared) const SizedBox(width: 10.0),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                flex: 2,
                child: compared
                    ? Stack(
                        children: [
                          Text(
                            text.textSpan?.toPlainText() ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.transparent,
                            ),
                          ),
                          SelectableText(
                            string1 ?? '',
                            style: theme.textTheme.bodyMedium,
                            contextMenuBuilder: (context, editableTextState) {
                              return TextContextMenu(
                                editableTextState: editableTextState,
                              );
                            },
                          ),
                        ],
                      )
                    : text,
              ),
              if (!compared) const SizedBox(width: 10.0),
            ],
          ),
        ),
        Divider(
          height: 4.0,
          thickness: 2.0,
          color: const Color(0xFF242424),
          endIndent: compared ? 0 : 10,
          indent: compared ? 10 : 0,
        ),
      ],
    );
  }

  TextSpan _textComparison(
      String string1, String string2, TextStyle? style, bool compared) {
    final green = style?.copyWith(
      color: Colors.green[200],
      backgroundColor: Colors.green.withOpacity(0.3),
    );
    final red = style?.copyWith(
      color: Colors.red[200],
      decoration: TextDecoration.lineThrough,
      backgroundColor: Colors.red.withOpacity(0.3),
    );
    if (string1.trim().isEmpty) {
      return TextSpan(
        text: string2,
        style: compared ? style : green,
      );
    } else if (string2.trim().isEmpty) {
      return TextSpan(
        text: string1,
        style: compared ? style : green,
      );
    }
    final List<String> words1 = string1.trim().split(' ');
    final List<String> words2 = string2.trim().split(' ');

    List<TextSpan> spans = [];

    for (int i = 0; i < words1.length; i++) {
      if (words2.contains(words1[i])) {
        spans.add(
          TextSpan(text: '${words1[i]} ', style: style),
        );
      } else {
        spans.add(
          TextSpan(
            text: '${words1[i]} ',
            style: compared ? style : red,
          ),
        );
      }
    }

    for (int i = 0; i < words2.length; i++) {
      if (!words1.contains(words2[i])) {
        spans.add(
          TextSpan(
            text: '${words2[i]} ',
            style: compared
                ? green
                : style?.copyWith(
                    color: Colors.green[200],
                    backgroundColor: Colors.green.withOpacity(0.3),
                  ),
          ),
        );
      }
    }

    // Merge adjacent TextSpans with the same style
    for (int i = 0; i < spans.length - 1; i++) {
      if (spans[i].style == spans[i + 1].style) {
        spans[i] = TextSpan(
          text: (spans[i].text ?? '') + (spans[i + 1].text ?? ''),
          style: spans[i].style,
        );
        spans.removeAt(i + 1);
        i--;
      }
    }

    return TextSpan(children: spans);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      widget.controller.closeRegistration();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildFile(widget.file1, widget.file2, widget.compared),
    );
  }
}

class FileCompareController with ChangeNotifier {
  int _index = -1;
  final List<GlobalKey> _keysWithChanges = [];

  void registerChange(GlobalKey key) {
    if (_index == -1) _keysWithChanges.add(key);
  }

  void clear([bool notify = true]) {
    _keysWithChanges.clear();
    _index = 0;
    if (notify) notifyListeners();
  }

  void closeRegistration() {
    _index = 0;
    notifyListeners();
  }

  void nextChange() {
    if (_keysWithChanges.isEmpty) return;
    if (_keysWithChanges.length == _index + 1) {
      _index = 0;
    } else {
      _index = _index + 1;
    }
    if (_keysWithChanges[_index].currentContext != null) {
      Scrollable.ensureVisible(_keysWithChanges[_index].currentContext!);
    }
    notifyListeners();
  }

  bool isSelected(GlobalKey key) {
    if (_index == -1) return false;
    if (_keysWithChanges.contains(key)) {
      return _keysWithChanges[_index] == key;
    }
    return false;
  }

  bool get hasData => _keysWithChanges.isNotEmpty;
}
