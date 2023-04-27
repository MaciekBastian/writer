import 'package:xml/xml.dart';

import '../working_tree.dart';
import 'scene.dart';

class Chapter {
  final String id;
  final String name;
  final int index;
  final String? narrationId;
  final String? narrationName;
  final String description;
  final bool startsNewPart;
  final List<Scene> scenes;

  final WorkingTree<Chapter>? workingTree;

  Chapter({
    required this.id,
    required this.name,
    required this.index,
    this.startsNewPart = false,
    this.scenes = const [],
    this.description = '',
    this.narrationId,
    this.narrationName,
    this.workingTree,
  });

  Chapter.fromXml(XmlElement xml)
      : name = xml.getElement('name')?.text ?? '',
        id = xml.getElement('id')?.text ?? '',
        index = int.tryParse(xml.getElement('index')?.text ?? '') ?? -1,
        description = xml.getElement('description')?.text ?? '',
        startsNewPart =
            (xml.getElement('starts-new-part')?.text ?? 'false') == 'false'
                ? false
                : true,
        narrationId = xml.getElement('narration')?.getElement('id')?.text,
        narrationName = xml.getElement('narration')?.getElement('name')?.text,
        scenes = (xml.getElement('scenes')?.children ?? <XmlNode>[])
            .map((e) {
              final id = e.getElement('id')?.text;
              final name = e.getElement('name')?.text;
              final index = e.getElement('index')?.text;
              final description = e.getElement('description')?.text;
              final time = e.getElement('time')?.text;
              final threads = e.getElement('threads')?.children.map((p0) {
                return MapEntry(
                  p0.getElement('id')?.text ?? '',
                  p0.getElement('name')?.text ?? '',
                );
              }).toList();

              if (id == null ||
                  name == null ||
                  index == null ||
                  description == null ||
                  time == null) {
                return null;
              }

              return Scene(
                id: id,
                index: int.tryParse(index) ?? -1,
                description: description,
                name: name,
                threads: threads?.asMap().map((key, value) {
                      return MapEntry(value.key, value.value);
                    }) ??
                    {},
                time: time,
              );
            })
            .whereType<Scene>()
            .toList(),
        workingTree = null;

  static XmlElement getChapterTag(String xml) {
    final element = XmlDocument.parse(xml).getElement('chapter');

    if (element == null) {
      throw Exception('there is no chapter tag');
    } else {
      return element;
    }
  }

  String toXML() {
    final builder = XmlBuilder();
    builder.declaration(
      version: '1.0',
      encoding: 'UTF-8',
    );
    builder.element('chapter', nest: () {
      builder.element('name', nest: name);
      builder.element('id', nest: id);
      builder.element('index', nest: index);
      builder.element('description', nest: description);
      builder.element('starts-new-part', nest: startsNewPart.toString());
      builder.element('narration', nest: () {
        builder.element('id', nest: narrationId);
        builder.element('name', nest: narrationName);
      });
      builder.element('scenes', nest: () {
        for (var element in scenes) {
          builder.element('scene', nest: () {
            builder.element('id', nest: element.id);
            builder.element('name', nest: element.name);
            builder.element('index', nest: element.index);
            builder.element('time', nest: element.time);
            builder.element('description', nest: element.description);
            builder.element('threads', nest: () {
              for (var thread in element.threads.entries) {
                builder.element('thread', nest: () {
                  builder.element('id', nest: thread.key);
                  builder.element('name', nest: thread.value);
                });
              }
            });
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString();
  }

  Chapter copyWith({
    String? name,
    int? index,
    String? narrationId,
    String? narrationName,
    String? description,
    bool? startsNewPart,
    List<Scene>? scenes,
  }) {
    var tree = workingTree ?? WorkingTree.empty(this);
    final change = Chapter(
      id: id,
      name: name ?? this.name,
      index: index ?? this.index,
      narrationId: narrationId ?? this.narrationId,
      narrationName: narrationName ?? this.narrationName,
      description: description ?? this.description,
      scenes: scenes ?? this.scenes,
      startsNewPart: startsNewPart ?? this.startsNewPart,
    );

    tree = tree.newChange(this, change);

    return Chapter(
      id: id,
      name: change.name,
      index: change.index,
      narrationId: change.narrationId,
      narrationName: change.narrationName,
      description: change.description,
      scenes: change.scenes,
      startsNewPart: change.startsNewPart,
      workingTree: tree,
    );
  }

  Chapter.fromWorkingTree(WorkingTree<Chapter> tree)
      : id = tree.currentVersion.id,
        name = tree.currentVersion.name,
        description = tree.currentVersion.description,
        index = tree.currentVersion.index,
        narrationId = tree.currentVersion.narrationId,
        narrationName = tree.currentVersion.narrationName,
        startsNewPart = tree.currentVersion.startsNewPart,
        scenes = tree.currentVersion.scenes,
        workingTree = tree;

  Chapter removeNarration() => Chapter(
        id: id,
        name: name,
        index: index,
        narrationId: null,
        narrationName: null,
        description: description,
        scenes: scenes,
        startsNewPart: startsNewPart,
      );
}
