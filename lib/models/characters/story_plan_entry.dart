class StoryPlanEntry {
  final String content;

  /// scene id or null
  final String? momentId;
  final int index;

  StoryPlanEntry({
    required this.content,
    required this.index,
    required this.momentId,
  });
}
