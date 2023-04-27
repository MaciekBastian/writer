import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/characters/affiliated_person.dart';
import '../../models/characters/character.dart';
import '../../models/file_tab.dart';
import '../checkbox.dart';
import '../dropdown_select.dart';

import '../../providers/project_state.dart';

class AddFriendOrEnemyWindow extends StatefulWidget {
  const AddFriendOrEnemyWindow({
    super.key,
    required this.friend,
    required this.character,
  });

  final bool friend;
  final Character character;

  @override
  State<AddFriendOrEnemyWindow> createState() => _AddFriendOrEnemyWindowState();
}

class _AddFriendOrEnemyWindowState extends State<AddFriendOrEnemyWindow> {
  String? _pickedId;
  bool _formerFriendOrEnemy = false;
  bool _applyValueToOtherCharacter = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);
    final availableCharacters = provider.characters.entries.where(
      (element) {
        return !(widget.character.friends.any((el) {
              return el.id == element.key;
            })) &&
            !(widget.character.enemies.any((el) {
              return el.id == element.key;
            })) &&
            element.key != widget.character.id;
      },
    ).toList();

    return Dialog(
      alignment: Alignment.center,
      child: Container(
        width: 400.0,
        height: 280.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              spreadRadius: 2.0,
              blurRadius: 20.0,
            )
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 32.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      widget.friend
                          ? 'character.add_friend'.tr()
                          : 'character.add_enemy'.tr(),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  CloseWindowButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    colors: WindowButtonColors(
                      iconNormal: Colors.grey[400],
                      iconMouseDown: Colors.white,
                      iconMouseOver: Colors.white,
                      mouseOver: Colors.red,
                      mouseDown: Colors.red[200],
                      normal: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            if (availableCharacters.isNotEmpty)
              Container(
                width: double.infinity,
                height: 55.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                child: WrtDropdownSelect(
                  title: 'character.pick_character'.tr(),
                  initiallySelected: availableCharacters.first.key,
                  onSelected: (value) {
                    setState(() {
                      _pickedId = value;
                    });
                  },
                  values: availableCharacters.map((e) => e.key).toList(),
                  labels: availableCharacters.asMap().map(
                    (key, value) {
                      return MapEntry(value.key, value.value);
                    },
                  ),
                ),
              ),
            WrtCheckbox(
              label: widget.friend
                  ? 'character.mark_as_former_enemy'.tr()
                  : 'character.mark_as_former_friend'.tr(),
              value: _formerFriendOrEnemy,
              callback: () {
                setState(() {
                  _formerFriendOrEnemy = !_formerFriendOrEnemy;
                });
              },
            ),
            const SizedBox(height: 8.0),
            if (availableCharacters.isNotEmpty)
              WrtCheckbox(
                label: widget.friend
                    ? 'character.also_apply_this_relationship'.tr(args: [
                        availableCharacters.firstWhere((element) {
                          return element.key ==
                              (_pickedId ?? availableCharacters.first.key);
                        }).value,
                      ])
                    : 'character.also_apply_this_relationship'.tr(args: [
                        availableCharacters.firstWhere((element) {
                          return element.key ==
                              (_pickedId ?? availableCharacters.first.key);
                        }).value,
                      ]),
                value: _applyValueToOtherCharacter,
                callback: () {
                  setState(() {
                    _applyValueToOtherCharacter = !_applyValueToOtherCharacter;
                  });
                },
              ),
            const SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 15.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () async {
                    if (availableCharacters.isEmpty) {
                      Navigator.of(context).pop();
                      return;
                    }

                    if (widget.friend) {
                      Navigator.of(context).pop(
                        AffiliatedPerson.friend(
                          id: _pickedId ?? availableCharacters.first.key,
                          name: availableCharacters.firstWhere((element) {
                            return element.key ==
                                (_pickedId ?? availableCharacters.first.key);
                          }).value,
                          sideChange: _formerFriendOrEnemy
                              ? SideChange.fromEnemy
                              : null,
                        ),
                      );
                    } else {
                      Navigator.of(context).pop(
                        AffiliatedPerson.enemy(
                          id: _pickedId ?? availableCharacters.first.key,
                          name: availableCharacters.firstWhere((element) {
                            return element.key ==
                                (_pickedId ?? availableCharacters.first.key);
                          }).value,
                          sideChange:
                              _formerFriendOrEnemy ? SideChange.toEnemy : null,
                        ),
                      );
                    }

                    if (_applyValueToOtherCharacter) {
                      final characterData =
                          await provider.getUpToDateCharacterWithoutOpening(
                        _pickedId ?? availableCharacters.first.key,
                      );
                      if (characterData != null) {
                        provider.openTabInBackground(
                          FileTab(
                            id: characterData.id,
                            path: null,
                            type: FileType.characterEditor,
                          ),
                        );
                        if (widget.friend) {
                          final friendsCopy = [...characterData.friends];
                          if (friendsCopy.every((element) {
                            return element.id != widget.character.id;
                          })) {
                            friendsCopy.add(
                              AffiliatedPerson.friend(
                                id: widget.character.id,
                                name: widget.character.name,
                                sideChange: _formerFriendOrEnemy
                                    ? SideChange.fromEnemy
                                    : null,
                              ),
                            );
                            provider.updateCharacter(characterData.copyWith(
                              friends: friendsCopy,
                            ));
                          }
                        } else {
                          final enemiesCopy = [...characterData.enemies];
                          if (enemiesCopy.every((element) {
                            return element.id != widget.character.id;
                          })) {
                            enemiesCopy.add(
                              AffiliatedPerson.enemy(
                                id: widget.character.id,
                                name: widget.character.name,
                                sideChange: _formerFriendOrEnemy
                                    ? SideChange.fromEnemy
                                    : null,
                              ),
                            );
                            provider.updateCharacter(characterData.copyWith(
                              enemies: enemiesCopy,
                            ));
                          }
                        }
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 10.0,
                    ),
                    child: Text(
                      widget.friend
                          ? 'character.add_friend'.tr()
                          : 'character.add_enemy'.tr(),
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
