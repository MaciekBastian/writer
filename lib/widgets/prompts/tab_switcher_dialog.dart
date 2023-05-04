import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../helpers/general_helper.dart';
import '../../models/file_tab.dart';
import '../../providers/project_state.dart';

class TabSwitcherDialog extends StatefulWidget {
  static const pageName = '/switcher';
  const TabSwitcherDialog({
    super.key,
    this.revert = false,
  });
  final bool revert;
  @override
  State<TabSwitcherDialog> createState() => _TabSwitcherDialogState();
}

class _TabSwitcherDialogState extends State<TabSwitcherDialog> {
  final _keyboardFocus = FocusNode();
  final _listScroll = ScrollController();
  int _index = 0;
  Duration _lastEventDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProjectState>(context, listen: false);
    _index = provider.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);
    final theme = Theme.of(context);
    final tabs = provider.openedTabs;

    final height = tabs.length * 20.0 > 300.0 ? 300.0 : tabs.length * 20.0;

    final dialog = KeyboardListener(
      focusNode: _keyboardFocus,
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.controlLeft ||
            value.logicalKey == LogicalKeyboardKey.controlRight) {
          if (provider.ctrlTabAutoClose) {
            provider.switchTab(_index);
            Navigator.of(context).pop();
            return;
          }
        }

        if (_lastEventDuration != Duration.zero) {
          if (value.timeStamp.inMilliseconds -
                  _lastEventDuration.inMilliseconds <
              300) {
            return;
          }
        }

        if (value.logicalKey == LogicalKeyboardKey.tab) {
          final newIndex = widget.revert ? _index - 1 : _index + 1;
          setState(() {
            _index = newIndex == tabs.length
                ? 0
                : newIndex == -1
                    ? tabs.length - 1
                    : newIndex;
            _lastEventDuration = value.timeStamp;
          });
        } else if (value.logicalKey == LogicalKeyboardKey.arrowUp ||
            value.logicalKey == LogicalKeyboardKey.arrowDown) {
          final newIndex = value.logicalKey == LogicalKeyboardKey.arrowDown
              ? _index + 1
              : _index - 1;
          setState(() {
            _index = newIndex == tabs.length
                ? 0
                : newIndex == -1
                    ? tabs.length - 1
                    : newIndex;
            _lastEventDuration = value.timeStamp;
          });
        } else if (value.logicalKey == LogicalKeyboardKey.enter) {
          provider.switchTab(_index);
          Navigator.of(context).pop();
          return;
        } else if (value.logicalKey == LogicalKeyboardKey.altLeft ||
            value.logicalKey == LogicalKeyboardKey.altRight) {
          provider.toggleCtrlTabAutoClose();
          setState(() {
            _lastEventDuration = value.timeStamp;
          });
        } else if (value.logicalKey == LogicalKeyboardKey.keyP) {
          if (provider.isTabPinned(tabs[_index])) {
            provider.unpinTab(tabs[_index]);
          } else {
            provider.pinTab(tabs[_index]);
          }
          setState(() {
            _lastEventDuration = value.timeStamp;
          });
        } else if (value.logicalKey == LogicalKeyboardKey.keyS) {
          if (!provider.isSaved(_index)) {
            provider.save(tabs[_index]);
          }
          setState(() {
            _lastEventDuration = value.timeStamp;
          });
        } else if (value.logicalKey == LogicalKeyboardKey.keyC) {
          if (provider.isSaved(_index)) {
            if (_index == tabs.length - 1) _index = _index - 1;
            if (tabs.length > 1) {
              provider.closeTab(_index);
            } else {
              provider.closeTab(0);
              Navigator.of(context).pop();
              return;
            }
          }
          setState(() {
            _lastEventDuration = value.timeStamp;
          });
        }

        _adjustScrolling(height);
      },
      child: Focus(
        autofocus: true,
        canRequestFocus: true,
        descendantsAreTraversable: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          alignment: Alignment.topCenter,
          child: Container(
            width: 500.0,
            height: height + 40.0,
            margin: const EdgeInsets.only(top: 55.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: theme.colorScheme.surfaceVariant,
              boxShadow: const [
                BoxShadow(
                  spreadRadius: 3.0,
                  color: Colors.black45,
                  blurRadius: 20.0,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4.0),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'command_palette.go_to'.tr().toUpperCase(),
                          textAlign: TextAlign.left,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 5.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.white10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.push_pin_outlined,
                              size: 15.0,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text('- P', style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 5.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.white10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.save,
                              size: 15.0,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text('- S', style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 5.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.white10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.close,
                              size: 15.0,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text('- C', style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 5.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: Colors.white10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pin_invoke_outlined,
                              size: 15.0,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text('- Alt', style: theme.textTheme.labelMedium),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15.0),
                    ],
                  ),
                ),
                const Divider(
                  height: 8.0,
                  thickness: 2.0,
                  indent: 4.0,
                  endIndent: 4.0,
                  color: Color(0xFF242424),
                ),
                Expanded(
                  child: ListView(
                    controller: _listScroll,
                    children: tabs.map((e) {
                      final index = tabs.indexOf(e);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 10.0,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: index == _index
                              ? const Color.fromARGB(132, 22, 56, 226)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.id != null
                                    ? e.type == FileType.characterEditor
                                        ? provider.characters[e.id] ?? ''
                                        : e.type == FileType.threadEditor
                                            ? provider.threads[e.id] ?? ''
                                            : e.type == FileType.editor
                                                ? provider
                                                        .chaptersAsMap[e.id] ??
                                                    ''
                                                : ''
                                    : GeneralHelper()
                                        .getFileName(e.type, e.path)
                                        .tr(),
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            if (provider.isTabPinned(e))
                              const Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  Icons.push_pin_outlined,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            if (!provider.isSaved(provider.indexOfTab(e)))
                              Container(
                                width: 10.0,
                                height: 10.0,
                                margin: const EdgeInsets.only(
                                  right: 10.0,
                                ),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (Platform.isMacOS) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(
            LogicalKeyboardKey.tab,
            control: true,
          ): () {
            final newIndex = _index + 1;
            setState(() {
              _index = newIndex == tabs.length
                  ? 0
                  : newIndex == -1
                      ? tabs.length - 1
                      : newIndex;
            });
            _adjustScrolling(height);
          },
          const SingleActivator(
            LogicalKeyboardKey.tab,
            shift: true,
            control: true,
          ): () {
            final newIndex = _index - 1;
            setState(() {
              _index = newIndex == tabs.length
                  ? 0
                  : newIndex == -1
                      ? tabs.length - 1
                      : newIndex;
            });
            _adjustScrolling(height);
          },
        },
        child: dialog,
      );
    } else {
      return dialog;
    }
  }

  void _adjustScrolling(double height) {
    final newOffset = 20.0 * _index;
    final min = _listScroll.position.minScrollExtent;
    final max = _listScroll.position.maxScrollExtent;
    if (newOffset > (height * 0.3)) {
      if ((newOffset - (height * 0.3)) >= max) {
        _listScroll.jumpTo(max);
      } else {
        _listScroll.jumpTo(newOffset - (height * 0.3));
      }
    } else {
      _listScroll.jumpTo(min);
    }
  }
}
