import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import '../models/characters/character.dart';
import '../models/threads/thread.dart';
import 'package:xml/xml.dart';

import '../models/chapters/chapter.dart';
import '../models/language.dart';
import '../models/project.dart';
import '../models/version/version.dart';

class VersionHelper {
  Future<List<Version>> getAllVersions(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) return [];
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) return [];
    final allVersions = File(
      p.join(versionDirectory.path, 'all_versions.json'),
    );
    if (!(allVersions.existsSync())) return [];
    final data = json.decode(await allVersions.readAsString()) as List;
    final versions = data.map(
      (e) {
        return Version.fromJson(
          (e as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      },
    ).toList();

    return versions;
  }

  /// returns all versions with new added on the bottom
  Future<List<Version>> _register(Project project, Version version) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) versionDirectory.createSync();
    final allVersions = File(
      p.join(versionDirectory.path, 'all_versions.json'),
    );
    if (!(allVersions.existsSync())) {
      allVersions.createSync();
      allVersions.writeAsStringSync('[]');
    }
    final data = json.decode(await allVersions.readAsString()) as List;
    final versions = data.map(
      (e) {
        return Version.fromJson(
          (e as Map).map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        );
      },
    ).toList();
    if (versions.any((element) => element.code == version.code)) {
      versions.removeWhere((element) => element.code == version.code);
    }
    versions.add(version);
    await allVersions.writeAsString(
      json.encode(
        versions.map((e) => e.toJson()).toList(),
      ),
    );

    return versions;
  }

  Future<void> updateCurrent(Project project, Version version) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) versionDirectory.createSync();
    final current = File(
      p.join(versionDirectory.path, 'current.json'),
    );
    if (!(current.existsSync())) current.createSync();
    await current.writeAsString(json.encode(version.toJson()));
  }

  Future<Version?> getCurrentVersion(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) return null;
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) return null;
    final current = File(
      p.join(versionDirectory.path, 'current.json'),
    );
    if (!(current.existsSync())) return null;
    final data = json.decode(await current.readAsString()) as Map;
    return Version.fromJson(
      data.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Future<String> getDefaultPath(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) versionDirectory.createSync();
    return versionDirectory.path;
  }

  Future<Version?> addVersion(Project project, Version version) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) versionDirectory.createSync();
    final versionFile = File(version.path);
    if (!(versionFile.existsSync())) versionFile.createSync();

    final port = ReceivePort();
    await Isolate.spawn(_writeToVersion, [
      port.sendPort,
      versionFile.path,
      project.path,
      version.toJson(),
    ]);
    final response = await port.first as bool?;

    if (response != null) {
      if (response) {
        // successfully wrote to file
        final updatedVersion = Version(
          code: version.code,
          timestamp: DateTime.now(),
          path: version.path,
          commited: version.commited,
          message: version.message,
          previous: version.previous,
          size: versionFile.lengthSync(),
        );
        await _register(project, updatedVersion);
        await updateCurrent(project, updatedVersion);
        return updatedVersion;
      }
    }
    return null;
  }

  Future<Version?> commitVersion(Project project, Version version) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) versionDirectory.createSync();
    final versionFile = File(version.path);
    if (!(versionFile.existsSync())) versionFile.createSync();

    final port = ReceivePort();
    await Isolate.spawn(_writeToVersion, [
      port.sendPort,
      versionFile.path,
      project.path,
      version.toJson(),
    ]);
    final response = await port.first as bool?;

    if (response != null) {
      if (response) {
        // successfully wrote to file
        final updatedVersion = Version(
          code: version.code,
          timestamp: DateTime.now(),
          path: version.path,
          commited: true,
          message: version.message,
          previous: version.previous,
          size: versionFile.lengthSync(),
        );
        await _register(project, updatedVersion);
        await updateCurrent(project, updatedVersion);
        return updatedVersion;
      }
    }
    return null;
  }

  Future<bool> isCheckoutSafe(String project, DateTime lastCommit) async {
    final directory = Directory(project);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final config = File(p.join(project, 'config.mwrt'));
    final characters = Directory(p.join(project, 'characters'));
    final threads = Directory(p.join(project, 'threads'));
    final chapters = Directory(p.join(project, 'chapters'));
    final content = Directory(p.join(project, 'content'));
    final data = [config, characters, threads, chapters, content];

    DateTime? lastModification;

    for (var systemEntity in data) {
      final modified = systemEntity.statSync().modified;
      if (lastModification?.isBefore(modified) ?? true) {
        lastModification = modified;
      }
    }
    if (lastModification == null) return false;
    return lastCommit.isAfter(lastModification);
  }

  Future<VersionFile?> readVersion(Version version) async {
    final file = File(version.path);
    if (!file.existsSync()) return null;

    final xml = XmlDocument.parse(await file.readAsString());
    final tree = xml.rootElement;
    final data = VersionFile(
      code: tree.getElement('code')?.text ?? version.code,
      commited: tree.getElement('commited')?.text == 'true',
      path: version.path,
      timestamp: DateTime.tryParse(tree.getElement('timestamp')?.text ?? '') ??
          version.timestamp,
      message: tree.getElement('message')?.text,
      config: Project(
        creationDate: DateTime.tryParse(
              tree.getElement('config')?.getElement('creation-date')?.text ??
                  '',
            ) ??
            DateTime.now(),
        id: tree.getElement('config')?.getElement('id')?.text ?? '',
        name: tree.getElement('config')?.getElement('name')?.text ?? '',
        author: tree.getElement('config')?.getElement('author')?.text ?? '',
        path:
            tree.getElement('config')?.getElement('oryginal-path')?.text ?? '',
        language: ProjectLanguage.values.firstWhere(
          (element) {
            return element.name ==
                (tree.getElement('config')?.getElement('language')?.text ??
                    ProjectLanguage.other.name);
          },
        ),
      ),
      characters: tree.getElement('characters')?.children.map((p0) {
            return Character.fromXml(p0.getElement('character')!);
          }).toList() ??
          <Character>[],
      threads: tree.getElement('threads')?.children.map((p0) {
            return Thread.fromXml(p0.getElement('thread')!);
          }).toList() ??
          <Thread>[],
      chapters: tree.getElement('chapters')?.children.map((p0) {
            return Chapter.fromXml(p0.getElement('chapter')!);
          }).toList() ??
          <Chapter>[],
      contents: tree
              .getElement('content')
              ?.children
              .map((nest) {
                final p0 = nest.getElement('chapter-file');
                final p1 = nest.getElement('chapter-id');
                return MapEntry(
                    p1?.innerText ?? '',
                    (json.decode(p0?.innerText ?? '[]') as List)
                        .map((e) => e.toString())
                        .toList());
              })
              .toList()
              .asMap()
              .map((key, value) => MapEntry(value.key, value.value)) ??
          {},
    );

    return data;
  }

  Future<void> stageChanges(Project project, Version version) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final versionDirectory = Directory(
      p.join(preferencesDirectory.path, 'versions'),
    );
    if (!(versionDirectory.existsSync())) versionDirectory.createSync();
    final versionFile = File(version.path);
    if (!(versionFile.existsSync())) versionFile.createSync();

    final port = ReceivePort();
    await Isolate.spawn(_writeToVersion, [
      port.sendPort,
      versionFile.path,
      project.path,
      version.toJson(),
    ]);
  }

  Future<String?> getExportableFile(Project project) async {
    final port = ReceivePort();
    await Isolate.spawn(_generateExportable, [
      port.sendPort,
      project.path,
    ]);
    final response = await port.first as String?;

    if (response != null) {
      return response;
    }

    return null;
  }

  Future<void> _writeToVersion(List<dynamic> args) async {
    SendPort responsePort = args[0];
    String path = args[1];
    String project = args[2];
    Version version = Version.fromJson(
      (args[3] as Map).map((key, value) => MapEntry(key.toString(), value)),
    );

    final file = File(path);
    if (!(file.existsSync())) file.create();

    final config = File(p.join(project, 'config.mwrt'));

    if (!config.existsSync()) {
      Isolate.exit(responsePort, false);
    }

    try {
      final xml = await _getFileContent(project, version);
      await file.writeAsString(xml);
    } catch (e) {
      Isolate.exit(responsePort, false);
    }

    Isolate.exit(responsePort, true);
  }

  Future<void> _generateExportable(List<dynamic> args) async {
    SendPort responsePort = args[0];
    String project = args[1];

    final config = File(p.join(project, 'config.mwrt'));

    if (!config.existsSync()) {
      Isolate.exit(responsePort, null);
    }

    try {
      final xml = await _getFileContent(project);
      Isolate.exit(responsePort, xml);
    } catch (e) {
      Isolate.exit(responsePort, null);
    }
  }

  Future<String> _getFileContent(String project, [Version? version]) async {
    final builder = XmlBuilder();
    builder.declaration(
      version: '1.0',
      encoding: 'UTF-8',
    );

    final config = File(p.join(project, 'config.mwrt'));
    final characters = Directory(p.join(project, 'characters'));
    final threads = Directory(p.join(project, 'threads'));
    final chapters = Directory(p.join(project, 'chapters'));
    final content = Directory(p.join(project, 'content'));

    final general = Project.fromJson(
      (json.decode(await config.readAsString()) as Map).map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );

    builder.element('version', nest: () {
      if (version != null) {
        builder.element('code', nest: version.code);
        builder.element('commited', nest: version.commited.toString());
        builder.element('previous', nest: version.previous);
        builder.element('message', nest: version.message);
        builder.element('path', nest: version.path);
        builder.element('timestamp', nest: version.timestamp.toIso8601String());
      }
      builder.element('config', nest: () {
        builder.element('id', nest: general.id);
        builder.element('name', nest: general.name);
        builder.element('author', nest: general.author);
        builder.element('oryginal-path', nest: general.path);
        builder.element('language', nest: general.language.name);
        builder.element(
          'creation-date',
          nest: general.creationDate.toIso8601String(),
        );
      });
      builder.element('characters', nest: () {
        if (characters.existsSync()) {
          final files = characters
              .listSync()
              .whereType<File>()
              .where((element) => element.path.endsWith('.xml'))
              .toList();

          for (var character in files) {
            final data = Character.getCharacterTag(
              character.readAsStringSync(),
            );
            builder.element('character', nest: () {
              builder.xml(data.toXmlString());
            });
          }
        }
      });
      builder.element('threads', nest: () {
        if (threads.existsSync()) {
          final files = threads
              .listSync()
              .whereType<File>()
              .where((element) => element.path.endsWith('.xml'))
              .toList();

          for (var thread in files) {
            final data = Thread.getThreadTag(
              thread.readAsStringSync(),
            );
            builder.element('thread', nest: () {
              builder.xml(data.toXmlString());
            });
          }
        }
      });
      builder.element('chapters', nest: () {
        if (chapters.existsSync()) {
          final files = chapters
              .listSync()
              .whereType<File>()
              .where((element) => element.path.endsWith('.xml'))
              .toList();

          for (var chapter in files) {
            final data = Chapter.getChapterTag(
              chapter.readAsStringSync(),
            );
            builder.element('chapter', nest: () {
              builder.xml(data.toXmlString());
            });
          }
        }
      });
      builder.element('content', nest: () {
        if (content.existsSync()) {
          final files = content
              .listSync()
              .whereType<File>()
              .where((element) => element.path.endsWith('.txt'))
              .toList();

          for (var chapter in files) {
            builder.element('file', nest: () {
              final path = Uri.parse(chapter.path).pathSegments.lastWhere(
                    (element) => element.endsWith('.txt'),
                  );
              builder.element(
                'chapter-id',
                nest: path.substring(0, path.length - '.txt'.length),
              );
              builder.element(
                'chapter-file',
                nest: chapter.readAsStringSync(),
              );
            });
          }
        }
      });
      // TODO : finish adding more data to verison
    });

    final xml = builder.buildDocument();
    return xml.toString();
  }
}
