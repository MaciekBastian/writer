import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../contexts/text_context_menu.dart';
import '../../providers/project_state.dart';

class AdvancedSearchPage extends StatefulWidget {
  static const pageName = '/search';
  const AdvancedSearchPage({super.key});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  Timer? _editTimer;
  final _searchController = TextEditingController();
  final _searchNode = FocusNode();

  final _mustIncludeNode = FocusNode();
  final _mustIncludeController = TextEditingController();
  final _excludeNode = FocusNode();
  final _excludeController = TextEditingController();

  final List<String> _mustInclude = [];
  final List<String> _exclude = [];

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
    final provider = Provider.of<ProjectState>(context, listen: false);
    final project = Provider.of<ProjectState>(context);

    return ListView(
      padding: const EdgeInsets.all(10.0),
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
            key: const Key('advenced_search_generic_query'),
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
              hintText: 'search.generic_query'.tr(),
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
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'search.must_include'.tr(),
              style: theme.textTheme.labelLarge,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _mustInclude.clear();
                  });
                },
                child: const Icon(
                  Icons.clear_all,
                  size: 20.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.0),
        if (_mustInclude.isNotEmpty)
          Text.rich(
            TextSpan(
              children: _mustInclude.map((e) {
                return TextSpan(
                  children: [
                    TextSpan(text: e, style: theme.textTheme.bodyMedium),
                    const WidgetSpan(child: SizedBox(width: 2.0)),
                    WidgetSpan(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _mustInclude.remove(e);
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 10.0)),
                  ],
                );
              }).toList(),
            ),
          ),
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
            key: const Key('advenced_search_must_include'),
            controller: _mustIncludeController,
            autofocus: true,
            focusNode: _mustIncludeNode,
            contextMenuBuilder: (context, editableTextState) {
              return TextContextMenu(
                editableTextState: editableTextState,
              );
            },
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(0.0),
              hintText: 'search.must_include'.tr(),
              isDense: true,
            ),
            onChanged: (value) {
              if (value.endsWith(';')) {
                setState(() {
                  _mustInclude.add(value.substring(0, value.length - 1));
                  _mustIncludeController.text = '';
                  _mustIncludeController.selection = TextSelection.fromPosition(
                    const TextPosition(offset: 0),
                  );
                  _mustIncludeNode.requestFocus();
                });
              }
            },
            scrollPadding: const EdgeInsets.all(0.0),
            minLines: 1,
            maxLines: 1,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          'search.separate_with_semicolon'.tr(),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'search.exclude'.tr(),
              style: theme.textTheme.labelLarge,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _exclude.clear();
                  });
                },
                child: const Icon(
                  Icons.clear_all,
                  size: 20.0,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.0),
        if (_exclude.isNotEmpty)
          Text.rich(
            TextSpan(
              children: _exclude.map((e) {
                return TextSpan(
                  children: [
                    TextSpan(text: e, style: theme.textTheme.bodyMedium),
                    const WidgetSpan(child: SizedBox(width: 2.0)),
                    WidgetSpan(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _exclude.remove(e);
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 20.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 10.0)),
                  ],
                );
              }).toList(),
            ),
          ),
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
            key: const Key('advenced_search_exclude'),
            controller: _excludeController,
            autofocus: true,
            focusNode: _excludeNode,
            contextMenuBuilder: (context, editableTextState) {
              return TextContextMenu(
                editableTextState: editableTextState,
              );
            },
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(0.0),
              hintText: 'search.exclude'.tr(),
              isDense: true,
            ),
            onChanged: (value) {
              if (value.endsWith(';')) {
                setState(() {
                  _exclude.add(value.substring(0, value.length - 1));
                  _excludeController.text = '';
                  _excludeController.selection = TextSelection.fromPosition(
                    const TextPosition(offset: 0),
                  );
                  _excludeNode.requestFocus();
                });
              }
            },
            scrollPadding: const EdgeInsets.all(0.0),
            minLines: 1,
            maxLines: 1,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          'search.separate_with_semicolon'.tr(),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
