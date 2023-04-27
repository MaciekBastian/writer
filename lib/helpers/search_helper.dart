import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import '../models/file_tab.dart';
import 'package:xml/xml.dart';

import '../models/search_result.dart';

class SearchHelper {
  // TODO: search
  Future<List<SearchResult>> searchThroughProjectFiles(
      String path, String query) async {
    if (query.isEmpty || query.length == 1) return [];
    try {
      final port = ReceivePort();
      await Isolate.spawn(_lookForErrors, [port.sendPort, path, query]);
      final response = await port.first as List<Map<String, dynamic>>?;

      if (response != null) {
        return response.map((e) => SearchResult.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}

void _lookForErrors(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String path = args[1];
  String query = args[2].toString().trim().toLowerCase();

  List<SearchResult> results = [];

  final root = Directory(path);
  final characters = Directory(p.join(root.path, 'characters'));
  final threads = Directory(p.join(root.path, 'threads'));
  final List<File> files = [];
  if (characters.existsSync()) {
    final characterFiles = characters
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();
    files.addAll(characterFiles);
  }
  if (threads.existsSync()) {
    final threadFiles = threads
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.xml'))
        .toList();
    files.addAll(threadFiles);
  }
  for (var file in files) {
    final fileContent = (await file.readAsString());
    final document = XmlDocument.parse(fileContent);
    final allNodes = document.findAllElements('*').where((element) {
      final tag = element.name.local;
      // accept only tags with specific name
      final reservedTags = [
        'name',
        'description',
        'apperance',
        'goals',
        'result',
        'conflict',
        'age'
      ];
      return reservedTags.contains(tag);
    }).toList();
    final contentes = allNodes
        .map((e) {
          return e.text.toLowerCase();
        })
        .toList()
        .where((element) {
          return element.isNotEmpty;
        })
        .toList();
    contentes.sort((a, b) => a.compareTo(b));

    final matches = contentes.where((element) {
      return element.contains(query);
    }).toList();
    if (matches.isNotEmpty) {
      final firstTag = document.rootElement.name.local;
      final types = {
        'character': FileType.characterEditor,
        'thread': FileType.threadEditor,
      };
      results.add(
        SearchResult(
          type: types[firstTag] ?? FileType.userFile,
          matches: matches,
          id: document.rootElement.getElement('id')?.text,
        ),
      );
    }
  }

  Isolate.exit(responsePort, results.map((e) => e.toJson()).toList());
}
