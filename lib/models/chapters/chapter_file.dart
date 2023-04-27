class ChapterFile {
  final String chapterId;
  final DateTime lastModified;
  final List content;

  ChapterFile({
    required this.chapterId,
    required this.content,
    required this.lastModified,
  });
}
