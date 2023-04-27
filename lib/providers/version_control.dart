import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../helpers/general_helper.dart';
import '../helpers/version_helper.dart';
import '../models/project.dart';
import '../models/version/version.dart';

class VersionControl with ChangeNotifier {
  Project? _project;

  bool get versionControlInitialized => _project != null;

  List<Version> _versions = [];
  List<Version> get versions {
    final copy = [..._versions];
    copy.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return copy;
  }

  Version? _current;

  bool get isVersioningEnabled {
    return _project != null && _current != null && _versions.isNotEmpty;
  }

  Version? get current => _current;

  bool _loading = false;
  bool get isLoading => _loading;
  bool _comparingLoading = false;
  bool get isComparingLoading => _comparingLoading;

  final List<VersionFile> _openedFiles = [];
  VersionFile? _currentFile;

  String? _currentlyComparing;
  Version? get currentlyComparing {
    if (_versions.any((element) => element.code == _currentlyComparing)) {
      return _versions.firstWhere(
        (element) => element.code == _currentlyComparing,
      );
    }
    return null;
  }

  void initialize(Project project) async {
    if (versionControlInitialized) return;
    _project = project;
    _versions = await VersionHelper().getAllVersions(project);
    _current = await VersionHelper().getCurrentVersion(project);
    notifyListeners();
  }

  void startVersioning() async {
    if (_project != null && _current == null && _versions.isEmpty) {
      _loading = true;
      notifyListeners();
      final code = GeneralHelper().id(8);
      final path = await VersionHelper().getDefaultPath(_project!);
      final version = Version(
        code: code,
        timestamp: DateTime.now(),
        path: p.join(path, '$code.xml'),
        commited: false,
      );
      try {
        final updated = await VersionHelper().addVersion(_project!, version);
        if (updated != null) {
          _versions.add(updated);
          _current = updated;
        }
      } catch (e) {
        _loading = false;
        notifyListeners();
      }
      _loading = false;
      notifyListeners();
    }
  }

  void commit([String? message]) async {
    if (_loading) return;
    if (!versionControlInitialized) return;
    if (_project == null) return;
    if (_current == null) return;
    if (_current!.commited) return;
    _loading = true;
    notifyListeners();
    try {
      final version = Version(
        code: _current!.code,
        timestamp: DateTime.now(),
        path: _current!.path,
        commited: true,
        message: message,
        previous: _current!.previous,
        size: _current!.size,
      );

      final updated = await VersionHelper().commitVersion(_project!, version);
      if (updated == null) {
        _loading = false;
        notifyListeners();
        return;
      }
      _versions.removeWhere((element) => element.code == version.code);
      _versions.add(updated);
      _current = updated;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = false;
    notifyListeners();
  }

  /// provide previous to create branch
  void startNewVersion([String? previous]) async {
    if (_loading) return;
    if (!versionControlInitialized) return;
    if (_project == null) return;
    if (_current == null) return;
    if (!_current!.commited) return;
    _loading = true;
    notifyListeners();
    final code = GeneralHelper().id(8);
    final path = await VersionHelper().getDefaultPath(_project!);
    final version = Version(
      code: code,
      timestamp: DateTime.now(),
      path: p.join(path, '$code.xml'),
      commited: false,
      previous: previous ?? _current!.code,
    );
    try {
      final updated = await VersionHelper().addVersion(_project!, version);
      if (updated != null) {
        _versions.add(updated);
        _current = updated;
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
    }
    _loading = false;
    notifyListeners();
  }

  /// returns list of versions that share the same `code` in `previous`. If none,
  /// returns an empty list
  List<Version> branches(String code) {
    return _versions.where((element) => element.previous == code).toList();
  }

  /// checksout to version with `code`, if exists. It replaces all the data with
  /// data from the version. It does NOT check if checkout is safe!
  void checkout(String code) async {}

  Future<bool> isCheckoutSafe() async {
    if (_current == null) return false;
    if (_project == null) return false;
    if (_versions.isEmpty) return false;
    if (!_current!.commited) return false;
    return VersionHelper().isCheckoutSafe(
      _project!.path,
      versions.first.timestamp,
    );
  }

  void compare(String code) async {
    if (_loading) return;
    if (!versionControlInitialized) return;
    if (_project == null) return;
    if (_current == null) return;
    if (_versions.isEmpty) return;
    _currentlyComparing = code;
    notifyListeners();
    if (currentlyComparing == null) return;
    _comparingLoading = true;
    VersionHelper().stageChanges(_project!, _current!).then((value) async {
      final currentVersoin = await VersionHelper().readVersion(_current!);
      if (currentVersoin != null) {
        _currentFile = currentVersoin;
      }
      notifyListeners();
    });

    if (_openedFiles.any((el) => el.code == _currentlyComparing)) {
      _comparingLoading = false;
      notifyListeners();
      return;
    }

    final version = await VersionHelper().readVersion(currentlyComparing!);
    if (version != null) {
      _openedFiles.add(version);
    }

    _comparingLoading = false;
    notifyListeners();
  }

  VersionFile? getCurrentlyComparedFile() {
    if (_currentlyComparing == null) return null;
    if (_project == null) return null;
    if (_openedFiles.any((element) => element.code == _currentlyComparing)) {
      return _openedFiles.firstWhere(
        (element) => element.code == _currentlyComparing,
      );
    }
    return null;
  }

  VersionFile? getCurrentVersionFile() => _currentFile;
}
