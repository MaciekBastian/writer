import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/characters/character.dart';
import '../../widgets/button.dart';

import '../../helpers/report_helper.dart';
import '../../providers/project_state.dart';

class CharactersReport extends StatefulWidget {
  const CharactersReport({super.key});

  @override
  State<CharactersReport> createState() => _CharactersReportState();
}

class _CharactersReportState extends State<CharactersReport> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    if (_selectedId == null) {
      return ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          Text(
            'reports.characters_report'.tr(),
            style: theme.textTheme.headlineMedium,
          ),
          const Divider(
            color: Colors.grey,
            height: 20.0,
            thickness: 1.0,
            endIndent: 150.0,
          ),
          Text(
            '${'reports.select_character'.tr()}:',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 5.0),
              Container(
                width: 2.0,
                height: provider.characters.length * 40.0,
                color: Colors.grey,
              ),
              const SizedBox(width: 5.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...provider.characters.entries.map((e) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedId = e.key;
                          });
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(6.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(children: [
                            const Icon(
                              Icons.person_outline,
                              size: 20.0,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              e.value,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ]),
                        ),
                      ),
                    );
                  }),
                ],
              )
            ],
          ),
        ],
      );
    }

    final tree = ReportHelper().getFamilyTreeForCharacter(
      provider.project!,
      _selectedId!,
    );

    return FutureBuilder<Character?>(
      future: provider.getUpToDateCharacterWithoutOpening(_selectedId!),
      builder: (context, snapshot) {
        if (snapshot.data == null) return Container();
        final character = snapshot.data!;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5.0),
              color: const Color(0xFF191919),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  WrtButton(
                    callback: () {
                      // ReportHelper().characterReport(provider.project!);
                    },
                    label: 'reports.download'.tr(),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: [
                  Text(
                    character.name,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'character.description'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: WrtTheme.productBlueLight,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              character.description.trim().isEmpty
                                  ? '--'
                                  : character.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 15.0),
                            Text(
                              'character.apperance'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: WrtTheme.productBlueLight,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              character.apperance.trim().isEmpty
                                  ? '--'
                                  : character.apperance,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 15.0),
                            Text(
                              'character.goals'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: WrtTheme.productBlueLight,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              character.goals.trim().isEmpty
                                  ? '--'
                                  : character.goals,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                        width: 280.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                        ),
                        child: Column(
                          children: [
                            _tile(
                              'character.age'.tr(),
                              '${character.age ?? 'character.unset'.tr()}',
                              context,
                            ),
                            _tile(
                              'character.status'.tr(),
                              'character.${character.status == CharacterStatus.alive ? 'alive' : character.status == CharacterStatus.dead ? 'dead' : 'status_unknown'}'
                                  .tr(),
                              context,
                            ),
                            _tile(
                              'character.gender'.tr(),
                              'character.${character.gender == Gender.male ? 'male' : character.gender == Gender.female ? 'female' : character.gender == Gender.other ? 'gender_other' : 'gender_unknown'}'
                                  .tr(),
                              context,
                            ),
                            _tile(
                              'character.portrayed_by'.tr(),
                              character.portrayedBy ?? 'character.unset'.tr(),
                              context,
                            ),
                            _tile(
                              'character.aliases'.tr(),
                              character.aliases.isEmpty
                                  ? 'character.none'.tr()
                                  : character.aliases.join(',\n'),
                              context,
                            ),
                            _tile(
                              'character.family_members'.tr(),
                              character.familyMembers.isEmpty
                                  ? 'character.none'.tr()
                                  : character.familyMembers.map((e) {
                                      return '${e.name}\n(${'character.kinship_values.${e.kinship!.name}'.tr()})';
                                    }).join(',\n'),
                              context,
                            ),
                            _tile(
                              'character.friends'.tr(),
                              character.friends.isEmpty
                                  ? 'character.none'.tr()
                                  : character.friends.map((e) {
                                      return e.name;
                                    }).join(',\n'),
                              context,
                            ),
                            _tile(
                              'character.enemies'.tr(),
                              character.enemies.isEmpty
                                  ? 'character.none'.tr()
                                  : character.enemies.map((e) {
                                      return e.name;
                                    }).join(',\n'),
                              context,
                            ),
                            _tile(
                              'character.occupation_history'.tr(),
                              character.occupationHistory.isEmpty
                                  ? 'character.none'.tr()
                                  : character.occupationHistory.map((e) {
                                      return e.occupation;
                                    }).join(',\n'),
                              context,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // TODO: finish report
                ],
              ),
            ),
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
            width: 160.0,
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
