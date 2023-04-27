import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sidebar_tab.dart';
import '../providers/project_state.dart';

class TextContextMenu extends StatelessWidget {
  const TextContextMenu({
    super.key,
    this.editableTextState,
    this.selectableRegionState,
  }) : assert(editableTextState != null || selectableRegionState != null);

  final EditableTextState? editableTextState;
  final SelectableRegionState? selectableRegionState;

  @override
  Widget build(BuildContext context) {
    final anchors = editableTextState?.contextMenuAnchors ??
        selectableRegionState?.contextMenuAnchors;
    final provider = Provider.of<ProjectState>(context, listen: false);
    final theme = Theme.of(context);
    const height = 140.0;
    final anchor = anchors!.primaryAnchor;
    final screenSize = MediaQuery.of(context).size;
    final fitsBelow = anchor.dy + height + 30.0 <= screenSize.height;
    final fitsOnLeft = anchor.dx + 230.0 <= screenSize.width;

    return CustomSingleChildLayout(
      delegate: _TextMenuDelegate(
        anchorBelow: Offset(
          fitsOnLeft ? anchor.dx : anchor.dx - 200.0,
          anchor.dy + 10.0,
        ),
        anchorAbove: Offset(
          fitsOnLeft ? anchor.dx : anchor.dx - 200.0,
          anchor.dy - height - 20.0,
        ),
        fitsBelow: fitsBelow,
      ),
      child: Container(
        width: 200.0,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.canvasColor, width: 2.0),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  editableTextState?.copySelection(
                    SelectionChangedCause.toolbar,
                  );
                  // TODO: replace deprecation
                  selectableRegionState?.copySelection(
                    SelectionChangedCause.toolbar,
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 25.0,
                  ),
                  child: Text(
                    'context_menu.copy'.tr(),
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ),
            ),
            if (editableTextState != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    editableTextState?.cutSelection(
                      SelectionChangedCause.toolbar,
                    );
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 25.0,
                    ),
                    child: Text(
                      'context_menu.cut'.tr(),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            if (editableTextState != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    editableTextState?.pasteText(
                      SelectionChangedCause.toolbar,
                    );
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 25.0,
                    ),
                    child: Text(
                      'context_menu.paste'.tr(),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  editableTextState?.selectAll(
                    SelectionChangedCause.toolbar,
                  );
                  selectableRegionState?.selectAll(
                    SelectionChangedCause.toolbar,
                  );
                },
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 25.0,
                  ),
                  child: Text(
                    'context_menu.select_all'.tr(),
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ),
            ),
            const Divider(
              color: Color(0xFF212121),
              height: 10.0,
              thickness: 2.0,
              indent: 5.0,
              endIndent: 5.0,
            ),
            if (editableTextState != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final value = editableTextState!.textEditingValue;
                    if (value.selection.start == -1 &&
                        value.selection.start == -1) {
                      return;
                    }
                    final content = value.text.substring(
                      value.selection.start == -1 ? 0 : value.selection.start,
                      value.selection.end == -1
                          ? 0
                          : value.selection.end >= value.selection.start
                              ? value.selection.end
                              : value.selection.start == -1
                                  ? 0
                                  : value.selection.start,
                    );

                    if (content.isEmpty) return;

                    provider.projectSearch(content.trim().toLowerCase());
                    provider.switchSidebarTab(SidebarTab.projectSearch);
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 25.0,
                    ),
                    child: Text(
                      'context_menu.search_for_this_phrase'.tr(),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TextMenuDelegate extends SingleChildLayoutDelegate {
  _TextMenuDelegate({
    required this.anchorAbove,
    required this.anchorBelow,
    required this.fitsBelow,
  });

  final Offset anchorAbove;
  final Offset anchorBelow;
  final bool fitsBelow;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (fitsBelow) {
      return anchorBelow;
    } else {
      return anchorAbove;
    }
  }

  @override
  bool shouldRelayout(_TextMenuDelegate oldDelegate) {
    return anchorAbove != oldDelegate.anchorAbove ||
        anchorBelow != oldDelegate.anchorBelow ||
        fitsBelow != oldDelegate.fitsBelow;
  }
}
