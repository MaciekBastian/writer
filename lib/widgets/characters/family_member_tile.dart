import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_state.dart';
import '../dropdown_select.dart';

import '../../models/characters/affiliated_person.dart';

class FamilyMemberTile extends StatefulWidget {
  const FamilyMemberTile({
    super.key,
    required this.characterId,
    this.data,
    required this.unverified,
    required this.otherMembers,
    this.afterDone,
  });

  final String characterId;
  final AffiliatedPerson? data;
  final bool unverified;
  final List<AffiliatedPerson> otherMembers;
  final void Function()? afterDone;

  @override
  State<FamilyMemberTile> createState() => _FamilyMemberTileState();
}

class _FamilyMemberTileState extends State<FamilyMemberTile> {
  String? _characterId;
  String? _characterName;
  Kinship? _kinship;

  @override
  Widget build(BuildContext context) {
    final providerFunctions = Provider.of<ProjectState>(context, listen: false);
    final theme = Theme.of(context);

    if (!widget.unverified && widget.data != null) {
      return Container(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data!.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    'character.kinship_values.${widget.data!.kinship!.name}'
                        .tr(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontStyle: FontStyle.italic),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final character = providerFunctions.getCharacter(
                    widget.characterId,
                  );
                  final familyMembersCopy = [...widget.otherMembers];
                  familyMembersCopy.removeWhere((element) {
                    return element.id == widget.data!.id;
                  });
                  providerFunctions.updateCharacter(
                    character.copyWith(
                      familyMembers: familyMembersCopy,
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
    }

    final provider = Provider.of<ProjectState>(context);
    final allCharacters = provider.characters;
    final availableCharacters = allCharacters.entries.where(
      (element) {
        return !([...widget.otherMembers, widget.characterId].contains(
          element.key,
        ));
      },
    ).toList();

    if (availableCharacters.isEmpty) return Container();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 55.0,
                child: WrtDropdownSelect(
                  title: 'character.pick_character'.tr(),
                  initiallySelected: availableCharacters.first.key,
                  onSelected: (value) {
                    setState(() {
                      _characterId = value;
                      _characterName = allCharacters[value];
                    });
                  },
                  values: availableCharacters.map((e) => e.key).toList(),
                  labels: availableCharacters
                      .asMap()
                      .map((key, value) => MapEntry(value.key, value.value)),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: SizedBox(
                height: 55.0,
                child: WrtDropdownSelect(
                  title: 'character.kinship'.tr(),
                  initiallySelected: Kinship.values.first,
                  onSelected: (value) {
                    setState(() {
                      _kinship = value;
                    });
                  },
                  labels: Kinship.values.asMap().map((key, value) {
                    return MapEntry(
                      value,
                      'character.kinship_values.${value.name}'.tr(),
                    );
                  }),
                  values: Kinship.values,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 35.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: theme.colorScheme.primary,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_characterId == null ||
                        _characterName == null ||
                        _kinship == null) {
                      if (_characterId == null || _characterName == null) {
                        _characterId = availableCharacters.first.key;
                        _characterName = availableCharacters.first.value;
                      } else {
                        _kinship = Kinship.values.first;
                      }
                    }
                    final character = provider.getCharacter(widget.characterId);
                    final familyMembersCopy = [...character.familyMembers];
                    familyMembersCopy.add(
                      AffiliatedPerson.familyMember(
                        id: _characterId!,
                        name: _characterName!,
                        kinship: _kinship,
                      ),
                    );
                    providerFunctions.updateCharacter(
                      character.copyWith(
                        familyMembers: familyMembersCopy,
                      ),
                    );
                    if (widget.afterDone != null) {
                      widget.afterDone!();
                    }
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
                        'character.add'.tr(),
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
    );
  }
}
