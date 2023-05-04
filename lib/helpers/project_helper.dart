import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import '../models/chapters/chapter.dart';
import '../models/chapters/chapter_file.dart';
import '../models/characters/character.dart';
import '../models/language.dart';
import '../models/on_this_day.dart';
import '../models/project.dart';
import '../models/search_result.dart';
import '../models/threads/thread.dart';
import 'file_explorer_helper.dart';
import 'general_helper.dart';

class ProjectHelper {
  Future<Project> createNewProject(String path, [String? name]) async {
    final prefs = await SharedPreferences.getInstance();
    final directory = Directory(path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final configFile = File(p.join(directory.path, 'config.mwrt'));
    await configFile.create();
    final project = Project(
      id: GeneralHelper().id(),
      name: name ?? 'Unnamed Project',
      path: path,
      creationDate: DateTime.now(),
      language: GeneralHelper().getPlatfromLanguage(),
    );

    await configFile.writeAsString(json.encode(project.toJson()));

    final recentProjects = prefs.getStringList('recent_projects') ?? [];
    recentProjects.add(path);
    await prefs.setStringList(
      'recent_projects',
      recentProjects.toSet().toList(),
    );

    return project;
  }

  Future<List<Directory>> getRecentProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final recentProjects = prefs.getStringList('recent_projects') ?? [];
    return recentProjects.map((e) {
      return Directory(e);
    }).toList();
  }

