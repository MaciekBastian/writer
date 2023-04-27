enum FileType {
  editor,
  general,
  timelineEditor,
  plotDevelopment,
  threadEditor,
  characterEditor,
  system,
  userFile,
}

class FileTab {
  final FileType type;
  final String? path;
  final String? id;

  FileTab({
    required this.id,
    required this.path,
    required this.type,
  });
}
