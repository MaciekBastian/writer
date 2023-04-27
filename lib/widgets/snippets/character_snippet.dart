import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../contexts/text_context_menu.dart';
import '../../models/characters/character.dart';
import '../../providers/project_state.dart';

class CharacterSnippet extends StatelessWidget {
  const CharacterSnippet({
    super.key,
    required this.characterId,
  });

  final String characterId;

  TextSpan _buildText(String text, String highlightWord, TextStyle? style) {
    if (highlightWord.isEmpty) {
      return TextSpan(text: text, style: style);
    } else {
      final input = text.toLowerCase();
      final matches = highlightWord.allMatches(input.toLowerCase()).toList();
      if (matches.isEmpty) return TextSpan(text: text, style: style);
      final rangeFirst = TextRange(
        start: matches.first.start,
        end: matches.first.end,
      );
      return TextSpan(
        style: style,
        children: [
          TextSpan(
            text: rangeFirst.textBefore(text),
            style: style,
          ),
          ...List.generate(matches.length, (index) {
            final e = matches[index];
            final range = TextRange(start: e.start, end: e.end);
            final next =
                index == matches.length - 1 ? null : matches[index + 1];
            return TextSpan(
              children: [
                TextSpan(
                  text: range.textInside(text),
                  style: style?.copyWith(
                    backgroundColor: Colors.yellow[900]?.withOpacity(0.6),
                  ),
                ),
                TextSpan(
                  text: text.substring(
                    range.end,
                    next?.start,
                  ),
                ),
              ],
            );
          }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    final character = provider.getUpToDateCharacterWithoutOpening(characterId);
    final highlightWord = provider.projectSearchQuery.trim().toLowerCase();

    return FutureBuilder<Character?>(
      future: character,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            width: 80.0,
            height: 80.0,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Color(0xFF1638E2),
            ),
          );
        }
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 15.0,
          ),
          children: [
            SelectableText.rich(
              _buildText(
                data.name,
                highlightWord,
                theme.textTheme.headlineSmall,
              ),
              contextMenuBuilder: (context, editableTextState) {
                return TextContextMenu(editableTextState: editableTextState);
              },
            ),
            const SizedBox(height: 5.0),
            InkWell(
              mouseCursor: SystemMouseCursors.click,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                provider.openCharacter(data.id);
              },
              child: Text(
                'errors.open_in_editor'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color.fromARGB(255, 88, 111, 230),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            SelectableRegion(
              focusNode: FocusNode(),
              contextMenuBuilder: (context, selectableRegionState) {
                return TextContextMenu(
                  selectableRegionState: selectableRegionState,
                );
              },
              selectionControls: DesktopTextSelectionControls(),
              child: Container(
                width: 280.0,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                ),
                child: Column(
                  children: [
                    _tile(
                      'character.age'.tr(),
                      '${data.age ?? 'character.unset'.tr()}',
                      context,
                    ),
                    _tile(
                      'character.status'.tr(),
                      'character.${data.status == CharacterStatus.alive ? 'alive' : data.status == CharacterStatus.dead ? 'dead' : 'status_unknown'}'
                          .tr(),
                      context,
                    ),
                    _tile(
                      'character.gender'.tr(),
                      'character.${data.gender == Gender.male ? 'male' : data.gender == Gender.female ? 'female' : data.gender == Gender.other ? 'gender_other' : 'gender_unknown'}'
                          .tr(),
                      context,
                    ),
                    _tile(
                      'character.portrayed_by'.tr(),
                      data.portrayedBy ?? 'character.unset'.tr(),
                      context,
                    ),
                    _tile(
                      'character.aliases'.tr(),
                      data.aliases.isEmpty
                          ? 'character.none'.tr()
                          : data.aliases.join(',\n'),
                      context,
                    ),
                    _tile(
                      'character.family_members'.tr(),
                      data.familyMembers.isEmpty
                          ? 'character.none'.tr()
                          : data.familyMembers.map((e) {
                              return '${e.name}\n(${'character.kinship_values.${e.kinship!.name}'.tr()})';
                            }).join(',\n'),
                      context,
                    ),
                    _tile(
                      'character.friends'.tr(),
                      data.friends.isEmpty
                          ? 'character.none'.tr()
                          : data.friends.map((e) {
                              return e.name;
                            }).join(',\n'),
                      context,
                    ),
                    _tile(
                      'character.enemies'.tr(),
                      data.enemies.isEmpty
                          ? 'character.none'.tr()
                          : data.enemies.map((e) {
                              return e.name;
                            }).join(',\n'),
                      context,
                    ),
                    _tile(
                      'character.occupation_history'.tr(),
                      data.occupationHistory.isEmpty
                          ? 'character.none'.tr()
                          : data.occupationHistory.map((e) {
                              return e.occupation;
                            }).join(',\n'),
                      context,
                    ),
                  ],
                ),
              ),
            ),
            // TODO: affiliations: where character shows up (maybe: add mechanism to autosave this affiliations)

            if (data.description.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    'character.description'.tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                  SelectableText.rich(
                    _buildText(
                      data.description,
                      highlightWord,
                      theme.textTheme.bodyMedium,
                    ),
                    contextMenuBuilder: (context, editableTextState) {
                      return TextContextMenu(
                          editableTextState: editableTextState);
                    },
                  ),
                ],
              ),
            if (data.apperance.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    'character.apperance'.tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                  SelectableText.rich(
                    _buildText(
                      data.apperance,
                      highlightWord,
                      theme.textTheme.bodyMedium,
                    ),
                    contextMenuBuilder: (context, editableTextState) {
                      return TextContextMenu(
                          editableTextState: editableTextState);
                    },
                  ),
                ],
              ),
            if (data.goals.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    'character.goals'.tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                  SelectableText.rich(
                    _buildText(
                      data.goals,
                      highlightWord,
                      theme.textTheme.bodyMedium,
                    ),
                    contextMenuBuilder: (context, editableTextState) {
                      return TextContextMenu(
                          editableTextState: editableTextState);
                    },
                  ),
                ],
              ),
            const SizedBox(height: 50.0),
          ],
        );
      },
    );
  }

  Widget _tile(String title, String value, BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 5.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.0,
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
