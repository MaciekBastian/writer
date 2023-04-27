class Occupation {
  static const unknown = '--unknown';
  static const before = '--before';
  static const after = '--after';

  final String id;
  final String occupation;

  /// either:
  ///
  /// * `id` of scene
  /// * one of special symbols: `--before`, `--after`, `--unknown`
  final String start;

  /// either:
  ///
  /// * `id` of scene
  /// * one of special symbols: `--before`, `--after`, `--unknown`
  final String end;

  Occupation({
    required this.id,
    required this.occupation,
    this.start = Occupation.unknown,
    this.end = Occupation.unknown,
  });

  Occupation copyWith({
    String? occupation,
    String? start,
    String? end,
  }) {
    return Occupation(
      id: id,
      occupation: occupation ?? this.occupation,
      end: end ?? this.end,
      start: start ?? this.start,
    );
  }
}
