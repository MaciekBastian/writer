import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/expandable_section.dart';

import '../../models/file_tab.dart';
import '../../models/version/version.dart';
import '../../providers/project_state.dart';
import '../../providers/version_control.dart';
import '../../widgets/tooltip.dart';
import '../../widgets/version_control/comparable_file.dart';

class CompareVersionsPage extends StatefulWidget {
  static const pageName = '/system/version_control_compare';
  const CompareVersionsPage({super.key});

  @override
  State<CompareVersionsPage> createState() => _CompareVersionsPageState();
}

class _CompareVersionsPageState extends State<CompareVersionsPage> {
  final _comparedScroll = ScrollController();
  final _currentScroll = ScrollController();
  final _fileController = FileCompareController();

  FileType? _selectedType;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _comparedScroll.addListener(() {
      if (_comparedScroll.offset <= _currentScroll.position.maxScrollExtent) {
        _currentScroll.jumpTo(_comparedScroll.offset);
      }
    });
    _currentScroll.addListener(() {
      if (_currentScroll.offset <= _comparedScroll.position.maxScrollExtent) {
        _comparedScroll.jumpTo(_currentScroll.offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = Provider.of<ProjectState>(context);
    final versionControl = Provider.of<VersionControl>(context);
    final version = versionControl.currentlyComparing;

    if (version == null || versionControl.current == null) {
      return Center(
        child: Text('version_control.error_occurred'.tr()),
      );
    }

    final file = versionControl.getCurrentlyComparedFile();
    final current = versionControl.getCurrentVersionFile();

    return Column(
      children: [
        if (versionControl.isComparingLoading)
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: 4.0,
            color: Color(0xFF1638E2),
          )
        else
          const SizedBox(height: 4.0),
        // TODO: menu bar of comparsion
        const SizedBox(height: 1.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  versionControl.compare(version.code);
                },
                borderRadius: BorderRadius.circular(4.0),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.white10,
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.refresh,
                    size: 20.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        const SizedBox(height: 5.0),
        if (file != null && current != null)
          Expanded(
            child: Row(
              children: [
                // current version (editable)
                _currentView(current, file),
                Container(
                  width: 2.0,
                  height: double.infinity,
                  color: Colors.black,
                ),
                // version you're comparing current with (uneditable)
                _comparedView(current, file),
              ],
            ),
          ),
      ],
    );
  }

  /// CURRENT
  Widget _currentView(VersionFile current, VersionFile compared) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        color: const Color(0xFF1A1A1A),
        child: Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 20.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${current.code} - ${'version_control.current'.tr()}',
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  // back to menu button
                  WrtTooltip(
                    key: const Key('back_to_menu_button'),
                    content: 'version_control.compare_page.back_to_menu'.tr(),
                    showOnTheLeft: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _fileController.clear();
                          setState(() {
                            _selectedId = null;
                            _selectedType = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(4.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.white10,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.menu_open,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  // previous change
                  WrtTooltip(
                    key: const Key('previous_change_button'),
                    content:
                        'version_control.compare_page.previous_change'.tr(),
                    showOnTheLeft: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(4.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.white10,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.arrow_upward,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  // next change
                  WrtTooltip(
                    key: const Key('next_change_button'),
                    content: 'version_control.compare_page.next_change'.tr(),
                    showOnTheLeft: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _fileController.nextChange();
                        },
                        borderRadius: BorderRadius.circular(4.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.white10,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.arrow_downward,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  // local search
                  WrtTooltip(
                    key: const Key('search_button'),
                    content: 'version_control.compare_page.search'.tr(),
                    showOnTheLeft: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(4.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.white10,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.plagiarism_outlined,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedType == null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  children: [
                    _fileButton(
                      type: FileType.general,
                      label: 'project.general'.tr(),
                      modificationStatus: _getModificationStatus(
                        FileType.general,
                      ),
                      icon: const Icon(Icons.info_outline),
                    ),
                    _fileButton(
                      type: FileType.timelineEditor,
                      label: 'project.timeline'.tr(),
                      modificationStatus: _getModificationStatus(
                        FileType.timelineEditor,
                      ),
                      icon: const Icon(Icons.timeline),
                    ),
                    WrtExpandableSection(
                      header: _fileButton(
                        type: null,
                        label: 'project.editors'.tr(),
                        modificationStatus: '',
                        icon: const Icon(Icons.list),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          children: current.chapters.map((e) {
                            return _fileButton(
                              type: FileType.editor,
                              label: e.name,
                              id: e.id,
                              modificationStatus: _getModificationStatus(
                                FileType.editor,
                              ),
                              icon: const Icon(Icons.history_edu),
                            );
                          }).toList(),
                        ),
                      ),
                      initiallyExpanded: true,
                    ),
                    WrtExpandableSection(
                      header: _fileButton(
                        type: null,
                        label: 'project.characters'.tr(),
                        modificationStatus: '',
                        icon: const Icon(Icons.list),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          children: current.characters.map((e) {
                            return _fileButton(
                              type: FileType.characterEditor,
                              label: e.name,
                              id: e.id,
                              modificationStatus: _getModificationStatus(
                                FileType.characterEditor,
                              ),
                              icon: const Icon(Icons.person_outline),
                            );
                          }).toList(),
                        ),
                      ),
                      initiallyExpanded: true,
                    ),
                    WrtExpandableSection(
                      header: _fileButton(
                        type: null,
                        label: 'project.threads'.tr(),
                        modificationStatus: '',
                        icon: const Icon(Icons.list),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          children: current.threads.map((e) {
                            return _fileButton(
                              type: FileType.threadEditor,
                              label: e.name,
                              id: e.id,
                              modificationStatus: _getModificationStatus(
                                FileType.threadEditor,
                              ),
                              icon: const Icon(Icons.upcoming_outlined),
                            );
                          }).toList(),
                        ),
                      ),
                      initiallyExpanded: true,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  controller: _currentScroll,
                  child: ComparableFile(
                    file1: current,
                    file2: compared,
                    selectedId: _selectedId,
                    selectedType: _selectedType,
                    controller: _fileController,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getModificationStatus(FileType type, [String? id]) {
    // TODO: this
    return '';
  }

  Color _getModificationColor(String modification) {
    // TODO: this
    return Colors.grey;
  }

  Widget _fileButton({
    required FileType? type,
    required String label,
    required String modificationStatus,
    Icon? icon,
    String? id,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: type == null
            ? null
            : () {
                setState(() {
                  _selectedId = id;
                  _selectedType = type;
                });
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (icon != null)
                      Icon(
                        icon.icon,
                        size: 20.0,
                        color: Colors.grey,
                      ),
                    if (icon != null)
                      const SizedBox(width: 10.0)
                    else
                      const SizedBox(width: 30.0),
                    Text(
                      label,
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              Text(
                modificationStatus,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getModificationColor(modificationStatus),
                ),
              ),
              const SizedBox(width: 5.0),
            ],
          ),
        ),
      ),
    );
  }

  /// COMPARED
  Widget _comparedView(VersionFile current, VersionFile compared) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8.0,
              spreadRadius: 2.0,
              offset: Offset(-2.0, 10.0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 20.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${compared.code} - ${compared.commited ? 'version_control.commited'.tr() : 'version_control.uncommited'.tr()}',
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  const SizedBox(width: 5.0),
                  // similarity percentage
                  WrtTooltip(
                    key: const Key('similarity_percentage_button'),
                    content:
                        'version_control.compare_page.show_similarity_percentage'
                            .tr(),
                    showOnTheLeft: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(4.0),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.white10,
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.percent,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedType == null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  children: [
                    _fileButton(
                      type: FileType.general,
                      label: 'project.general'.tr(),
                      modificationStatus: _getModificationStatus(
                        FileType.general,
                      ),
                      icon: const Icon(Icons.info_outline),
                    ),
                    _fileButton(
                      type: FileType.timelineEditor,
                      label: 'project.timeline'.tr(),
                      modificationStatus: _getModificationStatus(
                        FileType.timelineEditor,
                      ),
                      icon: const Icon(Icons.timeline),
                    ),
                    WrtExpandableSection(
                      header: _fileButton(
                        type: null,
                        label: 'project.editors'.tr(),
                        modificationStatus: '',
                        icon: const Icon(Icons.list),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          children: compared.chapters.map((e) {
                            return _fileButton(
                              type: FileType.editor,
                              label: e.name,
                              modificationStatus: _getModificationStatus(
                                FileType.editor,
                              ),
                              icon: const Icon(Icons.history_edu),
                            );
                          }).toList(),
                        ),
                      ),
                      initiallyExpanded: true,
                    ),
                    WrtExpandableSection(
                      header: _fileButton(
                        type: null,
                        label: 'project.characters'.tr(),
                        modificationStatus: '',
                        icon: const Icon(Icons.list),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          children: compared.characters.map((e) {
                            return _fileButton(
                              type: FileType.characterEditor,
                              label: e.name,
                              modificationStatus: _getModificationStatus(
                                FileType.characterEditor,
                              ),
                              icon: const Icon(Icons.person_outline),
                            );
                          }).toList(),
                        ),
                      ),
                      initiallyExpanded: true,
                    ),
                    WrtExpandableSection(
                      header: _fileButton(
                        type: null,
                        label: 'project.threads'.tr(),
                        modificationStatus: '',
                        icon: const Icon(Icons.list),
                      ),
                      content: Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Column(
                          children: compared.threads.map((e) {
                            return _fileButton(
                              type: FileType.threadEditor,
                              label: e.name,
                              modificationStatus: _getModificationStatus(
                                FileType.threadEditor,
                              ),
                              icon: const Icon(Icons.upcoming_outlined),
                            );
                          }).toList(),
                        ),
                      ),
                      initiallyExpanded: true,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  controller: _comparedScroll,
                  child: ComparableFile(
                    file1: compared,
                    file2: current,
                    compared: true,
                    selectedId: _selectedId,
                    selectedType: _selectedType,
                    controller: _fileController,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
