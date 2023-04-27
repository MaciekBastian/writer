class Scene {
  final String id;
  final String? name;
  final int index;
  final String? time;
  final String description;
  final Map<String, String> threads;

  Scene({
    required this.id,
    required this.index,
    this.description = '',
    this.threads = const {},
    this.name,
    this.time,
  });

  Scene copyWith({
    String? name,
    int? index,
    String? time,
    String? description,
    Map<String, String>? threads,
  }) {
    return Scene(
      id: id,
      name: name ?? this.name,
      index: index ?? this.index,
      time: time ?? this.time,
      description: description ?? this.description,
      threads: threads ?? this.threads,
    );
  }
}
