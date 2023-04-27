import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../helpers/file_explorer_helper.dart';

class ExplorerPicker extends StatefulWidget {
  const ExplorerPicker({
    super.key,
    required this.pickProject,
  });

  /// if false, pick folder mode is active
  final bool pickProject;

  @override
  State<ExplorerPicker> createState() => _ExplorerPickerState();
}

class _ExplorerPickerState extends State<ExplorerPicker> {
  String? _currentPath;
  String? _selectedPath;
  bool _selectedHasProject = false;
  List<Directory> _directories = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () async {
      final path = await FileExplorerHelper().getDocuments();
      if (path != null) {
        final directories = await FileExplorerHelper().getDirectoriesForPath(
          path,
        );
        if (directories == null) return;
        setState(() {
          _currentPath = path;
          _directories = directories;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      alignment: Alignment.topLeft,
      child: Container(
        width: 750.0,
        height: 450.0,
        color: Colors.black,
        child: Column(
          children: [
            Container(
              height: 32.0,
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      widget.pickProject
                          ? 'explorer.file_picker'.tr()
                          : 'explorer.folder_picker'.tr(),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  CloseWindowButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    colors: WindowButtonColors(
                      iconNormal: Colors.grey[400],
                      iconMouseDown: Colors.white,
                      iconMouseOver: Colors.white,
                      mouseOver: Colors.red,
                      mouseDown: Colors.red[200],
                      normal: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  _buildLeftPanel(),
                  _buildRightPanel(),
                ],
              ),
            ),
            Container(
              height: 50.0,
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: _selectedPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _selectedHasProject
                                  ? widget.pickProject
                                      ? ''
                                      : 'explorer.selected_is_project'.tr()
                                  : widget.pickProject
                                      ? 'explorer.selected_is_not_project'.tr()
                                      : '',
                              style: theme.textTheme.labelMedium,
                            ),
                          )
                        : Container(),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 30.0,
                      alignment: Alignment.center,
                      child: Text(
                        _selectedPath ?? _currentPath ?? '',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(
                        2,
                        (index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: index.isEven
                                  ? () {
                                      Navigator.of(context).pop();
                                    }
                                  : _selectedHasProject
                                      ? widget.pickProject
                                          ? () {
                                              if (_selectedPath != null ||
                                                  _currentPath != null) {
                                                Navigator.of(context).pop(
                                                  _selectedPath ?? _currentPath,
                                                );
                                              }
                                            }
                                          : null
                                      : widget.pickProject
                                          ? null
                                          : () {
                                              if (_selectedPath != null ||
                                                  _currentPath != null) {
                                                Navigator.of(context).pop(
                                                  _selectedPath ?? _currentPath,
                                                );
                                              }
                                            },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.only(right: 5.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[800]!,
                                  ),
                                ),
                                child: Text(
                                  index.isEven
                                      ? 'explorer.cancel'.tr()
                                      : widget.pickProject
                                          ? 'explorer.pick_project'.tr()
                                          : 'explorer.pick_folder'.tr(),
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _buildRightPanel() {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10.0,
            ),
            height: 30.0,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[800]!,
                width: 2.0,
              ),
              color: Colors.grey[900],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (_currentPath != null) {
                          final parent = FileExplorerHelper().getParent(
                            _currentPath!,
                          );
                          if (parent != null) {
                            final directories = await FileExplorerHelper()
                                .getDirectoriesForPath(parent);
                            if (directories == null) return;
                            setState(() {
                              _currentPath = parent;
                              _directories = directories;
                              _selectedPath = null;
                            });
                          }
                        }
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    _currentPath ?? '',
                    style: theme.textTheme.labelMedium,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _directories.map((e) {
                return _DirectoryElement(
                  dir: e,
                  onFocused: () {
                    final containsProject =
                        FileExplorerHelper().doesPathContainProject(e.path);
                    if (containsProject == null) {
                      return;
                    }

                    setState(() {
                      _selectedPath = e.path;
                      _selectedHasProject = containsProject;
                    });
                  },
                  onSelected: () async {
                    final directories = await FileExplorerHelper()
                        .getDirectoriesForPath(e.path);
                    if (directories == null) return;
                    setState(() {
                      _currentPath = e.path;
                      _directories = directories;
                      _selectedPath = null;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Container _buildLeftPanel() {
    final theme = Theme.of(context);
    return Container(
      width: 200.0,
      padding: const EdgeInsets.all(10.0),
      color: Colors.grey[800],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'explorer.quick_access'.tr()}:',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10.0),
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
                          final directories = await FileExplorerHelper()
                              .getDirectoriesForPath(snapshot.data!);
                          if (directories == null) return;
                          setState(() {
                            _currentPath = snapshot.data;
                            _directories = directories;
                            _selectedPath = null;
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
                              SizedBox(width: 30.0, child: icon),
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
        ],
      ),
    );
  }
}

class _DirectoryElement extends StatefulWidget {
  const _DirectoryElement({
    required this.dir,
    required this.onFocused,
    required this.onSelected,
  });

  final Directory dir;
  final void Function() onSelected;
  final void Function() onFocused;

  @override
  State<_DirectoryElement> createState() => __DirectoryElementState();
}

class __DirectoryElementState extends State<_DirectoryElement> {
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1.0),
      color: Colors.grey[700],
      height: 30.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1.0),
        color: Colors.black,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            focusNode: _focusNode,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _focusNode.requestFocus();
              widget.onFocused();
            },
            onDoubleTap: () {
              _focusNode.unfocus();
              widget.onSelected();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 20.0,
              ),
              child: Text(
                widget.dir.path.substring(
                  widget.dir.path.lastIndexOf('\\') + 1,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
