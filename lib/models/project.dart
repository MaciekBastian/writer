import 'language.dart';

class Project {
  final String id;
  final String name;
  final String path;
  final ProjectLanguage language;
  final DateTime creationDate;
  final String? author;

  Project({
    required this.id,
    required this.name,
    required this.path,
    required this.creationDate,
    this.language = ProjectLanguage.en,
    this.author,
  });

  Project.fromJson(Map<String, dynamic> input)
      : id = input['id'],
        name = input['name'],
        path = input['path'],
        creationDate = DateTime.parse(input['creation_date']),
        language = ProjectLanguage.values.firstWhere((element) {
          return element.name == input['language'];
        }),
        author = input['author'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'creation_date': creationDate.toIso8601String(),
        'language': language.name,
        'author': author,
      };

  Project copyWith({
    String? name,
    ProjectLanguage? language,
    String? author,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      path: path,
      language: language ?? this.language,
      creationDate: creationDate,
      author: author ?? this.author,
    );
  }
}
