import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../models/language.dart';
import '../models/on_this_day.dart';
import '../models/word_definition.dart';

class APIsHelper {
  Future<List<WordDefinition>?> lookupWordDefinitions(String word) async {
    // check if device is connected to the internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    // return null if there is no internet connection
    if (!hasConnection) return null;

    final url = 'https://api.dictionaryapi.dev/api/v2/entries/en/$word';
    try {
      final response = await http.get(Uri.parse(url));
      // status 200 = http request completed without errors
      if (response.statusCode != 200) return null;
      final data = json.decode(utf8.decode(response.bodyBytes)) as List;

      // return null if there is no results
      if (data.isEmpty) return null;

      final definitions = data
          .map(
            (e) => WordDefinition.fromJson(
              (e as Map).map(
                (key, value) {
                  return MapEntry(key.toString(), value);
                },
              ),
            ),
          )
          .toList();

      return definitions;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>?> getNameday(DateTime date, ProjectLanguage lang) async {
    // check if device is connected to the internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    // return null if there is no internet connection
    if (!hasConnection) return null;

    final country = lang == ProjectLanguage.pl ? 'pl' : 'us';

    final url =
        'https://nameday.abalin.net/api/V1/getdate?country=$country&month=${date.month}&day=${date.day}';

    try {
      final response = await http.get(Uri.parse(url));
      // status 200 = http request completed without errors
      if (response.statusCode != 200) return null;
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map;

      // return null if there is no results
      if (data.isEmpty) return null;

      final names = data['nameday']?[country] as String?;
      if (names == null) return null;
      return names.split(', ');
    } catch (e) {
      return null;
    }
  }

  Future<OnThisDay?> getOnThisDay(DateTime date) async {
    // check if device is connected to the internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    // return null if there is no internet connection
    if (!hasConnection) return null;

    final paddedMonth = '${date.month < 10 ? '0' : ''}${date.month}';
    final paddedDay = '${date.day < 10 ? '0' : ''}${date.day}';

    final url =
        'https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/all/$paddedMonth/$paddedDay';
    try {
      final response = await http.get(Uri.parse(url));
      // status 200 = http request completed without errors
      if (response.statusCode != 200) return null;
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map;

      // return null if there is no results
      if (data.isEmpty) return null;

      final onThisDay = OnThisDay.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
        date,
      );

      return onThisDay;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getTitle(String query, String lang) async {
    final url =
        'https://api.wikimedia.org/core/v1/wikipedia/$lang/search/title?q=$query&limit=1';
    final response = await http.get(Uri.parse(url));
    // status 200 = http request completed without errors
    if (response.statusCode != 200) return null;
    final data = json.decode(utf8.decode(response.bodyBytes)) as Map;
    final pages = data['pages'] as List?;
    if (pages == null) return null;
    if (pages.isEmpty) return null;
    final page = pages.first as Map;
    return page['key'];
  }

  Future<WikipediaSnippet?> queryWikipedia(String query, [String? lang]) async {
    // check if device is connected to the internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResult != ConnectivityResult.none;
    // return null if there is no internet connection
    if (!hasConnection) return null;

    final title = await getTitle(query, lang ?? 'en');
    // no title was found
    if (title == null) return null;

    final url =
        'https://${lang ?? 'en'}.wikipedia.org/api/rest_v1/page/summary/$title';
    try {
      final response = await http.get(Uri.parse(url));
      // status 200 = http request completed without errors
      if (response.statusCode != 200) return null;
      final data = json.decode(utf8.decode(response.bodyBytes)) as Map;

      // return null if there is no results
      if (data.isEmpty) return null;

      final wikipedia = WikipediaSnippet.fromJson(
        data.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );

      return wikipedia;
    } catch (e) {
      return null;
    }
  }
}
