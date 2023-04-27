import 'package:xml/xml.dart';

class Thread {
  final String id;
  final String name;
  final String description;
  final String conflict;
  final String result;
  final Map<String, String> charactersInvolved;

  Thread({
    required this.id,
    required this.name,
    this.description = '',
    this.conflict = '',
    this.result = '',
    this.charactersInvolved = const {},
  });

  /// must be thread tag
  Thread.fromXml(XmlElement xml)
      : id = xml.getElement('id')?.text ?? '',
        name = xml.getElement('name')?.text ?? '',
        description = xml.getElement('description')?.text ?? '',
        conflict = xml.getElement('conflict')?.text ?? '',
        result = xml.getElement('result')?.text ?? '',
        charactersInvolved =
            (xml.getElement('characters-involved')?.children ?? <XmlNode>[])
                .map((e) {
                  return MapEntry(
                    e.getElement('id')?.text ?? '',
                    e.getElement('name')?.text ?? '',
                  );
                })
                .toList()
                .asMap()
                .map((key, value) => MapEntry(value.key, value.value));

  static XmlElement getThreadTag(String xml) {
    final element = XmlDocument.parse(xml).getElement('thread');

    if (element == null) {
      throw Exception('there is no thread tag');
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
    builder.element('thread', nest: () {
      builder.element('id', nest: id);
      builder.element('name', nest: name);
      builder.element('description', nest: description);
      builder.element('conflict', nest: conflict);
      builder.element('result', nest: result);
      builder.element('characters-involved', nest: () {
        for (var entry in charactersInvolved.entries) {
          builder.element('person', nest: () {
            builder.element('id', nest: entry.key);
            builder.element('name', nest: entry.value);
          });
        }
      });
    });
    final document = builder.buildDocument();
    return document.toXmlString();
  }

  Thread copyWith({
    String? name,
    String? description,
    String? conflict,
    String? result,
    Map<String, String>? charactersInvolved,
  }) {
    return Thread(
      id: id,
      name: name ?? this.name,
      charactersInvolved: charactersInvolved ?? this.charactersInvolved,
      conflict: conflict ?? this.conflict,
      description: description ?? this.description,
      result: result ?? this.result,
    );
  }
}
