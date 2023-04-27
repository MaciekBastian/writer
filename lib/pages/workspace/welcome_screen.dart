import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:writer/helpers/file_explorer_helper.dart';
import 'package:writer/widgets/prompts/multiple_option_select.dart';
import 'package:writer/widgets/prompts/text_prompt.dart';

import '../../providers/project_state.dart';
import '../../providers/version_control.dart';
import '../../widgets/button.dart';
import '../tools/explorer_picker.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final versionControl = Provider.of<VersionControl>(context, listen: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 30.0,
        horizontal: 35.0,
      ),
      child: ListView(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: const Icon(
              Icons.edit,
              size: 125.0,
            ),
          ),
          Text(
            'welcome.welcome_text'.tr(),
            style: theme.textTheme.headlineLarge,
          ),
          Text(
            'welcome.slogan'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'welcome.start_where_you_left_off'.tr()}:',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Divider(
                      color: Colors.grey,
                      endIndent: 50.0,
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${'welcome.recent_projects'.tr()}:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    FutureBuilder(
                      future: provider.recentProjects(),
                      initialData: const <String>[],
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ((snapshot.data) ?? []).map((e) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  final project = await provider.openProject(e);
                                  if (project != null) {
                                    versionControl.initialize(project);
                                  }
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    Platform.isMacOS
                                        ? Uri.parse(e).pathSegments.last
                                        : e,
                                    style: theme.textTheme.bodyMedium,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'welcome.start_your_work'.tr()}:',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Divider(
                      color: Colors.grey,
                      endIndent: 50.0,
                    ),
                    const SizedBox(height: 10.0),
                    WrtButton(
                      callback: () async {
                        if (Platform.isWindows) {
                          final path = await showDialog(
                            context: context,
                            builder: (context) => const ExplorerPicker(
                              pickProject: false,
                            ),
                          );
                          if (path != null) {
                            final project = await provider.createProject(path);
                            if (project != null) {
                              versionControl.initialize(project);
                            }
                          }
                          return;
                        }
                        if (Platform.isMacOS) {
                          final name = await showTextPrompt(
                            context,
                            message: 'welcome.project_name'.tr(),
                          );
                          if (name != null) {
                            final exists = await FileExplorerHelper()
                                .macosDoesProjectExists(name);
                            if (exists) return;
                            final path = await FileExplorerHelper()
                                .macosCreateProject(name);

                            final project = await provider.createProject(
                              path,
                              name,
                            );
                            if (project != null) {
                              versionControl.initialize(project);
                            }
                          }
                          return;
                        }
                      },
                      label: 'welcome.create_project'.tr(),
                    ),
                    const SizedBox(height: 10.0),
                    WrtButton(
                      callback: () async {
                        if (Platform.isWindows) {
                          final path = await showDialog(
                            context: context,
                            builder: (context) => const ExplorerPicker(
                              pickProject: true,
                            ),
                          );
                          if (path != null) {
                            final project = await provider.openProject(path);
                            if (project != null) {
                              versionControl.initialize(project);
                            }
                          }
                          return;
                        }
                        if (Platform.isMacOS) {
                          Future<Map<String, String>> getProjects() async {
                            final allProjects =
                                await FileExplorerHelper().macosGetProjects();
                            if (allProjects.isEmpty) return {};
                            final allNames = allProjects
                                .map((e) => Uri.parse(e).pathSegments.last)
                                .toList();

                            return allProjects.asMap().map(
                                  (key, value) =>
                                      MapEntry(allNames[key], value),
                                );
                          }

                          final path = await showMultipleOptionSelectPrompt(
                            await getProjects(),
                            'welcome.select_project'.tr(),
                            context,
                          );

                          if (path == null) return;
                          if (path is String) {
                            final project = await provider.openProject(path);
                            if (project != null) {
                              versionControl.initialize(project);
                            }
                          }
                        }
                      },
                      label: 'welcome.open_project'.tr(),
                    ),
                    const SizedBox(height: 10.0),
                    WrtButton(
                      callback: () async {
                        // TODO: import project FOR BOTH PLATFORMS
                      },
                      label: 'welcome.import_project'.tr(),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'welcome.import_open_difference'.tr(),
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 20.0),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {},
                      child: Text(
                        'welcome.first_launch'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color.fromARGB(255, 88, 111, 230),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
