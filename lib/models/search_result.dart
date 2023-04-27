import 'file_tab.dart';

class SearchResult {
  final FileType type;
  final String? id;
  final String? path;
  final List<String> matches;

  SearchResult({
    required this.type,
    required this.matches,
    this.id,
    this.path,
  });

  SearchResult.fromJson(Map<String, dynamic> input)
      : type = FileType.values.firstWhere((el) => el.name == input['type']),
        id = input['id'],
        path = input['path'],
        matches = input['matches'];

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'id': id,
        'path': path,
        'matches': matches,
      };

  static FileType _getType(String filePath) {
    final segments = Uri.parse(filePath).pathSegments;
    if (segments.contains('characters')) return FileType.characterEditor;
    if (segments.contains('threads')) return FileType.threadEditor;
    if (segments.contains('chapters')) return FileType.timelineEditor;
    return FileType.userFile;
  }

  static String _getId(String filePath) {
    final segments = Uri.parse(filePath).pathSegments.reversed.toList();
    final fileName = segments.firstWhere((element) => element.endsWith('.xml'));
    return fileName
        .substring(0, fileName.lastIndexOf('.'))
        .replaceAll('/', '')
        .replaceAll('\\', '');
  }

  SearchResult.fromFilePath(String filePath)
      : type = _getType(filePath),
        id = _getId(filePath),
        matches = [],
        path = filePath;
}
