import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/error/project_error.dart';

import '../models/file_tab.dart';
import '../providers/project_state.dart';

class ErrorsPanel extends StatefulWidget {
  const ErrorsPanel({super.key});

  @override
  State<ErrorsPanel> createState() => _ErrorsPanelState();
}

class _ErrorsPanelState extends State<ErrorsPanel> {
  ProjectError? _selectedError;
  double _height = 250.0;
  bool _hovering = false;
  bool _dragging = false;

  Widget _buildErrorButton(ProjectError error) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);

    return Container(
      color: _selectedError?.errorId == error.errorId
          ? Colors.grey[800]
          : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_selectedError?.errorId == error.errorId) {
              setState(() {
                _selectedError = null;
              });
            } else {
              setState(() {
                _selectedError = error;
              });
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            children: [
              const SizedBox(width: 15.0),
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF8241),
                size: 20.0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    error.contentKey.tr() +
                        (error.errorWord == null
                            ? ''
                            : ': ${error.errorWord!.tr()}'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: provider.isErrorIgnored(error.errorId)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final provider = Provider.of<ProjectState>(context, listen: false);
    final project = Provider.of<ProjectState>(context);

    if (!project.isProjectOpened) return Container();
    if (!project.isErrorPanelOpened) {
      _selectedError = null;
      return Container();
    }

    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.resizeRow,
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
          child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                _height = 250.0;
              });
            },
            onVerticalDragStart: (_) {
              setState(() {
                _dragging = true;
              });
            },
            onVerticalDragEnd: (_) {
              setState(() {
                _dragging = false;
              });
            },
            onVerticalDragUpdate: (details) {
              double newHeight = _height;
              if (details.delta.direction >= 0 &&
                  details.delta.direction >= (math.pi / 2)) {
                newHeight = _height - details.delta.distance;
              } else {
                newHeight = _height + details.delta.distance;
              }
              if (120.0 <= newHeight && newHeight <= screenSize.height / 2.5) {
                setState(() {
                  _height = newHeight;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 8.0,
              color: _hovering || _dragging
                  ? Colors.grey[800]
                  : const Color(0xFF242424),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(
                  vertical: 2.5,
                  horizontal: 8.0,
                ),
                color:
                    _hovering || _dragging ? Colors.black : Colors.transparent,
              ),
            ),
          ),
        ),
        Container(
          color: const Color(0xFF242424),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'errors.errors'.tr().toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    provider.switchErrorPanel();
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: const SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: Icon(
                      Icons.close_outlined,
                      size: 20.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: _height,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: project.errors.length,
                  itemBuilder: (context, index) {
                    final error = project.errors[index];

                    return _buildErrorButton(error);
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: const Color(0xFF1A1A1A),
                  child: _selectedError == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'errors.select_error_message'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _selectedError!.contentKey.tr(),
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                            if (_selectedError!.errorWord != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _selectedError!.errorWord!.tr(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _selectedError!.solution.tr(
                                  args: [_selectedError!.errorWord?.tr() ?? ''],
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(right: 8.0),
                              alignment: Alignment.centerRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      provider.ignoreError(
                                        _selectedError!.errorId,
                                      );
                                      Future.delayed(
                                        const Duration(milliseconds: 250),
                                        () {
                                          setState(() {
                                            _selectedError = null;
                                          });
                                        },
                                      );
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        provider.isErrorIgnored(
                                                _selectedError!.errorId)
                                            ? 'errors.stop_ignoring'
                                                .tr()
                                                .toUpperCase()
                                            : 'errors.ignore'
                                                .tr()
                                                .toUpperCase(),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ..._buildSuggestions(),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSuggestions() {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context, listen: false);

    return List.generate(
      _selectedError!.whereTypes.length,
      (index) {
        String content = '';
        switch (_selectedError!.whereTypes[index]) {
          case FileType.general:
            content = 'project.general'.tr();
            break;
          case FileType.timelineEditor:
            content = 'project.timeline'.tr();
            break;
          case FileType.threadEditor:
            final threadName =
                provider.threads[_selectedError!.whereIds?[index]];
            content = threadName ?? 'project.threads'.tr();
            break;
          case FileType.characterEditor:
            final characterName =
                provider.characters[_selectedError!.whereIds?[index]];
            content = characterName ?? 'project.characters'.tr();
            break;
          case FileType.plotDevelopment:
            // TODO: add plot development support.
            break;
          case FileType.system:
            // TODO: Handle this case.
            break;
          case FileType.editor:
            // TODO: Handle this case.
            break;
          case FileType.userFile:
            // TODO: Handle this case.
            break;
        }

        return Row(
          children: [
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                content,
                style: theme.textTheme.labelMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(
              width: 8.0,
              height: 30.0,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final type = _selectedError!.whereTypes[index];
                    if (type == FileType.characterEditor) {
                      provider.switchErrorPanel();
                      provider.openCharacter(
                        _selectedError!.whereIds![index],
                      );
                    } else if (type == FileType.threadEditor) {
                      provider.switchErrorPanel();
                      provider.openThread(
                        _selectedError!.whereIds![index],
                      );
                    } else {
                      provider.switchErrorPanel();
                      provider.openTab(
                        FileTab(
                          id: _selectedError!.whereIds?[index],
                          path: _selectedError!.whereIds?[index],
                          type: type,
                        ),
                      );
                    }
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'errors.open_in_editor'.tr().toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
          ],
        );
      },
    );
  }
}
