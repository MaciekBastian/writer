import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/file_explorer_helper.dart';
import '../../models/file_tab.dart';
import '../../widgets/button.dart';

import '../../providers/project_state.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({super.key});

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  bool _loading = true;
  int _index = 0;
  List<Directory> _history = [];
  FileSystemEntity? _selected;

  @override
  void initState() {
    super.initState();

    FileExplorerHelper().getDocuments().then((value) {
      if (value != null) {
        _history.add(Directory(value));
      }
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final current = _loading ? null : _history[_index];

    final provider = Provider.of<ProjectState>(context);

    if (Platform.isMacOS) {
      return Center(
        child: Text(
          'file_explorer.macos_unavailable'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 55.0,
          color: const Color(0xFF191919),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // action buttons
              Row(
                children: [
                  // back
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _index == 0
                          ? null
                          : () {
                              setState(() {
                                _index -= 1;
                              });
                            },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20.0,
                          color: _index == 0 ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // forward
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _index == _history.length - 1
                          ? null
                          : () {
                              setState(() {
                                _index += 1;
                              });
                            },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20.0,
                          color: _index == _history.length - 1
                              ? Colors.grey
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // parent directory
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: current == null
                          ? null
                          : () async {
                              final parent = FileExplorerHelper().getParent(
                                current.path,
                              );
                              if (parent == null) return;
                              setState(() {
                                _history.add(Directory(parent));
                                _index = _history.length - 1;
                              });
                            },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_upward,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // current directory
              Expanded(
                child: Container(
                  height: 30.0,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    color: const Color(0xFF242424),
                  ),
                  child: SelectableText(
                    current?.path ?? '//',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ),
              // open button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WrtButton(
                  callback: () {
                    if (_selected == null) return;
                  },
                  label: 'file_explorer.open'.tr(),
                ),
              ),
            ],
          ),
        ),
        if (_loading)
          LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: 4.0,
            color: theme.colorScheme.primary,
          ),
        Expanded(
          child: Row(
            children: [
              if (!provider.smallScreenView && !provider.rightSidebar)
                Container(
                  width: 200.0,
                  height: double.infinity,
                  color: const Color(0xFF191919),
                  child: ListView(
                    children: [
                      ...List.generate(
                        3,
                        (index) {
                          late final Future<String?> path;
                          late final Icon icon;
                          late final String title;

                          if (index == 0) {
                            path = FileExplorerHelper().getDesktop();
                            title = 'explorer.desktop'.tr();
                            icon = const Icon(Icons.desktop_windows_outlined);
                          } else if (index == 1) {
                            path = FileExplorerHelper().getDocuments();
                            title = 'explorer.documents'.tr();
                            icon = const Icon(Icons.file_copy_outlined);
                          } else {
                            path = FileExplorerHelper().getDownloads();
                            title = 'explorer.downloads'.tr();
                            icon = const Icon(Icons.file_download_outlined);
                          }

                          return FutureBuilder(
                            future: path,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async {
                                      final pathData = await path;
                                      if (current?.path == pathData) return;
                                      if (pathData == null) return;
                                      setState(() {
                                        _history.add(Directory(pathData));
                                        _index = _history.length - 1;
                                      });
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Container(
                                      height: 40.0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                        horizontal: 10.0,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30.0,
                                            child: Icon(
                                              icon.icon,
                                              size: 20.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Text(
                                            title,
                                            style: theme.textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText(
                          'file_explorer.hint'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (current != null) _buildCurrentFolderList(current),
            ],
          ),
        )
      ],
    );
  }

  Expanded _buildCurrentFolderList(Directory current) {
    final provider = Provider.of<ProjectState>(context, listen: false);

    return Expanded(
      child: Builder(
        builder: (context) {
          final folders = current.listSync().whereType<Directory>();
          final files = current.listSync().whereType<File>().where((element) {
            final fileName = element.uri.pathSegments.where((element) {
              return element.isNotEmpty;
            }).last;
            final extension = fileName
                .substring(
                  fileName.lastIndexOf('.') + 1,
                )
                .toLowerCase();
            final supported = [
              'pdf',
              'jpeg',
              'png',
              'jpg',
              'svg',
              'jfif',
              'pjpeg',
              'webp',
            ];

            return supported.contains(extension);
          }).toList();

          return ListView(
            children: [
              ...folders.map((e) {
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 2.0,
                  ),
                  color:
                      _selected?.path == e.path ? Colors.black54 : Colors.black,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          _selected = e;
                        });
                      },
                      onDoubleTap: () {
                        try {
                          // we are checking here if we have access to this folder
                          e.listSync();
                        } catch (e) {
                          return;
                        }
                        setState(() {
                          _history.add(e);
                          _index = _history.length - 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_outlined,
                              size: 20.0,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5.0),
                            Expanded(
                              child: Text(
                                e.uri.pathSegments.where((element) {
                                  return element.isNotEmpty;
                                }).last,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              ...files.map((e) {
                final fileName = e.uri.pathSegments.where((element) {
                  return element.isNotEmpty;
                }).last;
                final extension = fileName
                    .substring(
                      fileName.lastIndexOf('.') + 1,
                    )
                    .toLowerCase();

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 2.0,
                  ),
                  color:
                      _selected?.path == e.path ? Colors.black54 : Colors.black,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          _selected = e;
                        });
                      },
                      onDoubleTap: () {
                        try {
                          // we are checking here if we have access to this file
                          e.statSync();
                        } catch (e) {
                          return;
                        }
                        provider.openTab(
                          FileTab(
                            id: null,
                            path: e.path,
                            type: FileType.userFile,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                if (['pdf'].contains(extension))
                                  const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    size: 20.0,
                                    color: Colors.grey,
                                  ),
                                if ([
                                  'jpeg',
                                  'png',
                                  'jpg',
                                  'svg',
                                  'jfif',
                                  'pjpeg',
                                  'webp',
                                ].contains(extension))
                                  const Icon(
                                    Icons.photo_camera_back_outlined,
                                    size: 20.0,
                                    color: Colors.grey,
                                  ),
                                const SizedBox(width: 5.0),
                                Text(
                                  e.uri.pathSegments.where((element) {
                                    return element.isNotEmpty;
                                  }).last,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
