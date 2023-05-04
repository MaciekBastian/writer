import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:spell_check_on_client/spell_check_on_client.dart';

import '../models/error/spelling_error.dart';

class SpellCheckHelper {
  Future<String> getDicrionary() async {
    final root = await pp.getApplicationSupportDirectory();
    final dictionary = File(p.join(root.path, 'dictionary.txt'));
    if (!dictionary.existsSync()) return '';

    return await dictionary.readAsString();
  }

  Future<void> addToDictionary(String word) async {
    final root = await pp.getApplicationSupportDirectory();
    final dictionary = File(p.join(root.path, 'dictionary.txt'));
    if (!dictionary.existsSync()) await dictionary.create();

    final content = await dictionary.readAsString();
    await dictionary.writeAsString(
      '$content\n$word',
    );
  }

  Future<List<SpellingError>?> spellCheck(String contents) async {
    final port = ReceivePort();

    final availableLanguages = ['en'];
    String language = Platform.localeName.substring(0, 2);
    language = availableLanguages.contains(language) ? language : 'en';
    String file = await rootBundle.loadString(
      'assets/documents/${language}_words.txt',
    );
    final userDictionary = await getDicrionary();

    await Isolate.spawn(_spellCheck, [
      port.sendPort,
      contents,
      file + (userDictionary.isEmpty ? '' : '\n$userDictionary'),
    ]);
    final response = await port.first as List<Map<String, dynamic>>?;

    if (response != null) {
      return response.map((e) => SpellingError.fromJson(e)).toList();
    }

    return null;
  }
}

const List<String> _letters = [
  'æ',
  'ð',
  'ø',
  'œ',
  'ß',
  'þ',
  'ğ',
  'ö',
  'ş',
  'ü',
  'č',
  'ć',
  'đ',
  'š',
  'ž',
  'ą',
  'ć',
  'ę',
  'ł',
  'ń',
  'ó',
  'ś',
  'ź',
  'ż',
  'à',
  'â',
  'æ',
  'ç',
  'é',
  'è',
  'ê',
  'ë',
  'î',
  'ï',
  'ô',
  'œ',
  'ù',
  'û',
  'ü',
  'ÿ',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z'
];

Future<void> _spellCheck(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String contents = args[1];
  String file = args[2];

  final List<SpellingError> errors = [];

  final spellCheck = SpellCheck.fromWordsContent(
    file,
    letters: _letters,
  );

  final regexp = RegExp(
    r"[^a-zA-Z.'\s]+",
  );

  final sentences = contents
      .replaceAll(regexp, '')
      .split('.')
      .map((e) => e.trim().isEmpty ? null : e.trim().toLowerCase())
      .whereType<String>()
      .toList();

  for (var sentence in sentences) {
    final correctness = spellCheck.getPercentageCorrect(sentence);
    if (correctness > 0.99) continue;
    final words = sentence
        .split(' ')
        .map((e) {
          return e.trim().isEmpty ? null : e.trim();
        })
        .whereType<String>()
        .toList();
    for (var word in words) {
      if (!spellCheck.isCorrect(word)) {
        // spelling error
        final suggestions = spellCheck.didYouMeanAny(word);
        errors.add(
          SpellingError(
            sentence: sentence,
            wordWithError: word,
            suggestions: suggestions,
          ),
        );
      }
    }
  }

  final resultJson = errors.map((e) => e.toJson()).toList();
  Isolate.exit(responsePort, resultJson);
}
