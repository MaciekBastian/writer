import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/file_explorer_helper.dart';
import '../../widgets/prompts/multiple_option_select.dart';
import '../../widgets/prompts/text_prompt.dart';

import '../../providers/project_state.dart';
import '../../providers/version_control.dart';
import '../../widgets/button.dart';
import '../global_settings.dart';
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
                    const SizedBox(height: 10.0),
                    FutureBuilder<Map<String, DateTime>>(
                      future: provider.recentProjects(),
                      initialData: const <String, DateTime>{},
                      builder: (context, snapshot) {
                        final data = (snapshot.data ?? {}).entries.toList();
                        data.sort((a, b) => b.value.compareTo(a.value));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (data).map((element) {
                            return _RecentProjectButton(
                              time: element.value,
                              path: element.key,
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
                        // TODO: import project for Windows
                        if (Platform.isMacOS) {
                          final picked = await FilePicker.platform.pickFiles(
                            allowCompression: false,
                            allowMultiple: false,
                            lockParentWindow: true,
                            withData: true,
                            allowedExtensions: ['weave', 'xml'],
                            type: FileType.custom,
                          );
                          if (picked != null) {
                            final path = picked.files.first.path;
                            if (path != null) {
                              final file = File(path);
                              final content = file.readAsStringSync();
                              final project = await provider.importProject(
                                content,
                              );
                              if (project != null) {
                                versionControl.initialize(project);
                              }
                            }
                          }
                        }
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
                    const SizedBox(height: 5.0),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          GlobalSettingsPage.pageName,
                        );
                      },
                      child: Text(
                        '${'welcome.settings'.tr()} >',
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

class _RecentProjectButton extends StatefulWidget {
  const _RecentProjectButton({
    required this.path,
    required this.time,
  });

  final DateTime time;
  final String path;

  @override
  State<_RecentProjectButton> createState() => _RecentProjectButtonState();
}

class _RecentProjectButtonState extends State<_RecentProjectButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);
    final versionControl = Provider.of<VersionControl>(context, listen: false);

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          onTap: () async {
            final project = await provider.openProject(widget.path);
            if (project != null) {
              versionControl.initialize(project);
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 3.0),
            padding: const EdgeInsets.symmetric(
              vertical: 3.0,
              horizontal: 4.0,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 20.0,
                  color: Color(0xFF6F83E6),
                ),
                const SizedBox(width: 5.0, height: 30.0),
                Expanded(
                  child: Text(
                    Platform.isMacOS
                        ? Uri.parse(widget.path).pathSegments.last
                        : widget.path,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6F83E6),
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                if (_hovering)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 20.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5.0),
                      Text(
                        '${'welcome.last_modified'.tr()}:\n${'calendar.date_format_short'.tr(namedArgs: {
                              'year': '${widget.time.year}',
                              'month':
                                  '${widget.time.month < 10 ? '0' : ''}${widget.time.month}',
                              'day':
                                  '${widget.time.day < 10 ? '0' : ''}${widget.time.day}',
                            })}, ${widget.time.hour}:${widget.time.minute < 10 ? '0' : ''}${widget.time.minute}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(width: 5.0),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
