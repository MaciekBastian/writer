import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart' as material;
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'general_helper.dart';

import '../models/chapters/chapter.dart';
import '../models/characters/affiliated_person.dart';
import '../models/characters/character.dart';
import '../models/characters/occupation.dart';
import '../models/project.dart';

class ReportHelper {
  Future<void> characterReport(Project project) async {
    final dir = Directory(project.path);
    if (!(dir.existsSync())) return;
    final reports = Directory(p.join(dir.path, 'reports.reports'.tr()));
    if (!(reports.existsSync())) await reports.create();
    final now = DateTime.now();
    final fileName = 'character_test';
    // '${'characters'.tr()}_${now.year}${now.month < 10 ? '0' : ''}${now.month}${now.day < 10 ? '0' : ''}${now.day}_${now.hour < 10 ? '0' : ''}${now.hour}${now.minute < 10 ? '0' : ''}${now.minute}${now.second < 10 ? '0' : ''}${now.second}';
    final file = File(p.join(reports.path, '$fileName.pdf'));

    final theme = ThemeData.withFont(
      base: await PdfGoogleFonts.robotoRegular(),
      bold: await PdfGoogleFonts.robotoBold(),
      italic: await PdfGoogleFonts.robotoItalic(),
    );
    final pdf = Document(
      author: project.author,
      creator: 'app_name'.tr(),
      producer: 'PDF by nfet.net, under APACHE-2.0, pub.dev',
      version: PdfVersion.pdf_1_5,
      title: 'reports.characters_report'.tr(),
      subject: '${'reports.characters_report'.tr()} ${project.name}',
      theme: theme,
    );

    final getCharactersPort = ReceivePort();
    await Isolate.spawn(_getAllCharacters, [
      getCharactersPort.sendPort,
      project.path,
    ]);
    final getCharactersResp = await getCharactersPort.first as List<String>?;
    final characters = (getCharactersResp ?? []).map(
      (e) {
        return Character.fromXml(Character.getCharacterTag(e));
      },
    ).toList();

    final getChaptersPort = ReceivePort();
    await Isolate.spawn(_getAllChapters, [
      getChaptersPort.sendPort,
      project.path,
    ]);
    final getChaptersResp = await getChaptersPort.first as List<String>?;
    final chapters = (getChaptersResp ?? []).map(
      (e) {
        return Chapter.fromXml(Chapter.getChapterTag(e));
      },
    ).toList();
    final scenes = GeneralHelper().getUnifiedList(
      chapters.map((e) => e.scenes).toList(),
    );

    /// header of every page
    final header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'reports.characters_report'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(inherit: true, fontSize: 9.0),
        ),
        Text(
          '${'reports.generated_on'.tr()}: ${'calendar.date_format_short'.tr(
            namedArgs: {
              'month': '${now.month < 10 ? '0' : ''}${now.month}',
              'day': '${now.day < 10 ? '0' : ''}${now.day}',
              'year': now.year.toString(),
            },
          )}${now.hour < 10 ? '0' : ''}, ${now.hour}:${now.minute < 10 ? '0' : ''}${now.minute}',
          textAlign: TextAlign.center,
          style: TextStyle(
            inherit: true,
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    Widget footer(int page) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            color: PdfColor.fromHex('#1638E2'),
          ),
          Text(
            'reports.characters_report'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              inherit: true,
              fontSize: 12.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          Text(
            '$page',
            textAlign: TextAlign.center,
            style: const TextStyle(inherit: true, fontSize: 12.0),
          ),
        ],
      );
    }

    Widget tile(String label, String content) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 5.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80.0,
              child: Text(
                label,
                style: TextStyle(
                  inherit: true,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(inherit: true, fontSize: 12.0),
              ),
            ),
          ],
        ),
      );
    }

    // title page
    pdf.addPage(
      Page(
        orientation: PageOrientation.portrait,
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        build: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              header,
              Center(
                child: Column(
                  children: [
                    Text(
                      'reports.characters_report'.tr(),
                      style: theme.header0,
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'app_name'.tr(),
                      style: theme.header5,
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'welcome.slogan'.tr(),
                      style: theme.header5.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              footer(1),
            ],
          );
        },
      ),
    );

    int page = 1;

    // character specific pages
    for (int i = 0; i < characters.length; i++) {
      // page increment
      page++;
      final character = characters[i];
      final linesOfText =
          '${character.description} ${character.apperance} ${character.goals}'
                  .length ~/
              50.0;
      final linesOfFriendsAndEnemies = [
            character.friends.length,
            character.enemies.length,
          ].reduce(max) *
          2;
      final linesOfFamily = character.familyMembers.length * 2 + 1;
      final occupationLines = character.occupationHistory.length + 2;
      final storyPlanLines = character.storyPlan.isEmpty
          ? 1
          : character.storyPlan
                  .map((e) => e.content.length ~/ 50)
                  .reduce((value, element) => value + element) +
              1;

      /// FRIENDS AND ENEMIES TABLE
      final friendsAndEnemies = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'character.friends'.tr(),
                  style: theme.paragraphStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9.0,
                    color: PdfColor.fromHex('#1638E2'),
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 3.0),
                ...character.friends.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: theme.paragraphStyle,
                        textAlign: TextAlign.justify,
                      ),
                      if (e.sideChange != null)
                        Text(
                          e.sideChange == SideChange.toEnemy
                              ? 'character.former_friend'.tr()
                              : 'character.former_enemy'.tr(),
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'character.enemies'.tr(),
                  style: theme.paragraphStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9.0,
                    color: PdfColor.fromHex('#1638E2'),
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 3.0),
                ...character.enemies.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: theme.paragraphStyle,
                        textAlign: TextAlign.justify,
                      ),
                      if (e.sideChange != null)
                        Text(
                          e.sideChange == SideChange.toEnemy
                              ? 'character.former_friend'.tr()
                              : 'character.former_enemy'.tr(),
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      );

      /// FAMILY MEMBERS TABLE
      final familyMembers = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.0),
          Text(
            'character.family_members'.tr(),
            style: theme.paragraphStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 9.0,
              color: PdfColor.fromHex('#1638E2'),
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 3.0),
          ...character.familyMembers.map((e) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: theme.paragraphStyle,
                  textAlign: TextAlign.justify,
                ),
                if (e.kinship != null)
                  Text(
                    'character.kinship_values.${e.kinship!.name}'.tr(),
                    style: TextStyle(
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
              ],
            );
          }).toList(),
        ],
      );

      String getSceneName(String id) {
        final key = scenes.map((e) => e.id).contains(id)
            ? id
            : [
                Occupation.before,
                Occupation.after,
                Occupation.unknown,
              ].contains(id)
                ? id
                : Occupation.unknown;
        final labels = {
          Occupation.before: 'character.before'.tr(),
          Occupation.after: 'character.after'.tr(),
          Occupation.unknown: 'character.start_or_end_unknown'.tr(),
          ...scenes.asMap().map((key, value) {
            final chapter = chapters.firstWhere((element) {
              return element.scenes.contains(value);
            });
            final name =
                '${(chapter.name.isNotEmpty) ? chapter.name : '${'character.chapter'.tr()} ${chapter.index + 1}'}: ${(value.name != null && (value.name?.isNotEmpty ?? false)) ? value.name : '${'character.scene'.tr()} ${value.index + 1}'}';
            return MapEntry(value.id, name);
          }),
        };

        return labels[key] ?? labels[Occupation.unknown]!;
      }

      final storyPlan = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.0),
          Text(
            'character.development_plan'.tr(),
            style: theme.paragraphStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 9.0,
              color: PdfColor.fromHex('#1638E2'),
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 3.0),
          ...character.storyPlan.map((e) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      margin: const EdgeInsets.only(top: 4.0),
                      decoration: const BoxDecoration(
                        color: PdfColors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Text(
                      e.content,
                      style: theme.paragraphStyle,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(height: 3.0),
              ],
            );
          }).toList(),
        ],
      );

      /// OCCUPATION HISTORY TABLE
      final occupationHistory = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.0),
          Text(
            'character.occupation_history'.tr(),
            style: theme.paragraphStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 9.0,
              color: PdfColor.fromHex('#1638E2'),
            ),
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 5.0),
          Table(
            border: TableBorder.all(
              color: PdfColors.grey,
              style: BorderStyle.dashed,
              width: 1.0,
            ),
            columnWidths: const {
              0: FixedColumnWidth(180.0),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            tableWidth: TableWidth.max,
            children: character.occupationHistory.map((e) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(e.occupation, style: theme.tableCell),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(getSceneName(e.start), style: theme.tableCell),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(getSceneName(e.end), style: theme.tableCell),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );

      /// BASIC DATA PAGE
      pdf.addPage(
        Page(
          orientation: PageOrientation.portrait,
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          build: (context) {
            return Column(
              children: [
                header,
                SizedBox(height: 20.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.header0.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(
                        color: PdfColor.fromHex('#1638E2'),
                        height: 4.0,
                        thickness: 2.0,
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'character.description'.tr(),
                                  style: theme.paragraphStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
                                    color: PdfColor.fromHex('#1638E2'),
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  character.description,
                                  style: theme.paragraphStyle,
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'character.apperance'.tr(),
                                  style: theme.paragraphStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
                                    color: PdfColor.fromHex('#1638E2'),
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  character.apperance,
                                  style: theme.paragraphStyle,
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'character.goals'.tr(),
                                  style: theme.paragraphStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
                                    color: PdfColor.fromHex('#1638E2'),
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  character.goals,
                                  style: theme.paragraphStyle,
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15.0),
                          Container(
                            width: 200.0,
                            padding: const EdgeInsets.all(10.0),
                            color: PdfColors.grey300,
                            child: Column(
                              children: [
                                tile(
                                  'character.age'.tr(),
                                  '${character.age ?? 'character.unset'.tr()}',
                                ),
                                tile(
                                  'character.status'.tr(),
                                  'character.${character.status == CharacterStatus.alive ? 'alive' : character.status == CharacterStatus.dead ? 'dead' : 'status_unknown'}'
                                      .tr(),
                                ),
                                tile(
                                  'character.gender'.tr(),
                                  'character.${character.gender == Gender.male ? 'male' : character.gender == Gender.female ? 'female' : character.gender == Gender.other ? 'gender_other' : 'gender_unknown'}'
                                      .tr(),
                                ),
                                tile(
                                  'character.portrayed_by'.tr(),
                                  character.portrayedBy ??
                                      'character.unset'.tr(),
                                ),
                                tile(
                                  'character.aliases'.tr(),
                                  character.aliases.isEmpty
                                      ? 'character.none'.tr()
                                      : character.aliases.join(',\n'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      if (linesOfText + linesOfFriendsAndEnemies <= 35)
                        friendsAndEnemies,
                      if (linesOfText +
                              linesOfFriendsAndEnemies +
                              linesOfFamily <=
                          35)
                        familyMembers,
                      if (linesOfText +
                              linesOfFriendsAndEnemies +
                              linesOfFamily +
                              occupationLines <=
                          35)
                        occupationHistory,
                      if (linesOfText +
                              linesOfFriendsAndEnemies +
                              linesOfFamily +
                              occupationLines +
                              storyPlanLines <=
                          35)
                        storyPlan,
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                footer(page),
              ],
            );
          },
        ),
      );

      if (linesOfText + linesOfFriendsAndEnemies > 35 ||
          linesOfText + linesOfFriendsAndEnemies + linesOfFamily > 35 ||
          linesOfText +
                  linesOfFriendsAndEnemies +
                  linesOfFamily +
                  occupationLines >
              35 ||
          linesOfText +
                  linesOfFriendsAndEnemies +
                  linesOfFamily +
                  occupationLines +
                  storyPlanLines >
              35) {
        page++;

        /// If something overflows, add it to a new page
        pdf.addPage(
          Page(
            orientation: PageOrientation.portrait,
            pageFormat: PdfPageFormat.a4,
            margin:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            build: (context) {
              return Column(
                children: [
                  header,
                  SizedBox(height: 20.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (linesOfText + linesOfFriendsAndEnemies > 35)
                          friendsAndEnemies,
                        SizedBox(height: 10.0),
                        if (linesOfText +
                                linesOfFriendsAndEnemies +
                                linesOfFamily >
                            35)
                          familyMembers,
                        if (linesOfText +
                                linesOfFriendsAndEnemies +
                                linesOfFamily +
                                occupationLines >
                            35)
                          occupationHistory,
                        if (linesOfText +
                                linesOfFriendsAndEnemies +
                                linesOfFamily +
                                occupationLines +
                                storyPlanLines >
                            35)
                          storyPlan,
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  footer(page),
                ],
              );
            },
          ),
        );
      }
    }

    // TODO: relationships (graph etc.)

    // save file
    await file.writeAsBytes(await pdf.save());
  }
}

Future<void> _getAllCharacters(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String path = args[1];

  final characters = Directory(p.join(path, 'characters'));
  List<String> output = [];
  if (characters.existsSync()) {
    final files = characters
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();

    for (var character in files) {
      final data = await character.readAsString();
      output.add(data);
    }
  }

  Isolate.exit(
    responsePort,
    output,
  );
}

Future<void> _getAllChapters(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String path = args[1];

  final chapters = Directory(p.join(path, 'chapters'));
  List<String> output = [];
  if (chapters.existsSync()) {
    final files = chapters
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();

    for (var chapter in files) {
      final data = await chapter.readAsString();
      output.add(data);
    }
  }

  Isolate.exit(
    responsePort,
    output,
  );
}
