import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../contexts/text_context_menu.dart';
import '../../pages/tools/advanced_search.dart';
import '../tooltip.dart';

import '../../helpers/general_helper.dart';
import '../../models/file_tab.dart';
import '../../providers/project_state.dart';

class ProjectSearchTab extends StatefulWidget {
  const ProjectSearchTab({super.key});

  @override
  State<ProjectSearchTab> createState() => _ProjectSearchTabState();
}

class _ProjectSearchTabState extends State<ProjectSearchTab> {
  Timer? _editTimer;
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  final _searchNode = FocusNode();
  final _replaceNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProjectState>(context, listen: false);
    _searchController.text = provider.projectSearchQuery;
    _searchNode.requestFocus();
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final provider = Provider.of<ProjectState>(context);
    final replaceMode = provider.replaceAutoShown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  provider.toggleReplaceAutoShown();
                },
                child: SizedBox(
                  width: 25.0,
                  height: replaceMode ? 60.0 : 30.0,
                  child: replaceMode
                      ? const Icon(
                          Icons.expand_less,
                          size: 20.0,
                        )
                      : const Icon(
                          Icons.expand_more,
                          size: 20.0,
                        ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 30.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.grey[800],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextField(
                      key: const Key('project_search_field'),
                      controller: _searchController,
                      autofocus: true,
                      focusNode: _searchNode,
                      contextMenuBuilder: (context, editableTextState) {
                        return TextContextMenu(
                          editableTextState: editableTextState,
                        );
                      },
                      decoration: InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(0.0),
                        hintText: 'search.search'.tr(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          provider.clearProjectSearch();
                        }
                        _editTimer?.cancel();
                        _editTimer = Timer(
                          const Duration(milliseconds: 200),
                          () {
                            provider.projectSearch(_searchController.text);
                          },
                        );
                      },
                      scrollPadding: const EdgeInsets.all(0.0),
                      minLines: 1,
                      maxLines: 1,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  if (replaceMode)
                    // TODO: implement replace
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            padding: const EdgeInsets.only(left: 10.0),
                            width: double.infinity,
                            height: 30.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              color: Colors.grey[800],
                            ),
                            child: TextField(
                              key: const Key('project_replace_field'),
                              controller: _replaceController,
                              focusNode: _replaceNode,
                              contextMenuBuilder: (context, editableTextState) {
                                return TextContextMenu(
                                  editableTextState: editableTextState,
                                );
                              },
                              decoration: InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(0.0),
                                hintText: 'search.replace'.tr(),
                                isDense: true,
                              ),
                              scrollPadding: const EdgeInsets.all(0.0),
                              minLines: 1,
                              maxLines: 1,
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        WrtTooltip(
                          key: const Key('replace_all_button'),
                          content: 'search.replace_all'.tr(),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {},
                              child: const SizedBox(
                                width: 25.0,
                                height: 25.0,
                                child: Icon(
                                  Icons.find_replace,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                provider.openTab(
                  FileTab(
                    id: null,
                    path: AdvancedSearchPage.pageName,
                    type: FileType.system,
                  ),
                );
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'search.advanced_search'.tr(),
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        if (provider.hasSearchBeenMade)
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              '${'search.results_for_query'.tr()}${provider.projectSearchQuery}',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.left,
            ),
          ),
        const SizedBox(height: 10.0),
        if (provider.hasSearchBeenMade)
          Expanded(
            child: ListView(
              children: provider.projectSearchResults.map((e) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (e.type == FileType.characterEditor) {
                        if (e.id == null) return;
                        provider.openCharacter(e.id!);
                      } else if (e.type == FileType.threadEditor) {
                        if (e.id == null) return;
                        provider.openThread(e.id!);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const SizedBox(width: 20.0),
                                Icon(
                                  GeneralHelper()
                                      .getTypeIcon(
                                        e.type,
                                        e.path,
                                      )
                                      .icon,
                                  size: 20.0,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5.0),
                                Expanded(
                                  child: Text(
                                    (e.type == FileType.characterEditor
                                            ? provider.characters[e.id!]
                                            : e.type == FileType.threadEditor
                                                ? provider.threads[e.id!]
                                                : e.type == FileType.editor
                                                    ? provider
                                                        .chaptersAsMap[e.id!]
                                                    : GeneralHelper()
                                                        .getFileName(
                                                            e.type, e.path)
                                                        .tr()) ??
                                        '',
                                    style: theme.textTheme.bodyMedium,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 20.0,
                            alignment: Alignment.center,
                            height: 20.0,
                            margin: const EdgeInsets.only(
                              left: 10.0,
                            ),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF303030),
                            ),
                            child: Text(
                              '${e.matches.length}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
