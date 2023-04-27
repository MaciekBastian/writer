import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/expandable_section.dart';
import '../../models/error/project_error.dart';
import '../../widgets/characters/add_friend_or_enemy_window.dart';
import '../../models/characters/occupation.dart';
import '../../models/characters/story_plan_entry.dart';
import '../../widgets/hover_box.dart';
import '../../widgets/occupation_tile.dart';
import '../../helpers/general_helper.dart';
import '../../widgets/text_field.dart';

import '../../models/characters/affiliated_person.dart';
import '../../models/characters/character.dart';
import '../../providers/project_state.dart';
import '../../widgets/characters/family_member_tile.dart';
import '../../widgets/dropdown_select.dart';

class CharacterEditor extends StatefulWidget {
  const CharacterEditor({super.key});

  @override
  State<CharacterEditor> createState() => _CharacterEditorState();
}

class _CharacterEditorState extends State<CharacterEditor> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final project = Provider.of<ProjectState>(context);
    final character = provider.getCharacter(
      project.selectedTab!.id!,
    );

    final List<ProjectError> errors = provider.highlightErrors
        ? provider.errorsForFile(provider.selectedTab!)
        : [];

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Padding(
        key: Key(character.id),
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
                      badge: _buildErrorBadge(errors, 'character_name'),
                      initialValue: character.name,
                      title: 'character.character_name'.tr(),
                      onEdit: (val) {
                        provider.updateCharacter(
                          character.copyWith(
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
                          height: 55.0,
                          child: WrtTextField(
                            initialValue: character.age?.toString() ?? '',
                            number: true,
                            title: 'character.character_age'.tr(),
                            altText: 'character.unset'.tr(),
                            onEdit: (val) {
                              if (val.isEmpty) {
                                provider.updateCharacter(
                                  character.removeNullableValues(age: true),
                                );
                              } else {
                                provider.updateCharacter(
                                  character.copyWith(
                                    age: int.tryParse(val),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: SizedBox(
                          height: 55.0,
                          child: WrtDropdownSelect(
                            title: 'character.character_gender'.tr(),
                            initiallySelected: character.gender,
                            labels: {
                              Gender.male: 'character.male'.tr(),
                              Gender.female: 'character.female'.tr(),
                              Gender.other: 'character.gender_other'.tr(),
                              Gender.unknown: 'character.gender_unknown'.tr(),
                            },
                            onSelected: (value) {
                              provider.updateCharacter(
                                character.copyWith(gender: value),
                              );
                            },
                            values: const [
                              Gender.male,
                              Gender.female,
                              Gender.other,
                              Gender.unknown,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55.0,
                          child: WrtDropdownSelect(
                            title: 'character.character_status'.tr(),
                            initiallySelected: character.status,
                            labels: {
                              CharacterStatus.alive: 'character.alive'.tr(),
                              CharacterStatus.dead: 'character.dead'.tr(),
                              CharacterStatus.unknown:
                                  'character.status_unknown'.tr(),
                            },
                            onSelected: (value) {
                              provider.updateCharacter(
                                character.copyWith(status: value),
                              );
                            },
                            values: const [
                              CharacterStatus.alive,
                              CharacterStatus.dead,
                              CharacterStatus.unknown,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: SizedBox(
                          height: 55.0,
                          child: WrtTextField(
                            initialValue: character.portrayedBy,
                            title: 'character.portrayed_by'.tr(),
                            altText: 'character.unset'.tr(),
                            onEdit: (val) {
                              provider.updateCharacter(
                                character.copyWith(
                                  portrayedBy: val,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
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
                          padding:
                              const EdgeInsets.only(left: 5.0, bottom: 4.0),
                          child: Text(
                            'character.occupation_history'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        ...character.occupationHistory
                            .map(
                              (e) => OccupationTile(
                                characterId: character.id,
                                occupation: e,
                              ),
                            )
                            .toList(),
                        Container(
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                provider.updateCharacter(
                                  character.copyWith(
                                    occupationHistory: [
                                      ...character.occupationHistory,
                                      Occupation(
                                        id: GeneralHelper().id(),
                                        occupation:
                                            'character.new_occupation'.tr(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 10.0,
                                ),
                                child: Text(
                                  'character.click_to_add_new_occupation'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // extra fields
                  WrtExpandableSection(
                    header: Text(
                      'character.show_more'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    expandedHeader: Text(
                      'character.hide_more'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    allClickable: true,
                    content: Column(
                      children: [
                        SizedBox(
                          height: 55.0,
                          child: Row(
                            children: [
                              Text(
                                'character.extra_fields.birthday'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: WrtTextField(
                                  onEdit: (value) {
                                    if (value.isEmpty) {
                                      if (character.birthday?.month == null &&
                                          character.birthday?.year == null) {
                                        provider.updateCharacter(
                                          character.removeNullableValues(
                                            birthday: true,
                                          ),
                                        );
                                      } else {
                                        provider.updateCharacter(
                                          character.copyWith(
                                            birthday: Birthday(
                                              year: character.birthday?.year,
                                              month: character.birthday?.month,
                                              day: null,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      provider.updateCharacter(
                                        character.copyWith(
                                          birthday: Birthday(
                                            year: character.birthday?.year,
                                            month: character.birthday?.month,
                                            day: int.tryParse(value),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  title: 'calendar.day'.tr(),
                                  altText: 'character.unset'.tr(),
                                  initialValue:
                                      character.birthday?.day?.toString(),
                                  number: true,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: WrtDropdownSelect<int?>(
                                  initiallySelected: character.birthday?.month,
                                  values: [
                                    null,
                                    ...List.generate(12, (index) => index + 1),
                                  ],
                                  onSelected: (value) {
                                    if (value == null) {
                                      if (character.birthday?.month == null &&
                                          character.birthday?.year == null) {
                                        provider.updateCharacter(
                                          character.removeNullableValues(
                                            birthday: true,
                                          ),
                                        );
                                      } else {
                                        provider.updateCharacter(
                                          character.copyWith(
                                            birthday: Birthday(
                                              year: character.birthday?.year,
                                              month: null,
                                              day: character.birthday?.day,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      provider.updateCharacter(
                                        character.copyWith(
                                          birthday: Birthday(
                                            year: character.birthday?.year,
                                            month: value,
                                            day: character.birthday?.day,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  title: 'calendar.month'.tr(),
                                  labels: {
                                    null: 'character.unset'.tr(),
                                    ...List.generate(
                                      12,
                                      (index) => MapEntry(
                                        index + 1,
                                        'calendar.months.${index + 1}'.tr(),
                                      ),
                                    ).asMap().map(
                                      (key, value) {
                                        return MapEntry(value.key, value.value);
                                      },
                                    ),
                                  },
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: WrtTextField(
                                  onEdit: (value) {
                                    if (value.isEmpty) {
                                      if (character.birthday?.day == null &&
                                          character.birthday?.month == null) {
                                        provider.updateCharacter(
                                          character.removeNullableValues(
                                            birthday: true,
                                          ),
                                        );
                                      } else {
                                        provider.updateCharacter(
                                          character.copyWith(
                                            birthday: Birthday(
                                              year: null,
                                              month: character.birthday?.month,
                                              day: character.birthday?.day,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      provider.updateCharacter(
                                        character.copyWith(
                                          birthday: Birthday(
                                            year: int.tryParse(value),
                                            month: character.birthday?.month,
                                            day: character.birthday?.day,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  title: 'calendar.year'.tr(),
                                  altText: 'character.unset'.tr(),
                                  initialValue:
                                      character.birthday?.year?.toString(),
                                  number: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 55.0,
                          child: Row(children: [
                            Text(
                              'character.extra_fields.bloodtype'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: WrtTextField(
                                initialValue: character.bloodType,
                                altText: 'character.unset'.tr(),
                                title: 'character.extra_fields.bloodtype'.tr(),
                                onEdit: (value) {
                                  if (value.isEmpty) {
                                    provider.updateCharacter(
                                      character.removeNullableValues(
                                        bloodType: true,
                                      ),
                                    );
                                  } else {
                                    provider.updateCharacter(
                                      character.copyWith(
                                        bloodType: value,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 55.0,
                          child: Row(children: [
                            Text(
                              'character.extra_fields.email_address'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: WrtTextField(
                                altText: 'character.unset'.tr(),
                                initialValue: character.emailAddress,
                                title:
                                    'character.extra_fields.email_address'.tr(),
                                onEdit: (value) {
                                  if (value.isEmpty) {
                                    provider.updateCharacter(
                                      character.removeNullableValues(
                                        emailAddress: true,
                                      ),
                                    );
                                  } else {
                                    provider.updateCharacter(
                                      character.copyWith(
                                        emailAddress: value,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 55.0,
                          child: Row(children: [
                            Text(
                              'character.extra_fields.phone_number'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: WrtTextField(
                                altText: 'character.unset'.tr(),
                                title:
                                    'character.extra_fields.phone_number'.tr(),
                                initialValue: character.phoneNumber,
                                onEdit: (value) {
                                  if (value.isEmpty) {
                                    provider.updateCharacter(
                                      character.removeNullableValues(
                                        phoneNumber: true,
                                      ),
                                    );
                                  } else {
                                    provider.updateCharacter(
                                      character.copyWith(
                                        phoneNumber: value,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 55.0,
                          child: Row(children: [
                            Text(
                              'character.extra_fields.social_number'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: WrtTextField(
                                altText: 'character.unset'.tr(),
                                title:
                                    'character.extra_fields.social_number'.tr(),
                                initialValue: character.socialNumber,
                                onEdit: (value) {
                                  if (value.isEmpty) {
                                    provider.updateCharacter(
                                      character.removeNullableValues(
                                        socialNumber: true,
                                      ),
                                    );
                                  } else {
                                    provider.updateCharacter(
                                      character.copyWith(
                                        socialNumber: value,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 55.0,
                          child: Row(
                            children: [
                              Text(
                                'character.extra_fields.height'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: WrtTextField(
                                  altText: 'character.unset'.tr(),
                                  title: 'character.extra_fields.height'.tr(),
                                  initialValue: character.height == null
                                      ? null
                                      : '${character.height}',
                                  number: true,
                                  onEdit: (value) {
                                    if (value.isEmpty) {
                                      provider.updateCharacter(
                                        character.removeNullableValues(
                                          height: true,
                                        ),
                                      );
                                    } else {
                                      provider.updateCharacter(
                                        character.copyWith(
                                          height: int.tryParse(value),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 55.0,
                          child: Row(
                            children: [
                              Text(
                                'character.extra_fields.weight'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: WrtTextField(
                                  altText: 'character.unset'.tr(),
                                  title: 'character.extra_fields.weight'.tr(),
                                  initialValue: character.weight == null
                                      ? null
                                      : '${character.weight}',
                                  number: true,
                                  onEdit: (value) {
                                    if (value.isEmpty) {
                                      provider.updateCharacter(
                                        character.removeNullableValues(
                                          weight: true,
                                        ),
                                      );
                                    } else {
                                      provider.updateCharacter(
                                        character.copyWith(
                                          weight: int.tryParse(value),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 5.0),
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
                          padding:
                              const EdgeInsets.only(left: 5.0, bottom: 4.0),
                          child: Text(
                            'character.aliases'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        ...List.generate(
                          character.aliases.length,
                          (index) {
                            final e = character.aliases[index];
                            return SizedBox(
                              height: 25.0,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: WrtTextField(
                                      onEdit: (val) {
                                        final aliasesCopy = [
                                          ...character.aliases
                                        ];
                                        aliasesCopy.removeAt(index);
                                        aliasesCopy.insert(index, val);
                                        provider.updateCharacter(
                                          character.copyWith(
                                            aliases: aliasesCopy,
                                          ),
                                        );
                                      },
                                      onSubmit: (val) {
                                        final aliasesCopy = [
                                          ...character.aliases
                                        ];
                                        aliasesCopy.removeAt(index);
                                        aliasesCopy.insert(index, val);
                                        aliasesCopy.insert(
                                          index + 1,
                                          'character.new_alias'.tr(),
                                        );
                                        provider.updateCharacter(
                                          character.copyWith(
                                            aliases: aliasesCopy,
                                          ),
                                        );
                                      },
                                      borderless: true,
                                      initialValue: e,
                                      selectAllOnFocus: true,
                                      selectNextAfterSubmit: true,
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      canRequestFocus: false,
                                      onTap: () {
                                        final aliasesCopy = [
                                          ...character.aliases
                                        ];
                                        aliasesCopy.removeAt(index);
                                        provider.updateCharacter(
                                          character.copyWith(
                                            aliases: aliasesCopy,
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
                        Container(
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              canRequestFocus: false,
                              onTap: () {
                                provider.updateCharacter(
                                  character.copyWith(
                                    aliases: [
                                      ...character.aliases,
                                      'character.new_alias'.tr(),
                                    ],
                                  ),
                                );
                              },
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 10.0,
                                ),
                                child: Text(
                                  'character.add_new_alias'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, bottom: 4.0),
                                child: Text(
                                  'character.family_members'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            _buildErrorBadge(errors, 'family_members'),
                          ],
                        ),
                        ...List.generate(
                          character.familyMembers.length,
                          (index) {
                            final e = character.familyMembers[index];
                            return SizedBox(
                              height: 55.0,
                              child: FamilyMemberTile(
                                characterId: character.id,
                                unverified: false,
                                otherMembers: character.familyMembers,
                                data: e,
                              ),
                            );
                          },
                        ),
                        _AddFamilyMemberButton(
                          character.id,
                          character.familyMembers,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
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
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  'character.friends'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ...List.generate(
                                character.friends.length,
                                (index) {
                                  final e = character.friends[index];
                                  return Container(
                                    height: 45.0,
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  e.name,
                                                  style: theme
                                                      .textTheme.titleMedium,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ),
                                              const SizedBox(height: 3.0),
                                              if (e.sideChange != null)
                                                Expanded(
                                                  child: Text(
                                                    e.sideChange ==
                                                            SideChange.toEnemy
                                                        ? 'character.former_friend'
                                                            .tr()
                                                        : 'character.former_enemy'
                                                            .tr(),
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                    maxLines: 1,
                                                    softWrap: false,
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              final friendsCopy = [
                                                ...character.friends
                                              ];
                                              friendsCopy.removeAt(index);
                                              provider.updateCharacter(
                                                character.copyWith(
                                                  friends: friendsCopy,
                                                ),
                                              );
                                            },
                                            highlightColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            child: const Padding(
                                              padding: EdgeInsets.all(2.0),
                                              child: Icon(
                                                Icons.delete_outlined,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8.0),
                              Container(
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      final person =
                                          await showDialog<AffiliatedPerson?>(
                                        context: context,
                                        builder: (context) {
                                          return AddFriendOrEnemyWindow(
                                            friend: true,
                                            character: character,
                                          );
                                        },
                                      );

                                      if (person != null) {
                                        provider.updateCharacter(
                                          character.copyWith(
                                            friends: [
                                              ...character.friends,
                                              person,
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 10.0,
                                      ),
                                      child: Text(
                                        'character.add_friend'.tr(),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Container(
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
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  'character.enemies'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              ...List.generate(
                                character.enemies.length,
                                (index) {
                                  final e = character.enemies[index];
                                  return Container(
                                    height: 45.0,
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                e.name,
                                                style:
                                                    theme.textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 3.0),
                                              if (e.sideChange != null)
                                                Text(
                                                  e.sideChange ==
                                                          SideChange.toEnemy
                                                      ? 'character.former_friend'
                                                          .tr()
                                                      : 'character.former_enemy'
                                                          .tr(),
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              final enemeisCopy = [
                                                ...character.enemies
                                              ];
                                              enemeisCopy.removeAt(index);
                                              provider.updateCharacter(
                                                character.copyWith(
                                                  enemies: enemeisCopy,
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
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8.0),
                              Container(
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      final person =
                                          await showDialog<AffiliatedPerson?>(
                                        context: context,
                                        builder: (context) {
                                          return AddFriendOrEnemyWindow(
                                            friend: false,
                                            character: character,
                                          );
                                        },
                                      );

                                      if (person != null) {
                                        provider.updateCharacter(
                                          character.copyWith(
                                            enemies: [
                                              ...character.enemies,
                                              person,
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 10.0,
                                      ),
                                      child: Text(
                                        'character.add_enemy'.tr(),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8.0),
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
                          padding:
                              const EdgeInsets.only(left: 5.0, bottom: 4.0),
                          child: Text(
                            'character.development_plan'.tr(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        ...List.generate(
                          character.storyPlan.length,
                          (index) {
                            final e = character.storyPlan[index];
                            return Row(
                              children: [
                                Container(
                                  width: 15.0,
                                  height: 15.0,
                                  margin: const EdgeInsets.only(
                                    right: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF5D5D5D),
                                      width: 2.0,
                                    ),
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 35.0,
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      bottom: 4.0,
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: 4.0,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF242424),
                                      border: Border.all(
                                        color: const Color(0xFF5D5D5D),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: WrtTextField(
                                      onEdit: (val) {
                                        final storyPlanCopy = [
                                          ...character.storyPlan,
                                        ];
                                        final entry = storyPlanCopy.removeAt(
                                          index,
                                        );
                                        storyPlanCopy.insert(
                                          index,
                                          StoryPlanEntry(
                                            content: val,
                                            index: index,
                                            momentId: entry.momentId,
                                          ),
                                        );
                                        provider.updateCharacter(
                                          character.copyWith(
                                            storyPlan: storyPlanCopy,
                                          ),
                                        );
                                      },
                                      onSubmit: (value) {
                                        if (index ==
                                            character.storyPlan.length - 1) {
                                          final storyPlanCopy = [
                                            ...character.storyPlan,
                                          ];
                                          final entry = storyPlanCopy.removeAt(
                                            index,
                                          );
                                          storyPlanCopy.insert(
                                            index,
                                            StoryPlanEntry(
                                              content: value,
                                              index: index,
                                              momentId: entry.momentId,
                                            ),
                                          );
                                          storyPlanCopy.add(
                                            StoryPlanEntry(
                                              index: character.storyPlan.length,
                                              content:
                                                  'character.unnamed_bullet_point'
                                                      .tr(),
                                              momentId: null,
                                            ),
                                          );
                                          provider.updateCharacter(
                                            character.copyWith(
                                              storyPlan: storyPlanCopy,
                                            ),
                                          );
                                        }
                                      },
                                      borderless: true,
                                      nopadding: true,
                                      initialValue: e.content,
                                      selectAllOnFocus: true,
                                      selectNextAfterSubmit: true,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    canRequestFocus: false,
                                    onTap: () {
                                      final planCopy = [
                                        ...character.storyPlan,
                                      ];
                                      planCopy.removeAt(index);
                                      provider.updateCharacter(
                                        character.copyWith(
                                          storyPlan: planCopy,
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
                            );
                          },
                        ),
                        Container(
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
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                provider.updateCharacter(
                                  character.copyWith(
                                    storyPlan: [
                                      ...character.storyPlan,
                                      StoryPlanEntry(
                                        index: character.storyPlan.length,
                                        content:
                                            'character.unnamed_bullet_point'
                                                .tr(),
                                        momentId: null,
                                      ),
                                    ],
                                  ),
                                );
                              },
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 10.0,
                                ),
                                child: Text(
                                  'character.new_bullet_point'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  /// RIGHT PANEL DISPALYED HERE ONLY FOR SMALL SCREENS
                  if (provider.smallScreenView)
                    Column(
                      children: [
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          height: 200.0,
                          child: WrtTextField(
                            title: 'character.description'.tr(),
                            altText: 'character.click_to_start_typing'.tr(),
                            key: const Key('description_editor'),
                            onEdit: (val) {
                              provider.updateCharacter(character.copyWith(
                                description: val,
                              ));
                            },
                            minLines: 1,
                            maxLines: 20,
                            initialValue: character.description,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          height: 200.0,
                          child: WrtTextField(
                            title: 'character.apperance'.tr(),
                            altText: 'character.click_to_start_typing'.tr(),
                            key: const Key('apperance_editor'),
                            onEdit: (val) {
                              provider.updateCharacter(character.copyWith(
                                apperance: val,
                              ));
                            },
                            minLines: 1,
                            maxLines: 20,
                            initialValue: character.apperance,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          height: 200.0,
                          child: WrtTextField(
                            title: 'character.goals'.tr(),
                            altText: 'character.click_to_start_typing'.tr(),
                            key: const Key('description_goals'),
                            onEdit: (val) {
                              provider.updateCharacter(character.copyWith(
                                goals: val,
                              ));
                            },
                            minLines: 1,
                            maxLines: 20,
                            initialValue: character.goals,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            if (!provider.smallScreenView)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: WrtTextField(
                        title: 'character.description'.tr(),
                        altText: 'character.click_to_start_typing'.tr(),
                        key: const Key('description_editor'),
                        onEdit: (val) {
                          provider.updateCharacter(character.copyWith(
                            description: val,
                          ));
                        },
                        minLines: 1,
                        maxLines: 20,
                        initialValue: character.description,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: WrtTextField(
                        title: 'character.apperance'.tr(),
                        altText: 'character.click_to_start_typing'.tr(),
                        key: const Key('apperance_editor'),
                        onEdit: (val) {
                          provider.updateCharacter(character.copyWith(
                            apperance: val,
                          ));
                        },
                        minLines: 1,
                        maxLines: 20,
                        initialValue: character.apperance,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: WrtTextField(
                        title: 'character.goals'.tr(),
                        altText: 'character.click_to_start_typing'.tr(),
                        key: const Key('description_goals'),
                        onEdit: (val) {
                          provider.updateCharacter(character.copyWith(
                            goals: val,
                          ));
                        },
                        minLines: 1,
                        maxLines: 20,
                        initialValue: character.goals,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Builder _buildErrorBadge(List<ProjectError> errors, String key) {
    final theme = Theme.of(context);
    return Builder(
      builder: (context) {
        final errorsOfType = errors.where((element) {
          return element.elementId == key;
        }).toList();
        if (errorsOfType.isEmpty) return Container();
        return HoverBox(
          showOnTheLeft: true,
          size: Size(
            300.0,
            (60.0 * errorsOfType.length > 200
                ? 200.0
                : 60.0 * errorsOfType.length),
          ),
          content: ListView(
            children: errorsOfType.map((e) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.contentKey.tr() +
                          (e.errorWord == null ? '' : ': ${e.errorWord!.tr()}'),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 20.0,
                color: Colors.red,
              ),
              const SizedBox(width: 2.0),
              Text(
                errorsOfType.length.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddFamilyMemberButton extends StatefulWidget {
  const _AddFamilyMemberButton(this.id, this.allMembers);

  final List<AffiliatedPerson> allMembers;
  final String id;

  @override
  State<_AddFamilyMemberButton> createState() => _AddFamilyMemberButtonState();
}

class _AddFamilyMemberButtonState extends State<_AddFamilyMemberButton> {
  bool _isInEditMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  'character.add_new_family_member'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
          if (_isInEditMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FamilyMemberTile(
                characterId: widget.id,
                unverified: true,
                otherMembers: widget.allMembers,
                afterDone: () {
                  setState(() {
                    _isInEditMode = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
