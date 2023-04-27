import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../constants/system_pages.dart';
import '../helpers/search_helper.dart';
import '../models/chapters/chapter.dart';
import '../models/chapters/chapter_file.dart';
import '../models/search_result.dart';
import '../models/settings_enums.dart';
import '../models/working_tree.dart';
import '../helpers/errors.dart';
import '../helpers/general_helper.dart';
import '../helpers/project_helper.dart';
import '../models/chapters/scene.dart';
import '../models/characters/character.dart';
import '../models/file_tab.dart';
import '../models/project.dart';

import '../models/error/project_error.dart';
import '../models/sidebar_tab.dart';
import '../models/threads/thread.dart';

class ProjectState with ChangeNotifier {
  final List<FileTab> _openedTabs = [];
  List<FileTab> get openedTabs => [..._openedTabs];
  final List<FileTab> _changedTabs = [];
  final List<FileTab> _pinnedTabs = [];
  Map<String, String> _charactersSnippet = {};
  Map<String, String> _threadsSnippet = {};
  Map<String, dynamic> _projectPrefferences = {};

  Map<String, String> get characters {
    final charactersCopy = {..._charactersSnippet}.entries.toList();
    charactersCopy.sort((a, b) => a.value.compareTo(b.value));
    return charactersCopy.asMap().map((key, value) {
      return MapEntry(value.key, value.value);
    });
  }

  Map<String, String> get threads {
    final threadsCopy = {..._threadsSnippet}.entries.toList();
    threadsCopy.sort((a, b) => a.value.compareTo(b.value));
    return threadsCopy.asMap().map((key, value) {
      return MapEntry(value.key, value.value);
    });
  }

  final List<Character> _characters = [];
  final List<Thread> _threads = [];
  List<Chapter> _chapters = [];
  final List<ChapterFile> _editors = [];

  List<Character> get openedCharacters => [..._characters];

  Chapter getChapter(String id) {
    return _chapters.firstWhere((element) => element.id == id);
  }

  ChapterFile? getEditor(String chapterId) {
    if (!(_editors.any((element) => element.chapterId == chapterId))) {
      return null;
    }
    return _editors.firstWhere((element) => element.chapterId == chapterId);
  }

  List<Chapter> get chapters => [..._chapters];
  Map<String, String> get chaptersAsMap {
    return _chapters.asMap().map((key, value) {
      return MapEntry(
        value.id,
        value.name,
      );
    });
  }

  List<Scene> get scenes {
    final chaptersCopy = chapters;
    chaptersCopy.sort((a, b) => a.index.compareTo(b.index));
    List<Scene> result = [];
    for (var x in chaptersCopy) {
      final scenesCopy = [...x.scenes];
      scenesCopy.sort((a, b) => a.index.compareTo(b.index));
      result.addAll(scenesCopy);
    }
    return result;
  }

  int _currentlyOpened = -1;

  bool isSelected(int index) => index == _currentlyOpened;
  bool hasUnsavedChanges(int index) {
    return _changedTabs.contains(
      _openedTabs[index],
    );
  }

  FileType? get selectedFileType {
    if (_currentlyOpened == -1) return null;
    return _openedTabs[_currentlyOpened].type;
  }

  FileTab? get selectedTab {
    if (_currentlyOpened == -1) return null;
    return _openedTabs[_currentlyOpened];
  }

  bool get isSelectedSaved {
    final selected = selectedTab;
    return !_changedTabs.contains(selected);
  }

  bool get isAnyTabSelected {
    return _currentlyOpened != -1;
  }

  bool isSaved(int index) {
    return !_changedTabs.contains(_openedTabs[index]);
  }

  int get selectedIndex => _currentlyOpened;

  Project? _currentProject;
  Project? get project => _currentProject;

  bool get isProjectOpened => _currentProject != null;

  bool _projectInitialized = true;
  bool get initialized => _projectInitialized;

  bool get containsUnsaved => _changedTabs.isNotEmpty;
  int get unsavedCount => _changedTabs.length;

  SidebarTab _sidebarTab = SidebarTab.project;
  SidebarTab get currentSidebarTab => _sidebarTab;
  bool _rightSidebar = false;
  RightSidebarTab _rightSidebarTab = RightSidebarTab.snippets;
  RightSidebarTab get rightSidebarTab => _rightSidebarTab;
  bool get rightSidebar => _rightSidebar;

  List<ProjectError> _errors = [];
  List<ProjectError> get errors {
    final errorsCopy = [..._errors];
    final ignored = ignoredErrors;
    final errorsIgnored = errorsCopy
        .where((element) => ignored.contains(element.errorId))
        .toList();
    final errorsNotIgnored = errorsCopy
        .where((element) => !(ignoredErrors.contains(element.errorId)))
        .toList();
    errorsNotIgnored.sort((a, b) => a.type.index.compareTo(b.type.index));
    errorsIgnored.sort((a, b) => a.type.index.compareTo(b.type.index));

    return [...errorsNotIgnored, ...errorsIgnored];
  }

  bool fileContainsErrors(FileTab tab) {
    final err = errors.where((element) {
      return (tab.id == null
              ? element.whereTypes.contains(tab.type)
              : (element.whereIds?.contains(tab.id ?? '') ?? false)) &&
          isErrorIgnored(element.errorId) == false;
    }).toList();

    return err.isNotEmpty;
  }

  List<ProjectError> errorsForFile(FileTab tab) {
    final err = errors.where((element) {
      return (tab.id == null
              ? element.whereTypes.contains(tab.type)
              : (element.whereIds?.contains(tab.id ?? '') ?? false)) &&
          isErrorIgnored(element.errorId) == false;
    }).toList();
    return err;
  }

  bool _isLookingForErrors = false;

  bool _errorPanelOpened = false;
  bool get isErrorPanelOpened => _errorPanelOpened;

  bool isErrorIgnored(String id) => ignoredErrors.contains(id);

