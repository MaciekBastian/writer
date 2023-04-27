import 'package:flutter/material.dart';

import '../helpers/project_helper.dart';
import '../models/on_this_day.dart';
import '../models/project.dart';

class ProjectCache with ChangeNotifier {
  bool _initialized = false;
  Project? _project;

  List<WikipediaSnippet> _wikipediaSnippets = [];
  List<WikipediaSnippet> get wikipediaSnippets => [..._wikipediaSnippets];

  void initalize(Project project) async {
    if (_initialized) return;
    _wikipediaSnippets = await ProjectHelper().getWikipediaSnippets(project);
    _project = project;
    _initialized = true;
    notifyListeners();
  }

  bool hasThisSnippet(String? url) {
    return _wikipediaSnippets.any((element) => element.url == url);
  }

  void addSnippet(WikipediaSnippet snippet) async {
    if (_project == null) return;
    if (hasThisSnippet(snippet.url)) return;
    _wikipediaSnippets.add(snippet);
    await ProjectHelper().addWikipediaSnippet(_project!, snippet);
    notifyListeners();
  }

  void removeSnippet(String? url) async {
    if (_project == null) return;
    if (hasThisSnippet(url)) {
      _wikipediaSnippets.removeWhere((element) => element.url == url);
      await ProjectHelper().removeWikipediaSnippet(_project!, url);
    }
    notifyListeners();
  }
}
