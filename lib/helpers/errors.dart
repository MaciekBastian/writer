import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import '../models/threads/thread.dart';
import 'general_helper.dart';

import '../models/error/project_error.dart';
import '../models/file_tab.dart';
import '../models/project.dart';

import '../models/characters/character.dart';

class ErrorsHelper {
  Future<List<ProjectError>?> lookForErrors(Project project) async {
    final port = ReceivePort();
    await Isolate.spawn(_lookForErrors, [port.sendPort, project.path]);
    final response = await port.first as List<Map<String, dynamic>>?;

    if (response != null) {
      return response.map((e) => ProjectError.fromJson(e)).toList();
    }

    return null;
  }
}

void _lookForErrors(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String path = args[1];

  List<ProjectError> errors = [];
  final List<Thread> threads = [];
  final List<Character> characters = [];

  final characterDir = Directory(p.join(path, 'characters'));
  final threadsDir = Directory(p.join(path, 'threads'));
  if (characterDir.existsSync()) {
    final characterFiles =
        characterDir.listSync().whereType<File>().where((element) {
      return element.path.endsWith('.xml');
    }).toList();

    for (var file in characterFiles) {
      final rawData = await file.readAsString();
      final characterData = Character.fromXml(
        Character.getCharacterTag(rawData),
      );
      characters.add(characterData);
    }

    for (var character in characters) {
      final sameNames = characters.where((element) {
        return element.name.trim().toLowerCase() ==
            character.name.trim().toLowerCase();
      }).toList();

      final familyMembers = character.familyMembers;
      for (var familyMember in familyMembers) {
        final memberData = characters.firstWhere((element) {
          return element.id == familyMember.id;
        });
        if (memberData.familyMembers.any((element) {
          return element.id == character.id;
        })) {
          final suggestedKinship = GeneralHelper().getSuggestedKinship(
            kinship1: familyMember.kinship!,
            gender1: character.gender,
          );
          if (suggestedKinship != null) {
            final memberKinship =
                memberData.familyMembers.firstWhere((element) {
              return element.id == character.id;
            });
            if (suggestedKinship != memberKinship.kinship) {
              final ids = [character.id, memberData.id];
              ids.sort((a, b) => a.compareTo(b));
              const errorType = ProjectErrorType.characterKinshipConflict;
              final kinshipText =
                  '${memberData.name} (@:character.kinship_values.${memberKinship.kinship!.name}) - ${character.name} (@:character.kinship_values.${familyMember.kinship!.name}), @:errors.suggested_change: ${memberData.name} - ${character.name} (@:character.kinship_values.${suggestedKinship.name})';
              final errorId = '${errorType.name}_${ids.join('-')}';
              if (errors.every((element) => element.errorId != errorId)) {
                errors.add(
                  ProjectError(
                    errorId: errorId,
                    type: errorType,
                    contentKey: 'errors.kinship_conflict',
                    solution: 'errors.kinship_conflict_solution',
                    whereTypes:
                        ids.map((e) => FileType.characterEditor).toList(),
                    whereIds: ids,
                    errorWord: kinshipText,
                    elementId: 'family_members',
                  ),
                );
              }
            }
          }
        } else {
          final suggestedKinship = GeneralHelper().getSuggestedKinship(
            kinship1: familyMember.kinship!,
            gender1: character.gender,
          );
          if (suggestedKinship != null) {
            final ids = [character.id, memberData.id];
            ids.sort((a, b) => a.compareTo(b));
            const errorType = ProjectErrorType.characterKinshipSuggestion;
            final kinshipText =
                '${memberData.name} - ${character.name} (@:character.kinship_values.${suggestedKinship.name})';
            final errorId = '${errorType.name}_${ids.join('-')}';
            if (errors.every((element) => element.errorId != errorId)) {
              errors.add(
                ProjectError(
                  errorId: errorId,
                  type: errorType,
                  contentKey: 'errors.suggested_kinship',
                  solution: 'errors.suggested_kinship_solution',
                  whereTypes: [FileType.characterEditor],
                  whereIds: [memberData.id],
                  errorWord: kinshipText,
                  elementId: 'family_members',
                ),
              );
            }
          }
        }
      }

      if (sameNames.length > 1) {
        const errorType = ProjectErrorType.characterNameDuplicate;
        final errorId =
            '${errorType.name}_${sameNames.map((e) => e.id).join('-')}';
        if (errors.every((element) => element.errorId != errorId)) {
          errors.add(
            ProjectError(
              errorId: errorId,
              type: errorType,
              contentKey: 'errors.share_name',
              solution: 'errors.share_name_solution',
              whereTypes: sameNames.map((e) {
                return FileType.characterEditor;
              }).toList(),
              whereIds: sameNames.map((e) => e.id).toList(),
              errorWord: character.name,
              elementId: 'character_name',
            ),
          );
        }
      }
    }
  }

  if (threadsDir.existsSync()) {
    final threadFiles =
        threadsDir.listSync().whereType<File>().where((element) {
      return element.path.endsWith('.xml');
    }).toList();

    for (var file in threadFiles) {
      final rawData = await file.readAsString();
      final threadData = Thread.fromXml(
        Thread.getThreadTag(rawData),
      );
      threads.add(threadData);
    }

    for (var thread in threads) {
      final sameNames = threads.where((element) {
        return element.name.trim().toLowerCase() ==
            thread.name.trim().toLowerCase();
      }).toList();

      for (var character in thread.charactersInvolved.entries) {
        if (characters.any((element) => element.id == character.key)) {
          final data = characters.firstWhere((el) => el.id == character.key);
          if (data.name != character.value) {
            const errorType = ProjectErrorType.threadOldCharacterName;
            final errorId = '${errorType.name}_${thread.id}_${character.key}';
            if (errors.every((element) => element.errorId != errorId)) {
              errors.add(
                ProjectError(
                  errorId: errorId,
                  type: errorType,
                  contentKey: 'errors.thread_character_old_name',
                  solution: 'errors.thread_character_old_name_solution',
                  whereTypes: [FileType.threadEditor],
                  whereIds: [thread.id],
                  errorWord:
                      '${thread.name}: ${character.value} @:errors.changed_to ${data.name}',
                ),
              );
            }
          }
          continue;
        }
        const errorType = ProjectErrorType.threadCharacterDoesNotExist;
        final errorId = '${errorType.name}_${thread.id}_${character.key}';
        if (errors.every((element) => element.errorId != errorId)) {
          errors.add(
            ProjectError(
              errorId: errorId,
              type: errorType,
              contentKey: 'errors.thread_character_does_not_exist',
              solution: 'errors.thread_character_does_not_exist_solution',
              whereTypes: [FileType.threadEditor],
              whereIds: [thread.id],
              errorWord: character.value,
            ),
          );
        }
      }

      if (sameNames.length > 1) {
        const errorType = ProjectErrorType.threadNameDuplicate;
        final errorId =
            '${errorType.name}_${sameNames.map((e) => e.id).join('-')}';
        if (errors.every((element) => element.errorId != errorId)) {
          errors.add(
            ProjectError(
              errorId: errorId,
              type: errorType,
              contentKey: 'errors.share_name_threads',
              solution: 'errors.share_name_threads_solution',
              whereTypes: sameNames.map((e) {
                return FileType.threadEditor;
              }).toList(),
              whereIds: sameNames.map((e) => e.id).toList(),
              errorWord: thread.name,
            ),
          );
        }
      }
    }
  }

  final resultJson = errors.map((e) => e.toJson()).toList();

  Isolate.exit(responsePort, resultJson);
}
