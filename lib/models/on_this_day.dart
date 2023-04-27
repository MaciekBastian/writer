class OnThisDay {
  final DateTime date;
  final List<Holiday> holidays;
  final List<Event> events;
  final List<Event> selectedEvents;
  final List<PersonBirthOrDeath> births;
  final List<PersonBirthOrDeath> deaths;

  OnThisDay.fromJson(Map<String, dynamic> day, DateTime when)
      : date = when,
        holidays = ((day['holidays'] as List?) ?? []).map((e) {
          return Holiday.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList(),
        births = ((day['births'] as List?) ?? []).map((e) {
          return PersonBirthOrDeath.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList(),
        deaths = ((day['deaths'] as List?) ?? []).map((e) {
          return PersonBirthOrDeath.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList(),
        events = ((day['events'] as List?) ?? []).map((e) {
          return Event.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList(),
        selectedEvents = ((day['selected'] as List?) ?? []).map((e) {
          return Event.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList();
}

class PersonBirthOrDeath {
  final String name;
  final int year;
  final List<WikipediaSnippet> relatedPages;

  PersonBirthOrDeath.fromJson(Map<String, dynamic> person)
      : name = person['text'],
        year = person['year'],
        relatedPages = ((person['pages'] as List?) ?? []).map((e) {
          return WikipediaSnippet.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList();
}

class Holiday {
  final String name;
  final List<WikipediaSnippet> relatedPages;

  Holiday.fromJson(Map<String, dynamic> holiday)
      : name = holiday['text'],
        relatedPages = ((holiday['pages'] as List?) ?? []).map((e) {
          return WikipediaSnippet.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList();
}

class Event {
  final String name;
  final int year;
  final List<WikipediaSnippet> relatedPages;

  Event.fromJson(Map<String, dynamic> event)
      : name = event['text'],
        year = event['year'],
        relatedPages = ((event['pages'] as List?) ?? []).map((e) {
          return WikipediaSnippet.fromJson((e as Map).map((key, value) {
            return MapEntry(key.toString(), value);
          }));
        }).toList();
}

class WikipediaSnippet {
  final String extract;
  final String description;
  final String lang;
  final String title;
  final DateTime timestamp;
  final String? imageUrl;
  final String? url;

  WikipediaSnippet.fromJson(Map<String, dynamic> page)
      : extract = page['extract'] ?? '',
        title = page['titles']?['normalized'] ?? '',
        description = page['description'] ?? '',
        timestamp = DateTime.parse(page['timestamp']),
        lang = page['lang'] ?? 'en',
        url = page['content_urls']?['desktop']?['page'],
        imageUrl = page['originalimage']?['source'];

  Map<String, dynamic> toJson() => {
        'extract': extract,
        'titles': {'normalized': title},
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'lang': lang,
        'content_urls': {
          'desktop': {'page': url}
        },
        'originalimage': {'source': imageUrl}
      };
}
