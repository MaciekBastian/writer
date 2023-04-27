import 'package:flutter/material.dart';

import '../models/settings_enums.dart';
import '../pages/other/licenses.dart';
import '../pages/reports/characters_report.dart';
import '../pages/resources/how_to_use_writer.dart';
import '../pages/tools/advanced_search.dart';
import '../pages/tools/calendar.dart';
import '../pages/tools/dictionary.dart';
import '../pages/tools/file_explorer.dart';
import '../pages/tools/wikipedia.dart';
import '../pages/version_control/compare_page.dart';

const Map<String, Widget> systemPages = {
  '/writer-help': HowToUseWriter(),
  '/tools/dictionary': DictionaryPage(),
  '/tools/calendar': CalendarPage(),
  '/about/licenses': LicensesPage(),
  '/report/characters': CharactersReport(),
  '/tools/file_explorer': FileExplorerPage(),
  '/tools/wikipedia': WikipediaPage(),
  CompareVersionsPage.pageName: CompareVersionsPage(),
  AdvancedSearchPage.pageName: AdvancedSearchPage(),
};

const Map<SidebarProjectTabElement, String> systemPagesPathsForSidebar = {
  SidebarProjectTabElement.calendar: '/tools/calendar',
  SidebarProjectTabElement.dictionary: '/tools/dictionary',
  SidebarProjectTabElement.charactersReport: '/report/characters',
  SidebarProjectTabElement.fileExplorer: '/tools/file_explorer',
};

const Map<String, Icon> systemPagesIcons = {
  '/writer-help': Icon(Icons.help_outline),
  '/tools/dictionary': Icon(Icons.text_fields),
  '/tools/calendar': Icon(Icons.calendar_month_outlined),
  '/about/licenses': Icon(Icons.notes),
  '/report/characters': Icon(Icons.groups_3_outlined),
  '/tools/file_explorer': Icon(Icons.file_open_outlined),
  '/tools/wikipedia': Icon(Icons.language),
  CompareVersionsPage.pageName: Icon(Icons.difference_outlined),
  AdvancedSearchPage.pageName: Icon(Icons.search),
  // not implemented yet:
  '/system/version_control_graph': Icon(Icons.mediation),
  '/about/about': Icon(Icons.notes),
  'edu/plot-development': Icon(Icons.rebase_edit),
  'visualization/relationships': Icon(Icons.schema_outlined),
  'report/threads': Icon(Icons.summarize_outlined),
  'report/general': Icon(Icons.article_outlined),
};

const Map<String, String> systemPagesNames = {
  '/writer-help': 'system_pages.how_to_use_writer',
  '/tools/dictionary': 'system_pages.dictionary',
  '/tools/calendar': 'system_pages.calendar',
  '/about/licenses': 'taskbar.licenses',
  '/report/characters': 'reports.characters_report',
  '/tools/file_explorer': 'resources.file_explorer',
  '/tools/wikipedia': 'resources.wikipedia',
  CompareVersionsPage.pageName: 'version_control.compare',
  AdvancedSearchPage.pageName: 'search.search',
};

const Map<String, Widget> resources = {
  '/writer-help': HowToUseWriter(),
};

const Map<String, Widget> visualizationsAndReports = {
  '/report/characters': CharactersReport(),
};

const Map<String, Widget> tools = {
  '/tools/dictionary': DictionaryPage(),
  '/tools/calendar': CalendarPage(),
  '/tools/file_explorer': FileExplorerPage(),
  '/tools/wikipedia': WikipediaPage(),
};
