import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/system_pages.dart';
import '../models/file_tab.dart';
import '../models/settings_enums.dart';
import '../pages/resources/user_file.dart';
import '../pages/workspace/character_editor.dart';
import '../pages/workspace/editor/editor_page.dart';
import '../pages/workspace/empty.dart';
import '../pages/workspace/general_file.dart';
import '../pages/workspace/plot_development.dart';
import '../pages/workspace/thread_editor.dart';
import '../pages/workspace/timeline.dart';
import '../pages/workspace/welcome_screen.dart';
import '../providers/project_state.dart';
import 'errors_panel.dart';
import 'sidebar/right_sidebar/right_sidebar.dart';
import 'tabs.dart';

class Workspace extends StatelessWidget {
  const Workspace({super.key});

  Widget _buildWorkspace(FileType? fileType, [String? path]) {
    switch (fileType) {
      case FileType.general:
        return const GeneralFile();
      case FileType.timelineEditor:
        return const TimelineEditor();
      case FileType.threadEditor:
        return const ThreadEditor();
      case FileType.characterEditor:
        return const CharacterEditor();
      case FileType.plotDevelopment:
        return const PlotDevelopment();
      case FileType.editor:
        return const EditorPage();
      case FileType.system:
        break;
      case null:
        return const EmptyScreen();
      case FileType.userFile:
        return const UserFilePage();
    }

    return systemPages[path] ?? const EmptyScreen();
  }

  @override
  Widget build(BuildContext context) {
    final project = Provider.of<ProjectState>(context);

    return Column(
      children: [
        // tabs
        if (project.tabBarVisibility == TabBarVisibility.top) const WrtTabs(),
        // work area
        Expanded(
          child: Column(
            children: [
              if (project.isProjectOpened)
                // workspace
                Expanded(
                  child: Row(
                    children: [
                      // build actual working area
                      Expanded(
                        child: _buildWorkspace(
                          project.selectedFileType,
                          project.selectedTab?.path,
                        ),
                      ),
                      // right sidebar
                      if (project.showRightSidebar) const RightSidebar(),
                    ],
                  ),
                )
              else
                // welcome screen if project is not opened
                const Expanded(
                  child: WelcomeScreen(),
                ),
              // errors panel
              const ErrorsPanel(),
            ],
          ),
        ),
        // tabs if on the bottom
        if (project.tabBarVisibility == TabBarVisibility.bottom)
          const WrtTabs(),
      ],
    );
  }
}
