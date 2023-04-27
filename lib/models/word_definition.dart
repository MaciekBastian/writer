class WordDefinition {
  final String word;
  final String? phonetic;
  final List<Phonetic> phonetics;
  final String? licenseName;
  final String? licenseUrl;
  final List<String> sources;
  final List<Meaning> meanings;

  WordDefinition.fromJson(Map<String, dynamic> input)
      : word = input['word'],
        phonetic = input['phonetic'],
        phonetics = (input['phonetics'] as List?)?.map((e) {
              return Phonetic.fromJson(
                (e as Map).map((key, value) {
                  return MapEntry(key.toString(), value);
                }),
              );
            }).toList() ??
            [],
        licenseName = input['license']?['name'],
        licenseUrl = input['license']?['url'],
        sources = (input['sourceUrls'] as List?)?.map((e) {
              return e.toString();
            }).toList() ??
            [],
        meanings = (input['meanings'] as List?)?.map((e) {
              return Meaning.fromJson((e as Map).map((key, value) {
                return MapEntry(key.toString(), value);
              }));
            }).toList() ??
            [];
}

class Phonetic {
  final String? text;
  final String? audio;
  final String? sourceUrl;
  final String? licenseName;
  final String? licenseUrl;

  Phonetic.fromJson(Map<String, dynamic> input)
      : text = input['text'],
        audio = input['audio'],
        sourceUrl = input['sourceUrl'],
        licenseName = input['license']?['name'],
        licenseUrl = input['license']?['url'];
}

class Meaning {
  final String? partOfSpeech;
  final List<String> synonyms;
  final List<String> antonyms;
  List<Definition> definitions;

  Meaning.fromJson(Map<String, dynamic> input)
      : partOfSpeech = input['partOfSpeech'],
        synonyms = (input['synonyms'] as List?)?.map((e) {
              return e.toString();
            }).toList() ??
            [],
        antonyms = (input['antonyms'] as List?)?.map((e) {
              return e.toString();
            }).toList() ??
            [],
        definitions = (input['definitions'] as List?)?.map((e) {
              return Definition.fromJson(
                (e as Map).map(
                  (key, value) {
                    return MapEntry(
                      key.toString(),
                      value,
                    );
                  },
                ),
              );
            }).toList() ??
            [];
}

class Definition {
  final String definition;
  final String? example;

  Definition.fromJson(Map<String, dynamic> input)
      : definition = input['definition'],
        example = input['example'];
}
