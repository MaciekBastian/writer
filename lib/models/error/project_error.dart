import '../file_tab.dart';

enum ProjectErrorType {
  characterNameDuplicate,
  characterKinshipConflict,
  characterKinshipSuggestion,
  threadNameDuplicate,
  threadCharacterDoesNotExist,
  threadOldCharacterName,
}

class ProjectError {
  final String errorId;
  final ProjectErrorType type;
  final String contentKey;
  final List<FileType> whereTypes;
  final List<String>? whereIds;
  final String solution;
  final String? errorWord;
  final String? elementId;

  ProjectError({
    required this.errorId,
    required this.type,
    required this.contentKey,
    required this.solution,
    required this.whereTypes,
    this.whereIds,
    this.errorWord,
    this.elementId,
  });

  ProjectError.fromJson(Map<String, dynamic> input)
      : errorId = input['errorId'],
        contentKey = input['contentKey'],
        whereTypes = (input['whereType'] as List).map((e) {
          return FileType.values.firstWhere((el) {
            return el.name == e.toString();
          });
        }).toList(),
        whereIds = input['whereIds'] == null
            ? null
            : (input['whereIds'] as List).map((e) => e.toString()).toList(),
        solution = input['solution'],
        type = ProjectErrorType.values
            .firstWhere((el) => el.name == input['type']),
        errorWord = input['errorWord'],
        elementId = input['elementId'];

  Map<String, dynamic> toJson() => {
        'errorId': errorId,
        'contentKey': contentKey,
        'whereType': whereTypes.map((e) => e.name).toList(),
        'whereIds': whereIds,
        'solution': solution,
        'type': type.name,
        'errorWord': errorWord,
        'elementId': elementId,
      };
}