  Future<Project> loadProject(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final directory = Directory(path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final configFile = File(p.join(directory.path, 'config.mwrt'));
    if (!(configFile.existsSync())) {
      throw Exception('There is no config file');
    }

    final project = Project.fromJson(
      (json.decode(await configFile.readAsString()) as Map).map((key, value) {
        return MapEntry(key.toString(), value);
      }),
    );

    final recentProjects = prefs.getStringList('recent_projects') ?? [];
    recentProjects.add(path);
    await prefs.setStringList(
      'recent_projects',
      recentProjects.toSet().toList(),
    );

    return project;
  }

  Future<Project> overrideProject(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final configFile = File(p.join(directory.path, 'config.mwrt'));
    await configFile.writeAsString(json.encode(project.toJson()));

    return project;
  }

  Future<Map<String, String>> getAllCharacters(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final charactersDirectory = Directory(p.join(directory.path, 'characters'));
    if (!(charactersDirectory.existsSync())) {
      return {};
    }
    final allCharactersFile = File(
      p.join(charactersDirectory.path, 'all_characters.json'),
    );
    if (!(allCharactersFile.existsSync())) {
      return {};
    }
    final allCharacters = (json.decode(
      await allCharactersFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });

    return allCharacters;
  }

  /// returns updated list of all characters
  Future<Map<String, String>> addCharacter(
      Character character, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final charactersDirectory = Directory(p.join(directory.path, 'characters'));
    if (!(charactersDirectory.existsSync())) await charactersDirectory.create();
    final allCharactersFile = File(
      p.join(charactersDirectory.path, 'all_characters.json'),
    );
    if (!(allCharactersFile.existsSync())) {
      await allCharactersFile.create();
      allCharactersFile.writeAsStringSync('{}');
    }
    final allCharacters = (json.decode(
      await allCharactersFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    allCharacters.addEntries([
      MapEntry(character.id, character.name),
    ]);
    await allCharactersFile.writeAsString(json.encode(allCharacters));

    final newCharacterFile = File(p.join(
      charactersDirectory.path,
      '${character.id}.xml',
    ));
    await newCharacterFile.create();
    await newCharacterFile.writeAsString(character.toXML());

    return allCharacters;
  }

  /// returns updated list of all characters
  Future<Map<String, String>> overrideCharacter(
      Character character, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final charactersDirectory = Directory(p.join(directory.path, 'characters'));
    if (!(charactersDirectory.existsSync())) charactersDirectory.createSync();
    final characterFile = File(
      p.join(charactersDirectory.path, '${character.id}.xml'),
    );
    if (!(characterFile.existsSync())) {
      await addCharacter(character, project);
    } else {
      await characterFile.writeAsString(character.toXML());
    }

    final allCharactersFile = File(
      p.join(charactersDirectory.path, 'all_characters.json'),
    );
    final allCharacters = (json.decode(
      await allCharactersFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    allCharacters[character.id] = character.name;
    await allCharactersFile.writeAsString(json.encode(allCharacters));

    return allCharacters;
  }

  /// returns updated list of all characters
  Future<Map<String, String>> deleteCharacter(
      String characterId, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final charactersDirectory = Directory(p.join(directory.path, 'characters'));
    if (!(charactersDirectory.existsSync())) await charactersDirectory.create();
    final allCharactersFile = File(
      p.join(charactersDirectory.path, 'all_characters.json'),
    );
    if (!(allCharactersFile.existsSync())) {
      await allCharactersFile.create();
      allCharactersFile.writeAsStringSync('{}');
    }
    final allCharacters = (json.decode(
      await allCharactersFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    allCharacters.remove(characterId);
    await allCharactersFile.writeAsString(json.encode(allCharacters));

    final characterFile = File(
      p.join(charactersDirectory.path, '$characterId.xml'),
    );
    if (characterFile.existsSync()) {
      await characterFile.delete();
    }
    return allCharacters;
  }

  Future<Character> getCharacter(String id, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final charactersDirectory = Directory(p.join(directory.path, 'characters'));
    if (!(charactersDirectory.existsSync())) {
      throw Exception('There is no such character');
    }
    final characterFile = File(
      p.join(charactersDirectory.path, '$id.xml'),
    );
    if (!(characterFile.existsSync())) {
      throw Exception('There is no such character');
    }
    final character = Character.fromXml(
      Character.getCharacterTag(await characterFile.readAsString()),
    );

    return character;
  }

  Future<Map<String, dynamic>> getProjectPrefferences(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) return {};
    final prefsFile = File(
      p.join(preferencesDirectory.path, 'preferences.json'),
    );
    if (!(prefsFile.existsSync())) return {};
    final decoded = json.decode(await prefsFile.readAsString());

    return (decoded as Map).map((key, value) {
      return MapEntry(key.toString(), value);
    });
  }

  Future<void> setProjectPrefference(
      Project project, String key, dynamic value) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final preferencesDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(preferencesDirectory.existsSync())) preferencesDirectory.createSync();
    final prefsFile = File(
      p.join(preferencesDirectory.path, 'preferences.json'),
    );
    if (!(prefsFile.existsSync())) {
      prefsFile.createSync();
      prefsFile.writeAsStringSync('{}');
    }
    final decoded = json.decode(await prefsFile.readAsString());
    final data = (decoded as Map).map((key, value) {
      return MapEntry(key.toString(), value);
    });
    data[key] = value;
    await prefsFile.writeAsString(json.encode(data));
  }

  /// returns updated list of all threads
  Future<Map<String, String>> addThread(Thread thread, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final threadsDirectory = Directory(p.join(directory.path, 'threads'));
    if (!(threadsDirectory.existsSync())) await threadsDirectory.create();
    final allThreadsFile = File(
      p.join(threadsDirectory.path, 'all_threads.json'),
    );
    if (!(allThreadsFile.existsSync())) {
      await allThreadsFile.create();
      allThreadsFile.writeAsStringSync('{}');
    }
    final allThreads = (json.decode(
      await allThreadsFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    allThreads.addEntries([
      MapEntry(thread.id, thread.name),
    ]);
    await allThreadsFile.writeAsString(json.encode(allThreads));

    final newThreadFile = File(p.join(
      threadsDirectory.path,
      '${thread.id}.xml',
    ));
    await newThreadFile.create();
    await newThreadFile.writeAsString(thread.toXML());

    return allThreads;
  }

  /// returns updated list of all threads
  Future<Map<String, String>> overrideThread(
      Thread thread, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final threadsDirectory = Directory(p.join(directory.path, 'threads'));
    if (!(threadsDirectory.existsSync())) threadsDirectory.createSync();
    final threadFile = File(
      p.join(threadsDirectory.path, '${thread.id}.xml'),
    );
    if (!(threadFile.existsSync())) {
      await addThread(thread, project);
    } else {
      await threadFile.writeAsString(thread.toXML());
    }

    final allThreadsFile = File(
      p.join(threadsDirectory.path, 'all_threads.json'),
    );
    final allThreads = (json.decode(
      await allThreadsFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    allThreads[thread.id] = thread.name;
    await allThreadsFile.writeAsString(json.encode(allThreads));

    return allThreads;
  }

  /// returns updated list of all threads
  Future<Map<String, String>> deleteThread(
      String threadId, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final threadsDirectory = Directory(p.join(directory.path, 'threads'));
    if (!(threadsDirectory.existsSync())) await threadsDirectory.create();
    final allThreadsFile = File(
      p.join(threadsDirectory.path, 'all_threads.json'),
    );
    if (!(allThreadsFile.existsSync())) {
      await allThreadsFile.create();
      allThreadsFile.writeAsStringSync('{}');
    }
    final allThreads = (json.decode(
      await allThreadsFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
    allThreads.remove(threadId);
    await allThreadsFile.writeAsString(json.encode(allThreads));

    final threadFile = File(
      p.join(threadsDirectory.path, '$threadId.xml'),
    );
    if (threadFile.existsSync()) {
      await threadFile.delete();
    }
    return allThreads;
  }

  Future<Thread> getThread(String id, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final threadsDirectory = Directory(p.join(directory.path, 'threads'));
    if (!(threadsDirectory.existsSync())) {
      throw Exception('There is no such thread');
    }
    final threadFile = File(
      p.join(threadsDirectory.path, '$id.xml'),
    );
    if (!(threadFile.existsSync())) {
      throw Exception('There is no such thread');
    }
    final thread = Thread.fromXml(
      Thread.getThreadTag(await threadFile.readAsString()),
    );

    return thread;
  }

  Future<Map<String, String>> getAllThreads(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final threadsDirectory = Directory(p.join(directory.path, 'threads'));
    if (!(threadsDirectory.existsSync())) {
      return {};
    }
    final allThreadsFile = File(
      p.join(threadsDirectory.path, 'all_threads.json'),
    );
    if (!(allThreadsFile.existsSync())) {
      return {};
    }
    final allThreads = (json.decode(
      await allThreadsFile.readAsString(),
    ) as Map)
        .map((key, value) {
      return MapEntry(key.toString(), value.toString());
    });

    return allThreads;
  }

  Future<void> addChapter(Chapter chapter, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final chaptersDirectory = Directory(p.join(directory.path, 'chapters'));
    if (!(chaptersDirectory.existsSync())) await chaptersDirectory.create();

    final newChapterFile = File(p.join(
      chaptersDirectory.path,
      '${chapter.id}.xml',
    ));
    await newChapterFile.create();
    await newChapterFile.writeAsString(chapter.toXML());
  }

  Future<void> overrideChapter(Chapter chapter, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final chaptersDirectory = Directory(p.join(directory.path, 'chapters'));
    if (!(chaptersDirectory.existsSync())) await chaptersDirectory.create();

    final chapterFile = File(p.join(
      chaptersDirectory.path,
      '${chapter.id}.xml',
    ));
    await chapterFile.writeAsString(chapter.toXML());
  }

  Future<void> deleteChapter(String id, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final chaptersDirectory = Directory(p.join(directory.path, 'chapters'));
    if (!(chaptersDirectory.existsSync())) await chaptersDirectory.create();

    final chapterFile = File(p.join(
      chaptersDirectory.path,
      '$id.xml',
    ));
    if (chapterFile.existsSync()) {
      await chapterFile.delete();
    }
    await deleteChapterEditor(id, project);
  }

  Future<List<Chapter>> getAllChapters(Project project) async {
    final port = ReceivePort();
    await Isolate.spawn(_getAllChapters, [port.sendPort, project.path]);
    final response = await port.first as List<String>?;

    if (response != null) {
      return response
          .map((e) => Chapter.fromXml(Chapter.getChapterTag(e)))
          .toList();
    }

    return [];
  }

  Future<ChapterFile> openChapterEditor(String id, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final contentDirectory = Directory(p.join(directory.path, 'content'));
    if (!(contentDirectory.existsSync())) await contentDirectory.create();

    final chapterFile = File(p.join(
      contentDirectory.path,
      '$id.txt',
    ));
    if (!(chapterFile.existsSync())) {
      final emptyFile = ChapterFile(
        chapterId: id,
        content: [],
        lastModified: DateTime.now(),
      );
      await chapterFile.create();
      await chapterFile.writeAsString(jsonEncode([]));
      return emptyFile;
    }

    final content = await chapterFile.readAsString();
    final document = jsonDecode(content) as List;
    return ChapterFile(
      chapterId: id,
      content: document,
      lastModified: chapterFile.statSync().modified,
    );
  }

  Future<void> updateChapterEditor(
      String id, Project project, List content) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final contentDirectory = Directory(p.join(directory.path, 'content'));
    if (!(contentDirectory.existsSync())) await contentDirectory.create();

    final chapterFile = File(p.join(
      contentDirectory.path,
      '$id.txt',
    ));
    if (!(chapterFile.existsSync())) {
      await chapterFile.create();
    }
    await chapterFile.writeAsString(jsonEncode(content));
  }

  Future<void> deleteChapterEditor(String id, Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final contentDirectory = Directory(p.join(directory.path, 'content'));
    if (!(contentDirectory.existsSync())) await contentDirectory.create();

    final chapterFile = File(p.join(
      contentDirectory.path,
      '$id.txt',
    ));
    if (chapterFile.existsSync()) {
      await chapterFile.delete();
    }
  }

  Future<List<WikipediaSnippet>> getWikipediaSnippets(Project project) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final cacheDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(cacheDirectory.existsSync())) cacheDirectory.createSync();
    final wikipediaFile = File(p.join(cacheDirectory.path, 'wikipedia.json'));
    if (!(wikipediaFile.existsSync())) {
      await wikipediaFile.create();
      await wikipediaFile.writeAsString('[]');
    }
    final content = json.decode(await wikipediaFile.readAsString()) as List;

    return content.map((e) {
      return WikipediaSnippet.fromJson(
        (e as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }).toList();
  }

  Future<void> addWikipediaSnippet(Project project, WikipediaSnippet x) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final cacheDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(cacheDirectory.existsSync())) cacheDirectory.createSync();
    final wikipediaFile = File(p.join(cacheDirectory.path, 'wikipedia.json'));
    if (!(wikipediaFile.existsSync())) {
      await wikipediaFile.create();
      await wikipediaFile.writeAsString('[]');
    }
    final content = json.decode(await wikipediaFile.readAsString()) as List;
    content.add(x.toJson());
    await wikipediaFile.writeAsString(json.encode(content));
  }

  Future<void> removeWikipediaSnippet(Project project, String? url) async {
    final directory = Directory(project.path);
    if (!(directory.existsSync())) {
      throw Exception('There is no such directory');
    }
    final cacheDirectory = Directory(p.join(directory.path, '.writer'));
    if (!(cacheDirectory.existsSync())) cacheDirectory.createSync();
    final wikipediaFile = File(p.join(cacheDirectory.path, 'wikipedia.json'));
    if (!(wikipediaFile.existsSync())) {
      await wikipediaFile.create();
      await wikipediaFile.writeAsString('[]');
    }
    final content = json.decode(await wikipediaFile.readAsString()) as List;
    final data = content.map((e) {
      return WikipediaSnippet.fromJson(
        (e as Map).map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }).toList();
    data.removeWhere((element) => element.url == url);
    await wikipediaFile.writeAsString(
      json.encode(data.map((e) => e.toJson()).toList()),
    );
  }

  /// finds all references to this character, thread, chapter or scene
  Future<List<SearchResult>?> getReferences(Project project, String id) async {
    final port = ReceivePort();
    await Isolate.spawn(_getReferences, [port.sendPort, project.path, id]);

    final response = await port.first as List<String>?;

    if (response != null) {
      final results = response.map((e) {
        return SearchResult.fromFilePath(e);
      }).toList();
      return results;
    }
    return null;
  }

  /// Loads project from weave file and then creates new project. Currently only
  /// macos supported. it also handles case if project with the same name already exists
  // TODO: add windows support
  Future<Project?> importProject(String file) async {
    if (!Platform.isMacOS) return null;

    try {
      final xml = XmlDocument.parse(file);
      final tree = xml.rootElement;
      final config = Project(
        creationDate: DateTime.tryParse(
              tree.getElement('config')?.getElement('creation-date')?.text ??
                  '',
            ) ??
            DateTime.now(),
        id: tree.getElement('config')?.getElement('id')?.text ?? '',
        name: tree.getElement('config')?.getElement('name')?.text ?? '',
        author: tree.getElement('config')?.getElement('author')?.text ?? '',
        path: '',
        language: ProjectLanguage.values.firstWhere(
          (element) {
            return element.name ==
                (tree.getElement('config')?.getElement('language')?.text ??
                    ProjectLanguage.other.name);
          },
        ),
      );
      final characters = tree.getElement('characters')?.children.map((p0) {
            return Character.fromXml(p0.getElement('character')!);
          }).toList() ??
          <Character>[];
      final threads = tree.getElement('threads')?.children.map((p0) {
            return Thread.fromXml(p0.getElement('thread')!);
          }).toList() ??
          <Thread>[];
      final chapters = tree.getElement('chapters')?.children.map((p0) {
            return Chapter.fromXml(p0.getElement('chapter')!);
          }).toList() ??
          <Chapter>[];
      final contents = tree
              .getElement('content')
              ?.children
              .map((nest) {
                final p0 = nest.getElement('chapter-file');
                final p1 = nest.getElement('chapter-id');
                return MapEntry(
                    p1?.innerText ?? '',
                    (json.decode(p0?.innerText ?? '[]') as List)
                        .map((e) => e)
                        .map((e) => e as Map)
                        .toList());
              })
              .toList()
              .asMap()
              .map((key, value) => MapEntry(value.key, value.value)) ??
          {};

      String path = FileExplorerHelper().macosGetProjectPathName(config.name);
      if (await FileExplorerHelper().macosDoesProjectExists(path)) {
        path = FileExplorerHelper().macosGetProjectPathName(
          '${config.name}_import',
        );
        if (await FileExplorerHelper().macosDoesProjectExists(path)) {
          // imported file still exist, adding versions
          int number = 1;
          do {
            path = FileExplorerHelper().macosGetProjectPathName(
              '${config.name}_import_($number)',
            );
            number++;
          } while (await FileExplorerHelper().macosDoesProjectExists(path));
        }
      }

      final prefs = await SharedPreferences.getInstance();

      path = await FileExplorerHelper().macosGetProjectPath(path);

      final directory = Directory(
        path,
      );
      if (!(directory.existsSync())) {
        await directory.create();
      }
      final configFile = File(p.join(directory.path, 'config.mwrt'));
      await configFile.create();
      final project = Project(
        id: config.id,
        name: config.name,
        path: path,
        creationDate: config.creationDate,
        language: config.language,
      );
      await configFile.writeAsString(json.encode(project.toJson()));

      for (var element in characters) {
        await addCharacter(element, project);
      }
      for (var element in threads) {
        await addThread(element, project);
      }
      for (var element in chapters) {
        await addChapter(element, project);
      }
      for (var element in contents.entries) {
        await openChapterEditor(element.key, project);
        await updateChapterEditor(element.key, project, element.value);
      }

      final recentProjects = prefs.getStringList('recent_projects') ?? [];
      recentProjects.add(path);
      await prefs.setStringList(
        'recent_projects',
        recentProjects.toSet().toList(),
      );

      return project;
    } catch (e) {
      // some error occurred
      rethrow;
    }
  }
}

Future<void> _getAllChapters(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String path = args[1];

  final fileContent = <String>[];
  final directory = Directory(path);
  if (!(directory.existsSync())) {
    throw Exception('There is no such directory');
  }
  final chaptersDirectory = Directory(p.join(directory.path, 'chapters'));
  if (!(chaptersDirectory.existsSync())) await chaptersDirectory.create();
  final files = chaptersDirectory.listSync().whereType<File>().toList();

  for (var element in files) {
    fileContent.add(await element.readAsString());
  }

  Isolate.exit(responsePort, fileContent);
}

Future<void> _getReferences(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String path = args[1];
  String id = args[2];

  List<String> results = [];

  final directory = Directory(path);
  if (!(directory.existsSync())) {
    throw Exception('There is no such directory');
  }
  final characters = Directory(p.join(directory.path, 'characters'));
  final threads = Directory(p.join(directory.path, 'threads'));
  final chapters = Directory(p.join(directory.path, 'chapters'));

  if (characters.existsSync()) {
    final files = characters
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();
    final matches = files.where((element) {
      return element.readAsStringSync().contains(id);
    }).toList();
    results.addAll(matches.map((e) => e.path));
  }

  if (threads.existsSync()) {
    final files = threads
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();
    final matches = files.where((element) {
      return element.readAsStringSync().contains(id);
    }).toList();
    results.addAll(matches.map((e) => e.path));
  }

  if (chapters.existsSync()) {
    final files = chapters
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();
    final matches = files.where((element) {
      return element.readAsStringSync().contains(id);
    }).toList();
    results.addAll(matches.map((e) => e.path));
  }

  // TODO: possibly add more places of reference

  Isolate.exit(responsePort, results);
}
