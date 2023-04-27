import '../file_tab.dart';

class SpellingError {
  final String wordWithError;
  final List<String> suggestions;
  final String sentence;

  SpellingError({
    required this.wordWithError,
    required this.sentence,
    required this.suggestions,
  });

  SpellingError.fromJson(Map<String, dynamic> input)
      : wordWithError = input['wordWithError'],
        suggestions = input['suggestions'],
        sentence = input['sentence'];

  Map<String, dynamic> toJson() => {
        'wordWithError': wordWithError,
        'sentence': sentence,
        'suggestions': suggestions,
      };
}
