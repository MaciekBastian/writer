import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/snippets/character_snippet.dart';

import '../../providers/project_state.dart';
import '../../widgets/dropdown_select.dart';
import '../../widgets/hover_box.dart';
import '../../widgets/text_field.dart';

class ThreadEditor extends StatefulWidget {
  const ThreadEditor({super.key});

  @override
  State<ThreadEditor> createState() => _ThreadEditorState();
}

class _ThreadEditorState extends State<ThreadEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final projectProvider = Provider.of<ProjectState>(context);
    final thread = projectProvider.getThread(
      projectProvider.selectedTab!.id!,
    );

    return Padding(
      key: Key(thread.id),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView(
              children: [
                SizedBox(
                  height: 55.0,
                  child: WrtTextField(
                    initialValue: thread.name,
                    title: 'thread.thread_name'.tr(),
                    onEdit: (val) {
                      provider.updateThread(
                        thread.copyWith(
                          name: val,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 250.0,
                        child: WrtTextField(
                          initialValue: thread.conflict,
                          title: 'thread.conflict'.tr(),
                          altText: 'thread.unset'.tr(),
                          maxLines: 16,
                          onEdit: (val) {
                            provider.updateThread(
                              thread.copyWith(
                                conflict: val,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: SizedBox(
                        height: 250.0,
                        child: WrtTextField(
                          initialValue: thread.result,
                          title: 'thread.result'.tr(),
                          altText: 'thread.unset'.tr(),
                          maxLines: 16,
                          onEdit: (val) {
                            provider.updateThread(
                              thread.copyWith(
                                result: val,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: SelectableText(
                        'thread.conflict_hint'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(width: 22.0),
                    Expanded(
                      child: SelectableText(
                        'thread.result_hint'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242424),
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: const Color(0xFF5D5D5D),
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 4.0),
                        child: Text(
                          'thread.characters_involved'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      ...List.generate(
                        thread.charactersInvolved.length,
                        (index) {
                          final e =
                              thread.charactersInvolved.entries.toList()[index];
                          final hasCharacter =
                              provider.characters.containsKey(e.key);
                          final name = Text(
                            e.value,
                            style: theme.textTheme.bodyMedium,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: hasCharacter
                                      ? HoverBox(
                                          size: const Size(320.0, 250.0),
                                          content: CharacterSnippet(
                                            characterId: e.key,
                                          ),
                                          child: name,
                                        )
                                      : name,
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      final charactersInvolvedCopy = {
                                        ...thread.charactersInvolved
                                      };
                                      charactersInvolvedCopy.remove(e.key);
                                      provider.updateThread(
                                        thread.copyWith(
                                          charactersInvolved:
                                              charactersInvolvedCopy,
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
                      const _AddCharacterButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                if (provider.smallScreenView)
                  SizedBox(
                    width: double.infinity,
                    height: 250.0,
                    child: WrtTextField(
                      initialValue: thread.description,
                      altText: 'thread.unset'.tr(),
                      title: 'thread.thread_description'.tr(),
                      maxLines: 80,
                      onEdit: (val) {
                        provider.updateThread(
                          thread.copyWith(
                            description: val,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          if (!provider.smallScreenView)
            Expanded(
              flex: 2,
              child: WrtTextField(
                initialValue: thread.description,
                altText: 'thread.unset'.tr(),
                title: 'thread.thread_description'.tr(),
                maxLines: 80,
                onEdit: (val) {
                  provider.updateThread(
                    thread.copyWith(
                      description: val,
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

class _AddCharacterButton extends StatefulWidget {
  const _AddCharacterButton();

  @override
  State<_AddCharacterButton> createState() => __AddCharacterButtonState();
}

class __AddCharacterButtonState extends State<_AddCharacterButton> {
  bool _isInEditMode = false;
  String? _characterId;
  String? _characterName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final projectProvider = Provider.of<ProjectState>(context);
    final thread = projectProvider.getThread(
      projectProvider.selectedTab!.id!,
    );
    final allCharacters = provider.characters;
    final availableCharacters = allCharacters.entries.where(
      (element) {
        return !(thread.charactersInvolved.keys.contains(
          element.key,
        ));
      },
    ).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: const Color(0xFF5D5D5D),
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!_isInEditMode) {
                  setState(() {
                    _isInEditMode = true;
                  });
                }
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 10.0,
                ),
                child: Text(
                  'thread.add_new_character'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          if (_isInEditMode && availableCharacters.isNotEmpty)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 70.0,
                        padding: const EdgeInsets.all(8.0),
                        child: WrtDropdownSelect(
                          title: 'thread.pick_character'.tr(),
                          initiallySelected: availableCharacters.first.key,
                          onSelected: (value) {
                            setState(() {
                              _characterId = value;
                              _characterName = allCharacters[value];
                            });
                          },
                          values: availableCharacters.map((e) {
                            return e.key;
                          }).toList(),
                          labels: availableCharacters.asMap().map((key, value) {
                            return MapEntry(value.key, value.value);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 35.0,
                      margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: const Color(0xFF1638E2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_characterId == null ||
                                _characterName == null) {
                              _characterId = availableCharacters.first.key;
                              _characterName = availableCharacters.first.value;
                            }

                            final charactersInvolved =
                                thread.charactersInvolved;
                            charactersInvolved[_characterId!] = _characterName!;
                            provider.updateThread(
                              thread.copyWith(
                                charactersInvolved: charactersInvolved,
                              ),
                            );
                            setState(() {
                              _isInEditMode = false;
                            });
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Row(
                            children: [
                              const SizedBox(width: 15.0),
                              const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                'thread.add'.tr(),
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 15.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
