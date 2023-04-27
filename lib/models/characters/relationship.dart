class Relationship {
  final String person1Id;
  final String person2Id;
  final String person1Name;
  final String person2Name;
  final String description;

  Relationship({
    required this.description,
    required this.person1Id,
    required this.person1Name,
    required this.person2Id,
    required this.person2Name,
  });
}
