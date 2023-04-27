class WorkingTree<T> {
  final T currentVersion;
  final Map<DateTime, T> changes;
  final Map<DateTime, T> undoneChanges;

  WorkingTree({
    required this.currentVersion,
    required this.changes,
    required this.undoneChanges,
  });

  WorkingTree.empty(T version)
      : currentVersion = version,
        changes = {},
        undoneChanges = {};

  WorkingTree<T> newChange(T oldVersion, T newVersion) {
    return WorkingTree<T>(
      currentVersion: newVersion,
      changes: {
        DateTime.now(): oldVersion,
        ...changes,
      },
      undoneChanges: {},
    );
  }

  WorkingTree<T>? undo() {
    if (changes.isEmpty) return null;
    final keys = [...changes.keys.toList()];
    keys.sort((a, b) => a.compareTo(b));
    final lastVersion = changes[keys.last];
    if (lastVersion == null) return null;

    final changesCopy = {...changes};
    changesCopy.remove(keys.last);

    return WorkingTree<T>(
      currentVersion: lastVersion,
      changes: changesCopy,
      undoneChanges: {
        DateTime.now(): currentVersion,
        ...undoneChanges,
      },
    );
  }

  WorkingTree<T>? redo() {
    if (undoneChanges.isEmpty) return null;
    final keys = [...undoneChanges.keys.toList()];
    keys.sort((a, b) => a.compareTo(b));
    final lastVersion = undoneChanges[keys.last];
    if (lastVersion == null) return null;

    final changesCopy = {...undoneChanges};
    changesCopy.remove(keys.last);

    return WorkingTree<T>(
      currentVersion: lastVersion,
      changes: {
        DateTime.now(): currentVersion,
        ...changes,
      },
      undoneChanges: changesCopy,
    );
  }

  bool get canUndo => changes.isNotEmpty;
  bool get canRedo => undoneChanges.isNotEmpty;

  WorkingTree<T> clear() {
    return WorkingTree(
      currentVersion: currentVersion,
      changes: {},
      undoneChanges: {},
    );
  }
}
