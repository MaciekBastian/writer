import '../chapters/chapter.dart';
import '../characters/character.dart';
import '../project.dart';
import '../threads/thread.dart';

class Version {
  /// 8-characters-long code identifing this version.
  final String code;

  /// user-generated message, possibly description or title of this version
  final String? message;

  /// when version was exported
  final DateTime timestamp;

  /// code of previous version. To create branch, just pass the same version as previous.
  ///
  /// Null means this is initial commit
  final String? previous;

  /// path to this version file
  final String path;

  final bool commited;

  /// size in bytes
  final int size;

  Version({
    required this.code,
    required this.timestamp,
    required this.path,
    required this.commited,
    this.previous,
    this.message,
    this.size = 0,
  });

  Version.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        timestamp = DateTime.parse(json['timestamp']),
        path = json['path'],
        previous = json['previous'],
        commited = json['commited'],
        message = json['message'],
        size = json['size'];

  Map<String, dynamic> toJson() => {
        'code': code,
        'timestamp': timestamp.toIso8601String(),
        'path': path,
        'previous': previous,
        'message': message,
        'commited': commited,
        'size': size,
      };
}

class VersionFile extends Version {
  List<Character> characters;
  List<Thread> threads;
  List<Chapter> chapters;
  List<List<String>> contents;
  Project config;

  VersionFile({
    required this.config,
    required String code,
    required DateTime timestamp,
    required String path,
    required bool commited,
    String? previous,
    String? message,
    int size = 0,
    this.characters = const [],
    this.threads = const [],
    this.chapters = const [],
    this.contents = const [],
  }) : super(
          code: code,
          commited: commited,
          path: path,
          timestamp: timestamp,
          message: message,
          previous: previous,
          size: size,
        );
}