  bool get isProjectBeingAnalized => _isLookingForErrors;

  List<DateTime> get savedDates {
    return (_projectPrefferences['saved_dates'] as List? ?? [])
        .map((e) => DateTime.parse(e.toString()))
        .toList();
  }

  void saveDate(DateTime day) async {
    final date = DateTime(day.year, day.month, day.day);
    if (savedDates.contains(date)) return;
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'saved_dates',
      [
        ...savedDates.map((e) => e.toIso8601String()).toList(),
        date.toIso8601String(),
      ],
    );
    _projectPrefferences['saved_dates'] = [
      ...savedDates.map((e) => e.toIso8601String()).toList(),
      date.toIso8601String(),
    ];
    notifyListeners();
  }

  void deleteDate(DateTime day) async {
    final date = DateTime(day.year, day.month, day.day);
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'saved_dates',
      [
        ...savedDates
            .where((element) => !element.isAtSameMomentAs(date))
            .map((e) => e.toIso8601String())
            .toList(),
      ],
    );
    _projectPrefferences['saved_dates'] = [
      ...savedDates
          .where((element) => !element.isAtSameMomentAs(date))
          .map((e) => e.toIso8601String())
          .toList()
    ];
    notifyListeners();
  }

  int get errorsCount {
    final errorsCopy = [..._errors];
    final errorsNotIgnored = errorsCopy
        .where((element) => !(ignoredErrors.contains(element.errorId)))
        .toList();
    return errorsNotIgnored.length;
  }

  List<String> get ignoredErrors {
    return ((_projectPrefferences['ignored_errors'] as List?) ?? []).map((e) {
      return e.toString();
    }).toList();
  }

  bool visibilityForProjectTabFile(SidebarProjectTabElement element) {
    switch (element) {
      case SidebarProjectTabElement.general:
        return _projectPrefferences['project_tab_general'] ?? true;
      case SidebarProjectTabElement.chapters:
        return _projectPrefferences['project_tab_chapters'] ?? true;
      case SidebarProjectTabElement.timeline:
        return _projectPrefferences['project_tab_timeline'] ?? true;
      case SidebarProjectTabElement.plotDevelopment:
        return _projectPrefferences['project_tab_plot_development'] ?? true;
      case SidebarProjectTabElement.threads:
        return _projectPrefferences['project_tab_threads'] ?? true;
      case SidebarProjectTabElement.characters:
        return _projectPrefferences['project_tab_characters'] ?? true;
      case SidebarProjectTabElement.calendar:
        return _projectPrefferences['project_tab_calendar'] ?? false;
      case SidebarProjectTabElement.dictionary:
        return _projectPrefferences['project_tab_dictionary'] ?? false;
      case SidebarProjectTabElement.charactersReport:
        return _projectPrefferences['project_tab_characters_report'] ?? false;
      case SidebarProjectTabElement.fileExplorer:
        return _projectPrefferences['project_tab_files'] ?? false;
    }
  }

  void toggleVisibilityForProjectTabFile(SidebarProjectTabElement el) async {
    late String name;
    switch (el) {
      case SidebarProjectTabElement.general:
        name = 'project_tab_general';
        break;
      case SidebarProjectTabElement.chapters:
        name = 'project_tab_chapters';
        break;
      case SidebarProjectTabElement.timeline:
        name = 'project_tab_timeline';
        break;
      case SidebarProjectTabElement.plotDevelopment:
        name = 'project_tab_plot_development';
        break;
      case SidebarProjectTabElement.threads:
        name = 'project_tab_threads';
        break;
      case SidebarProjectTabElement.characters:
        name = 'project_tab_characters';
        break;
      case SidebarProjectTabElement.calendar:
        name = 'project_tab_calendar';
        break;
      case SidebarProjectTabElement.dictionary:
        name = 'project_tab_dictionary';
        break;
      case SidebarProjectTabElement.charactersReport:
        name = 'project_tab_characters_report';
        break;
      case SidebarProjectTabElement.fileExplorer:
        name = 'project_tab_files';
        break;
    }

    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      name,
      !(visibilityForProjectTabFile(el)),
    );
    _projectPrefferences[name] = !(visibilityForProjectTabFile(el));
    notifyListeners();
  }

  bool _tabSwitcher = false;
  bool get isTabSwitcherOpened => _tabSwitcher;

  void toggleTabSwitcher() {
    _tabSwitcher = !_tabSwitcher;
    notifyListeners();
  }

  bool get tooltips => _projectPrefferences['tooltips'] ?? true;
  bool get replaceAutoShown => _projectPrefferences['replace_auto'] ?? false;
  bool get highlightErrors => _projectPrefferences['errors_highlight'] ?? false;
  bool get allowMultiwindow => _projectPrefferences['multiwindow'] ?? false;
  bool get openEditors => _projectPrefferences['open_editors'] ?? false;
  bool get commandPaletteButton => _projectPrefferences['cmd_palette'] ?? true;
  bool get ctrlTabAutoClose => _projectPrefferences['ctrl_tab_close'] ?? true;
  bool get statusBarSave => _projectPrefferences['status_save'] ?? true;
  bool get statusBarErrors => _projectPrefferences['status_errors'] ?? true;
  bool get statusBarWordCount => _projectPrefferences['status_words'] ?? true;
  bool get statusBarVersion => _projectPrefferences['status_version'] ?? true;
  bool get showRightSidebar => _projectPrefferences['right_sidebar'] ?? false;
  bool get smallScreenView => _projectPrefferences['compact'] ?? false;

  void toggleStatusBar(int index) async {
    final defaults = {
      'status_save': true,
      'status_errors': true,
      'status_words': true,
      'status_version': true,
    };
    final options = defaults.keys.toList();
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      options[index],
      !(_projectPrefferences[options[index]] ?? defaults[options[index]]),
    );
    _projectPrefferences[options[index]] =
        !(_projectPrefferences[options[index]] ?? defaults[options[index]]);
    notifyListeners();
  }

  TabBarVisibility get tabBarVisibility {
    return TabBarVisibility.values.firstWhere((element) {
      return element.name ==
          (_projectPrefferences['tab_bar'] ?? TabBarVisibility.top.name);
    });
  }

  FilesOrder get filesOrder {
    return FilesOrder.values.firstWhere((element) {
      return element.name ==
          (_projectPrefferences['files_order'] ?? FilesOrder.defaultOrder.name);
    });
  }

  void toggleTooltips() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'tooltips',
      !(_projectPrefferences['tooltips'] ?? true),
    );
    _projectPrefferences['tooltips'] =
        !(_projectPrefferences['tooltips'] ?? true);
    notifyListeners();
  }

  void toggleComandPaletteButton() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'cmd_palette',
      !(_projectPrefferences['cmd_palette'] ?? true),
    );
    _projectPrefferences['cmd_palette'] =
        !(_projectPrefferences['cmd_palette'] ?? true);
    notifyListeners();
  }

  void toggleCtrlTabAutoClose() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'ctrl_tab_close',
      !(_projectPrefferences['ctrl_tab_close'] ?? true),
    );
    _projectPrefferences['ctrl_tab_close'] =
        !(_projectPrefferences['ctrl_tab_close'] ?? true);
    notifyListeners();
  }

  void toggleReplaceAutoShown() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'replace_auto',
      !(_projectPrefferences['replace_auto'] ?? true),
    );
    _projectPrefferences['replace_auto'] =
        !(_projectPrefferences['replace_auto'] ?? true);
    notifyListeners();
  }

  void switchErrorPanel() {
    _errorPanelOpened = !_errorPanelOpened;
    notifyListeners();
  }

  void toggleHighlighErrors() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'errors_highlight',
      !(_projectPrefferences['errors_highlight'] ?? false),
    );
    _projectPrefferences['errors_highlight'] =
        !(_projectPrefferences['errors_highlight'] ?? false);
    notifyListeners();
  }

  void toggleMultiwindow() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'multiwindow',
      !(_projectPrefferences['multiwindow'] ?? false),
    );
    _projectPrefferences['multiwindow'] =
        !(_projectPrefferences['multiwindow'] ?? false);
    notifyListeners();
  }

  void toggleShowRightSidebar() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'right_sidebar',
      !(_projectPrefferences['right_sidebar'] ?? false),
    );
    _projectPrefferences['right_sidebar'] =
        !(_projectPrefferences['right_sidebar'] ?? false);
    notifyListeners();
  }

  void toggleSmallScreenView() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'compact',
      !(_projectPrefferences['compact'] ?? false),
    );
    _projectPrefferences['compact'] =
        !(_projectPrefferences['compact'] ?? false);
    notifyListeners();
  }

  void toggleOpenEditors() async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'open_editors',
      !(_projectPrefferences['open_editors'] ?? false),
    );
    _projectPrefferences['open_editors'] =
        !(_projectPrefferences['open_editors'] ?? false);
    notifyListeners();
  }

  void changeTabBarVisibility(TabBarVisibility visibility) async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'tab_bar',
      visibility.name,
    );
    _projectPrefferences['tab_bar'] = visibility.name;
    notifyListeners();
  }

  void changeFilesOrderMode(FilesOrder order) async {
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'files_order',
      order.name,
    );
    _projectPrefferences['files_order'] = order.name;
    notifyListeners();
  }

  void changeFilesOrder(List<FileTab> files) async {
    if (_currentProject == null) return;
    if (filesOrder != FilesOrder.custom) return;
    final order = files.map((e) {
      return [e.type.name, e.path];
    }).toList();
    _projectPrefferences['cursom_files_order'] = order;
    await ProjectHelper().setProjectPrefference(
      _currentProject!,
      'cursom_files_order',
      order,
    );
    notifyListeners();
  }

  /// Handle ordering on your own, list is in default order
  List<FileTab> getAllFiles() {
    return [
      if (visibilityForProjectTabFile(SidebarProjectTabElement.chapters))
        FileTab(id: null, path: null, type: FileType.editor),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.general))
        FileTab(id: null, path: null, type: FileType.general),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.timeline))
        FileTab(id: null, path: null, type: FileType.timelineEditor),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.plotDevelopment))
        FileTab(id: null, path: null, type: FileType.plotDevelopment),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.threads))
        FileTab(id: null, path: null, type: FileType.threadEditor),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.characters))
        FileTab(id: null, path: null, type: FileType.characterEditor),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.calendar))
        FileTab(
          id: null,
          path: systemPagesPathsForSidebar[SidebarProjectTabElement.calendar],
          type: FileType.system,
        ),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.dictionary))
        FileTab(
          id: null,
          path: systemPagesPathsForSidebar[SidebarProjectTabElement.dictionary],
          type: FileType.system,
        ),
      if (visibilityForProjectTabFile(SidebarProjectTabElement.fileExplorer))
        FileTab(
          id: null,
          path:
              systemPagesPathsForSidebar[SidebarProjectTabElement.fileExplorer],
          type: FileType.system,
        ),
      if (visibilityForProjectTabFile(
          SidebarProjectTabElement.charactersReport))
        FileTab(
          id: null,
          path: systemPagesPathsForSidebar[
              SidebarProjectTabElement.charactersReport],
          type: FileType.system,
        ),
    ];
  }

  List<FileTab> getCustomOrder() {
    final order = _projectPrefferences['cursom_files_order'] as List?;
    final all = getAllFiles();
    if (order == null) return all;
    final custom = order.map((e) => e as List).map(
      (e) {
        return FileTab(
          id: null,
          path: e[1]?.toString(),
          type: FileType.values.firstWhere(
            (element) => element.name == e.first.toString(),
          ),
        );
      },
    ).toList();
    return custom.where((element) {
      return all.any((el) => element.path != null
          ? el.path == element.path
          : el.type == element.type);
    }).toList();
  }

  Future<Project?> createProject(String path, [String? name]) async {
    try {
      final project = await ProjectHelper().createNewProject(path, name);
      _currentProject = project;
      notifyListeners();
      return project;
    } catch (e) {
      return null;
    }
  }

  Future<Project?> openProject(String path) async {
    try {
      final project = await ProjectHelper().loadProject(path);
      _currentProject = project;
      final allCharacters = await ProjectHelper().getAllCharacters(project);
      _charactersSnippet = allCharacters;
      final allThreads = await ProjectHelper().getAllThreads(project);
      _threadsSnippet = allThreads;
      _projectPrefferences = await ProjectHelper().getProjectPrefferences(
        project,
      );
      _projectInitialized = false;
      notifyListeners();
      _chapters = await ProjectHelper().getAllChapters(project);
      notifyListeners();
      lookForErrors();
      _projectInitialized = true;
      return project;
    } catch (e) {
      return null;
    }
  }

  void closeProject() async {
    if (_currentProject == null) return;
    if (_changedTabs.isNotEmpty) return;
    _currentProject = null;
    _currentlyOpened = -1;
    _openedTabs.clear();
    _changedTabs.clear();
    _characters.clear();
    _chapters.clear();
    _charactersSnippet.clear();
    _editors.clear();
    _pinnedTabs.clear();
    _projectInitialized = false;
    _projectPrefferences.clear();
    _projectSearchQuery = null;
    _projectSearchResults.clear();
    _threads.clear();
    _threadsSnippet.clear();
    _workingTrees.clear();
    notifyListeners();
  }

  Future<void> reloadProject() async {
    if (_currentProject == null) return;
    _projectInitialized = false;
    notifyListeners();
    await openProject(_currentProject!.path);
  }

  Future<List<String>> recentProjects() async {
    var projects = await ProjectHelper().getRecentProjects();
    projects = projects
        .getRange(0, projects.length > 5 ? 5 : projects.length)
        .toList();
    return projects;
  }

  void openTab(FileTab tab) {
    if (_currentProject == null) return;
    final alreadyOpened = _openedTabs.any(
      (element) {
        if (element.type == FileType.characterEditor ||
            element.type == FileType.threadEditor ||
            element.type == FileType.editor) {
          return element.id == tab.id;
        } else {
          return element.type == tab.type && element.path == tab.path;
        }
      },
    );
    if (!alreadyOpened) {
      _openedTabs.add(tab);
      _currentlyOpened = _openedTabs.indexOf(tab);
      notifyListeners();
    } else {
      switchTab(indexOfTab(tab));
    }
  }

  void openTabInBackground(FileTab tab) {
    if (_currentProject == null) return;
    final alreadyOpened = _openedTabs.any(
      (element) {
        if (element.type == FileType.characterEditor ||
            element.type == FileType.threadEditor ||
            element.type == FileType.editor) {
          return element.id == tab.id;
        } else {
          return element.type == tab.type && element.path == tab.path;
        }
      },
    );
    if (alreadyOpened) return;
    _openedTabs.add(tab);
    notifyListeners();
  }

  int indexOfTab(FileTab element) {
    return _openedTabs.indexWhere((tab) {
      if (element.type == FileType.characterEditor ||
          element.type == FileType.threadEditor ||
          element.type == FileType.editor) {
        return element.id == tab.id;
      } else {
        return element.type == tab.type && element.path == tab.path;
      }
    });
  }

  void closeTab(int index) {
    final opened = selectedTab;
    if (index == -1) return;
    if (index >= _openedTabs.length) return;
    final removed = _openedTabs.removeAt(index);
    if (_pinnedTabs.contains(removed)) {
      _pinnedTabs.remove(removed);
    }
    if (_openedTabs.isEmpty) {
      _currentlyOpened = -1;
    } else {
      if (_currentlyOpened == index) {
        final plusOneIndex = index + 1;
        final minusOneIndex = index - 1;
        if (minusOneIndex == -1) {
          if (plusOneIndex < _openedTabs.length) {
            _currentlyOpened = plusOneIndex;
          }
        } else {
          _currentlyOpened = minusOneIndex;
        }
      } else {
        if (opened != null) {
          _currentlyOpened = _openedTabs.indexOf(opened);
        }
      }
    }
    if (_changedTabs.contains(removed)) {
      if (removed.type == FileType.characterEditor ||
          removed.type == FileType.threadEditor ||
          removed.type == FileType.general) {
        if (removed.type == FileType.characterEditor) {
          final character = _characters.firstWhere((element) {
            return element.id == removed.id;
          });
          final clearedTree = character.workingTree?.clear();
          if (clearedTree != null) {
            final index = _characters.indexOf(character);
            _characters.removeAt(index);
            _characters.insert(index, Character.fromWorkingTree(clearedTree));
          }
        }
      }
      _changedTabs.remove(removed);
    }
    notifyListeners();
  }

  void closeToTheRight([int? index]) {
    if ((index ?? _currentlyOpened) == -1) return;
    if ((index ?? _currentlyOpened) == _openedTabs.length - 1) return;
    saveAll();
    final tab = _openedTabs[index ?? _currentlyOpened];
    final copy = [..._openedTabs]
        .getRange(
          (index ?? _currentlyOpened) + 1,
          _openedTabs.length,
        )
        .toList();
    _changedTabs.removeWhere(
      (element) => !_pinnedTabs.contains(element) && copy.contains(element),
    );
    _openedTabs.removeWhere(
      (element) => !_pinnedTabs.contains(element) && copy.contains(element),
    );
    _currentlyOpened = _openedTabs.indexOf(tab);
    notifyListeners();
  }

  void closeSaved() {
    _openedTabs.removeWhere(
      (element) {
        return !_pinnedTabs.contains(element) &&
            !_changedTabs.contains(element);
      },
    );
    if (_openedTabs.isNotEmpty) {
      _currentlyOpened = 0;
    } else {
      _currentlyOpened = -1;
    }
    notifyListeners();
  }

  void closeOthers(FileTab tab) {
    saveAll();
    _changedTabs.removeWhere(
      (element) => !_pinnedTabs.contains(element) && element != tab,
    );
    _openedTabs.removeWhere(
      (element) => !_pinnedTabs.contains(element) && element != tab,
    );
    final index = _openedTabs.indexOf(tab);
    _currentlyOpened = index;
    notifyListeners();
  }

  void closeAll() {
    _changedTabs.removeWhere((element) => !_pinnedTabs.contains(element));
    _openedTabs.removeWhere((element) => !_pinnedTabs.contains(element));
    if (_openedTabs.isNotEmpty) {
      _currentlyOpened = 0;
    } else {
      _currentlyOpened = -1;
    }
    notifyListeners();
  }

  void switchTab(int newTabIndex) {
    _currentlyOpened = newTabIndex;
    notifyListeners();
  }

  void registerChange(FileTab tab) {
    if (!(_changedTabs.contains(tab))) {
      _changedTabs.add(tab);
    }
  }

  void updateProjectConfig(FileTab tab, Project newProject) {
    _currentProject = newProject;
    registerChange(tab);
    notifyListeners();
  }

  Future<void> saveGeneralFile() async {
    if (_currentProject == null) return;
    await ProjectHelper().overrideProject(_currentProject!);
    _changedTabs.removeWhere((element) => element.type == FileType.general);
    notifyListeners();
  }

  Object? _tabSavingIdentifier;
  bool isTabBeingSaved(FileTab tab) {
    if (_tabSavingIdentifier == null) return false;
    if (_tabSavingIdentifier is String) {
      return tab.path == _tabSavingIdentifier || tab.id == _tabSavingIdentifier;
    } else if (_tabSavingIdentifier is FileType) {
      return tab.type == _tabSavingIdentifier;
    }
    return false;
  }

  Future<void> save([FileTab? picked]) async {
    if (_tabSavingIdentifier != null) return;
    if (_currentProject == null) return;
    final tab = picked ?? selectedTab;
    if (tab != null) {
      switch (tab.type) {
        case FileType.general:
          _tabSavingIdentifier = FileType.general;
          notifyListeners();
          // wait for all pending events (for example registering change from text field takes exactly 600ms)
          // if user tires to save file again, the next request will be ignored, until `_tabSavingIdentifier`
          // is not null
          await Future.delayed(const Duration(milliseconds: 600));
          saveGeneralFile();
          break;
        case FileType.timelineEditor:
          _tabSavingIdentifier = FileType.timelineEditor;
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 600));
          saveTimelineFile();
          break;
        case FileType.threadEditor:
          if (tab.id == null) break;
          _tabSavingIdentifier = tab.id;
          await saveThreadFile(tab.id!);
          break;
        case FileType.characterEditor:
          if (tab.id == null) break;
          _tabSavingIdentifier = tab.id;
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 600));
          await saveCharacterFile(tab.id!);
          break;
        case FileType.plotDevelopment:
          // no edit here, view-only file
          break;
        case FileType.system:
          // no edit here, view-only file
          break;
        case FileType.editor:
          if (tab.id == null) break;
          _tabSavingIdentifier = tab.id;
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 600));
          final change = getEditor(tab.id!);
          if (change == null) break;
          await ProjectHelper().updateChapterEditor(
            tab.id!,
            _currentProject!,
            change.content,
          );
          _changedTabs.removeWhere((element) {
            return element.type == FileType.editor && element.id == tab.id;
          });
          break;
        case FileType.userFile:
          // files are read-only
          break;
      }
    }
    _tabSavingIdentifier = null;
    notifyListeners();
    await lookForErrors();
  }

  void pinTab(FileTab tab) {
    if (_pinnedTabs.contains(tab)) return;
    _pinnedTabs.add(tab);
    final index = _openedTabs.indexOf(tab);
    if (index == _currentlyOpened) {
      _currentlyOpened = 0;
    } else {
      _currentlyOpened += 1;
      if (_currentlyOpened == _openedTabs.length) _currentlyOpened = 0;
    }
    _openedTabs.remove(tab);
    _openedTabs.insert(0, tab);
    notifyListeners();
  }

  void unpinTab(FileTab tab) {
    if (_pinnedTabs.contains(tab)) {
      _pinnedTabs.remove(tab);
      if (_pinnedTabs.isNotEmpty) {
        _openedTabs.remove(tab);
        _openedTabs.insert(_pinnedTabs.length, tab);
      }
      notifyListeners();
    }
  }

  bool isTabPinned([FileTab? tab]) {
    if (_currentlyOpened == -1) return false;
    tab ??= _openedTabs[_currentlyOpened];
    return _pinnedTabs.contains(tab);
  }

  Future<void> lookForErrors() async {
    _isLookingForErrors = true;
    notifyListeners();
    final errorMessages = await ErrorsHelper().lookForErrors(_currentProject!);
    if (errorMessages != null) {
      _errors = errorMessages;
      _isLookingForErrors = false;
      notifyListeners();
    } else {
      _isLookingForErrors = false;
      notifyListeners();
    }
  }

  void saveAll() async {
    for (var tab in _openedTabs) {
      if (_changedTabs.contains(tab)) {
        await save(tab);
      }
    }
    _changedTabs.clear();
    notifyListeners();
  }

  void revertChanges(FileTab tab) async {
    switch (tab.type) {
      case FileType.general:
        final lastCopy = await ProjectHelper().loadProject(
          _currentProject!.path,
        );
        _currentProject = lastCopy;
        _changedTabs.removeWhere((element) => element.type == FileType.general);
        notifyListeners();
        break;
      case FileType.timelineEditor:
        // TODO: Handle this case.
        break;
      case FileType.threadEditor:
        if (tab.id == null) break;
        try {
          final thread = getThread(tab.id!);
          final index = _threads.indexOf(thread);
          _changedTabs.removeWhere((element) => element.id == tab.id);
          _threads.removeAt(index);
          _threadsSnippet.remove(thread.id);
          try {
            final lastSnapshot = await ProjectHelper().getThread(
              tab.id!,
              _currentProject!,
            );
            _threads.insert(index, lastSnapshot);
            _threadsSnippet[thread.id] = lastSnapshot.name;
            notifyListeners();
          } catch (e) {
            notifyListeners();
            break;
          }
        } catch (e) {
          break;
        }
        break;
      case FileType.characterEditor:
        if (tab.id == null) break;
        try {
          final character = getCharacter(tab.id!);
          final index = _characters.indexOf(character);
          _changedTabs.removeWhere((element) => element.id == tab.id);
          _characters.removeAt(index);
          _charactersSnippet.remove(character.id);
          try {
            final lastSnapshot = await ProjectHelper().getCharacter(
              tab.id!,
              _currentProject!,
            );
            _characters.insert(index, lastSnapshot);
            _charactersSnippet[character.id] = lastSnapshot.name;
            notifyListeners();
          } catch (e) {
            notifyListeners();
            break;
          }
        } catch (e) {
          break;
        }
        break;
      case FileType.plotDevelopment:
        // TODO: Handle this case.
        break;
      case FileType.system:
        // TODO: Handle this case.
        break;
      case FileType.editor:
        if (tab.id == null) break;
        if (_currentProject == null) break;
        _editors.removeWhere((element) => element.chapterId == tab.id);
        _editors.add(
          await ProjectHelper().openChapterEditor(
            tab.id!,
            _currentProject!,
          ),
        );
        _changedTabs.removeWhere((element) => element.id == tab.id);
        break;
      case FileType.userFile:
        // files are read-only
        break;
    }
  }

  Character getCharacter(String id) {
    return _characters.firstWhere((element) => element.id == id);
  }

  void addCharacter() {
    final character = Character(
      id: GeneralHelper().id(),
      name: 'New Character',
    );
    _characters.add(character);
    _charactersSnippet.addEntries([MapEntry(character.id, character.name)]);
    final tab = FileTab(
      id: character.id,
      path: null,
      type: FileType.characterEditor,
    );
    openTab(tab);
    registerChange(tab);
    notifyListeners();
  }

  void updateCharacter(Character character) {
    final currentSnapshot = _characters.firstWhere((el) {
      return el.id == character.id;
    });
    final index = _characters.indexOf(currentSnapshot);
    _characters.removeAt(index);
    _characters.insert(index, character);
    _charactersSnippet[character.id] = character.name;
    if (_openedTabs.any((element) => element.id == character.id)) {
      final tab = _openedTabs.firstWhere((element) {
        return element.id == character.id;
      });
      registerChange(tab);
    }
    notifyListeners();
  }

  Future<Character?> getUpToDateCharacterWithoutOpening(String id) async {
    if (_currentProject == null) return null;
    final isOpened = _characters.any((el) {
      return el.id == id;
    });
    if (!isOpened) {
      final character =
          await ProjectHelper().getCharacter(id, _currentProject!);
      _characters.add(character);
      return character;
    } else {
      return getCharacter(id);
    }
  }

  void openCharacter(String id) async {
    if (_currentProject == null) return;
    final isOpened = _characters.any((el) {
      return el.id == id;
    });
    if (!isOpened) {
      final character = await ProjectHelper().getCharacter(
        id,
        _currentProject!,
      );
      _characters.add(character);
    }
    final tab = _openedTabs.firstWhere(
      (element) {
        return element.id == id;
      },
      orElse: () => FileTab(
        id: id,
        path: null,
        type: FileType.characterEditor,
      ),
    );
    openTab(tab);
    notifyListeners();
  }

  void deleteCharacter(String id) async {
    if (_currentProject == null) return;
    final index = _openedTabs.indexWhere((element) => element.id == id);
    if (index != -1) {
      closeTab(index);
    }
    _characters.removeWhere((el) => el.id == id);
    _changedTabs.removeWhere((element) => element.id == id);
    _charactersSnippet.remove(id);
    final refreshedCharacters = await ProjectHelper().deleteCharacter(
      id,
      _currentProject!,
    );
    _charactersSnippet = refreshedCharacters;
    notifyListeners();
  }

  Future<void> saveCharacterFile(String id) async {
    try {
      if (_currentProject == null) return;
      final character = _characters.firstWhere((element) => element.id == id);
      _charactersSnippet = await ProjectHelper().overrideCharacter(
        character,
        _currentProject!,
      );
      _changedTabs.removeWhere((element) {
        return element.type == FileType.characterEditor && element.id == id;
      });
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  void switchSidebarTab(SidebarTab newTab) {
    _sidebarTab = newTab;
    notifyListeners();
  }

  void switchRightSidebarTab(RightSidebarTab newTab) {
    _rightSidebarTab = newTab;
    notifyListeners();
  }

  void toggleRightSidebar([bool? force]) {
    _rightSidebar = force ?? !_rightSidebar;
    notifyListeners();
  }

  void ignoreError(String id) async {
    if (_currentProject == null) return;
    final alreadyIgnored = ignoredErrors;
    final isIgnored = alreadyIgnored.contains(id);
    if (!isIgnored) {
      _projectPrefferences['ignored_errors'] = [...alreadyIgnored, id];
      await ProjectHelper().setProjectPrefference(
        _currentProject!,
        'ignored_errors',
        [...alreadyIgnored, id],
      );
      notifyListeners();
    } else {
      final ignoredCopy = [...alreadyIgnored];
      ignoredCopy.remove(id);
      _projectPrefferences['ignored_errors'] = ignoredCopy;
      await ProjectHelper().setProjectPrefference(
        _currentProject!,
        'ignored_errors',
        ignoredCopy,
      );
      notifyListeners();
    }
  }

  Thread getThread(String id) {
    return _threads.firstWhere((element) => element.id == id);
  }

  void addThread() {
    final thread = Thread(
      id: GeneralHelper().id(),
      name: 'New Thread',
    );
    _threads.add(thread);
    _threadsSnippet.addEntries([MapEntry(thread.id, thread.name)]);
    final tab = FileTab(
      id: thread.id,
      path: null,
      type: FileType.threadEditor,
    );
    openTab(tab);
    registerChange(tab);
    notifyListeners();
  }

  void updateThread(Thread thread) {
    final currentSnapshot = _threads.firstWhere((el) {
      return el.id == thread.id;
    });
    final index = _threads.indexOf(currentSnapshot);
    _threads.removeAt(index);
    _threads.insert(index, thread);
    _threadsSnippet[thread.id] = thread.name;
    final tab = _openedTabs.firstWhere((element) => element.id == thread.id);
    registerChange(tab);
    notifyListeners();
  }

  Future<Thread?> getUpToDateThreadWithoutOpening(String id) async {
    if (_currentProject == null) return null;
    final isOpened = _threads.any((el) {
      return el.id == id;
    });
    if (!isOpened) {
      try {
        final thread = await ProjectHelper().getThread(id, _currentProject!);
        _threads.add(thread);
        return thread;
      } catch (e) {
        return null;
      }
    } else {
      return getThread(id);
    }
  }

  void openThread(String id) async {
    if (_currentProject == null) return;
    final isOpened = _threads.any((el) {
      return el.id == id;
    });
    if (!isOpened) {
      final thread = await ProjectHelper().getThread(
        id,
        _currentProject!,
      );
      _threads.add(thread);
    }
    final tab = _openedTabs.firstWhere(
      (element) {
        return element.id == id;
      },
      orElse: () => FileTab(
        id: id,
        path: null,
        type: FileType.threadEditor,
      ),
    );
    openTab(tab);
    notifyListeners();
  }

  void deleteThread(String id) async {
    if (_currentProject == null) return;
    final index = _openedTabs.indexWhere((element) => element.id == id);
    if (index != -1) {
      closeTab(index);
    }
    _threads.removeWhere((el) => el.id == id);
    _changedTabs.removeWhere((element) => element.id == id);
    _threadsSnippet.remove(id);
    final refreshedThreads = await ProjectHelper().deleteThread(
      id,
      _currentProject!,
    );
    _threadsSnippet = refreshedThreads;
    notifyListeners();
  }

  Future<void> saveThreadFile(String id) async {
    try {
      if (_currentProject == null) return;
      final thread = _threads.firstWhere((element) => element.id == id);
      _threadsSnippet = await ProjectHelper().overrideThread(
        thread,
        _currentProject!,
      );
      _changedTabs.removeWhere((element) {
        return element.type == FileType.threadEditor && element.id == id;
      });
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  void addChapter(Chapter chapter) {
    _chapters.add(chapter);
    final tab = _openedTabs.firstWhere(
      (el) => el.type == FileType.timelineEditor,
      orElse: () {
        final newTab = FileTab(
          id: null,
          path: null,
          type: FileType.timelineEditor,
        );
        openTab(newTab);
        return newTab;
      },
    );
    registerChange(tab);
    notifyListeners();
  }

  void updateChapter(Chapter chapter) {
    final currentSnapshot = _chapters.firstWhere((el) {
      return el.id == chapter.id;
    });
    final index = _chapters.indexOf(currentSnapshot);
    _chapters.removeAt(index);
    _chapters.insert(index, chapter);
    final tab = _openedTabs.firstWhere(
      (element) => element.type == FileType.timelineEditor,
    );
    registerChange(tab);
    notifyListeners();
  }

  void deleteChapter(String id) async {
    if (_currentProject == null) return;
    _chapters.removeWhere((el) => el.id == id);
    await ProjectHelper().deleteChapter(
      id,
      _currentProject!,
    );
    await saveTimelineFile();
  }

  Future<void> saveChapterFile(String id) async {
    try {
      if (_currentProject == null) return;
      final chapter = _chapters.firstWhere((element) => element.id == id);
      await ProjectHelper().overrideChapter(
        chapter,
        _currentProject!,
      );
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<void> saveTimelineFile() async {
    for (var element in _chapters) {
      await saveChapterFile(element.id);
    }
    _changedTabs.removeWhere((element) {
      return element.type == FileType.timelineEditor;
    });
    notifyListeners();
  }

  Future<void> openChapterEditor(String id) async {
    if (_currentProject == null) return;
    final isOpened = _editors.any((el) {
      return el.chapterId == id;
    });
    if (!isOpened) {
      final editor = await ProjectHelper().openChapterEditor(
        id,
        _currentProject!,
      );
      _editors.add(editor);
    }
    final tab = _openedTabs.firstWhere(
      (element) {
        return element.id == id;
      },
      orElse: () => FileTab(
        id: id,
        path: null,
        type: FileType.editor,
      ),
    );
    openTab(tab);
    notifyListeners();
  }

  void createChapterAndOpenEditor(Chapter chapter) async {
    addChapter(chapter);
    await openChapterEditor(chapter.id);
    final tab = _openedTabs.firstWhere(
      (element) {
        return element.id == chapter.id;
      },
    );
    registerChange(tab);
  }

  void registerChangeInChapterEditor(ChapterFile change) async {
    if (_currentProject == null) return;
    final index = _editors.indexWhere((el) => el.chapterId == change.chapterId);
    if (index == -1) return;
    _editors.removeAt(index);
    _editors.insert(index, change);
    final tab = _openedTabs.firstWhere(
      (element) => element.type == FileType.editor,
    );
    registerChange(tab);
    notifyListeners();
  }

  int? wordCountForEditor() {
    if (_currentProject == null) return null;
    if (_currentlyOpened == -1) return null;
    final tab = openedTabs[_currentlyOpened];
    switch (tab.type) {
      case FileType.editor:
        if (tab.id == null) return null;
        final chapter = getEditor(tab.id!);
        if (chapter == null) return 0;
        if (chapter.content.isEmpty) return 0;
        return quill.Document.fromJson(chapter.content)
            .toPlainText()
            .split(' ')
            .where((element) => element.isNotEmpty && element != ' ')
            .length;
      case FileType.general:
        return _currentProject!.name.split(' ').length;
      case FileType.timelineEditor:
        final words = _chapters
            .map((e) {
              return '${e.description} ${e.name} ${e.scenes.map((el) {
                return el.description + (el.name ?? '');
              }).join(' ')}';
            })
            .where((element) => element.isNotEmpty && element != ' ')
            .map((e) => e.split(' ').length)
            .fold(0, (a, b) => a + b);
        return words;
      case FileType.plotDevelopment:
        return null;
      case FileType.threadEditor:
        if (tab.id == null) return null;
        final thread = getThread(tab.id!);
        final words =
            '${thread.description} ${thread.conflict} ${thread.result} ${thread.name}';
        return words
            .split(' ')
            .where((element) => element.isNotEmpty && element != ' ')
            .length;
      case FileType.characterEditor:
        if (tab.id == null) return null;
        final character = getCharacter(tab.id!);
        final words =
            '${character.description} ${character.apperance} ${character.age} ${character.goals} ${character.name} ${character.notes.join(' ')}';
        return words
            .split(' ')
            .where((element) => element.isNotEmpty && element != ' ')
            .length;
      case FileType.system:
        return null;
      case FileType.userFile:
        return null;
    }
  }

  // changes tracker and working tree
  List<WorkingTree> get _workingTrees => [
        ..._characters
            .map((e) {
              return e.workingTree;
            })
            .whereType<WorkingTree>()
            .toList(),
        ..._chapters
            .map((e) {
              return e.workingTree;
            })
            .whereType<WorkingTree>()
            .toList(),
      ];

  WorkingTree? _getMostRecentlyEditedWorkingTree() {
    final treesCopy = [..._workingTrees];
    if (treesCopy.isEmpty) return null;
    final recentChangesByTree = treesCopy.map((e) {
      final entries = {...e.changes, ...e.undoneChanges}.entries.toList();
      entries.sort((a, b) => a.key.compareTo(b.key));
      return entries.last;
    }).toList();
    recentChangesByTree.sort((a, b) => a.key.compareTo(b.key));
    final mostRecentChange = recentChangesByTree.last;
    try {
      final recentTree = treesCopy.firstWhere((element) =>
          element.changes.containsKey(mostRecentChange.key) ||
          element.undoneChanges.containsKey(mostRecentChange.key));

      return recentTree;
    } catch (e) {
      return null;
    }
  }

  void _undoOrRedo(bool undo) {
    final mostRecentChange = _getMostRecentlyEditedWorkingTree();
    if (mostRecentChange == null) return;
    final canPerformAction =
        undo ? mostRecentChange.canUndo : mostRecentChange.canRedo;
    if (canPerformAction) {
      if (mostRecentChange is WorkingTree<Character>) {
        // character edit
        final newTree =
            undo ? mostRecentChange.undo() : mostRecentChange.redo();
        if (newTree == null) return;
        updateCharacter(Character.fromWorkingTree(newTree));
      } else if (mostRecentChange is WorkingTree<Chapter>) {
        // chapter edit
        final newTree =
            undo ? mostRecentChange.undo() : mostRecentChange.redo();
        if (newTree == null) return;
        updateChapter(Chapter.fromWorkingTree(newTree));
      }
    }
  }

  void undo() {
    _undoOrRedo(true);
    notifyListeners();
  }

  void redo() {
    _undoOrRedo(false);
    notifyListeners();
  }

  String? _projectSearchQuery;
  bool get hasSearchBeenMade => _projectSearchQuery != null;
  String get projectSearchQuery => _projectSearchQuery ?? '';
  List<SearchResult> _projectSearchResults = [];
  List<SearchResult> get projectSearchResults => [..._projectSearchResults];

  void projectSearch(String query) async {
    if (_currentProject == null) return;
    if (query.isEmpty) {
      _projectSearchQuery = null;
      return;
    }
    _projectSearchQuery = query;
    _projectSearchResults = await SearchHelper().searchThroughProjectFiles(
      _currentProject!.path,
      query,
    );
    notifyListeners();
  }

  void clearProjectSearch() {
    _projectSearchQuery = null;
    _projectSearchResults = [];
    notifyListeners();
  }

  bool get shouldHighlightSearchResults {
    if (_currentProject == null) return false;
    if (_currentlyOpened == -1) return false;
    if (_sidebarTab != SidebarTab.projectSearch) return false;
    if (_projectSearchResults.isEmpty) return false;
    if (_projectSearchResults.any((el) => el.type == selectedFileType)) {
      final typeResults = _projectSearchResults.where((element) {
        return element.type == selectedFileType;
      }).toList();

      if (selectedFileType == FileType.characterEditor ||
          selectedFileType == FileType.threadEditor ||
          selectedFileType == FileType.editor) {
        return typeResults.any((element) {
          return element.id != null && element.id == selectedTab!.id;
        });
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  String? get selectedTabContent {
    if (_currentlyOpened == -1) return null;
    final tab = _openedTabs[_currentlyOpened];
    if (tab.type == FileType.characterEditor) {
      final character = getCharacter(tab.id!);
      return '${character.description}. ${character.apperance}. ${character.age}. ${character.goals}. ${character.name}. ${character.notes.join('. ')}. ${character.occupationHistory.map((e) => e.occupation).join('. ')}.';
    }

    return null;
  }
}
