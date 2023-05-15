import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../models/chapters/chapter_file.dart';
import '../../../providers/project_state.dart';
import '../../../widgets/tooltip.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late quill.QuillController _controller;
  late StreamSubscription _changesStream;
  Timer? _changeTimer;
  String? _chapterId;

  final _documentFocus = FocusNode();
  final _documentScroll = ScrollController();
  final _toolbarScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initialize();
  }

  @override
  void dispose() {
    _changeTimer?.cancel();
    _changesStream.cancel();
    super.dispose();
  }

  void _initialize() {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final chapter = provider.selectedTab?.id;
    final editor = provider.getEditor(chapter ?? '');
    if (_chapterId == chapter) return;
    _chapterId = chapter;
    _controller = editor?.content == null || (editor?.content.isEmpty ?? true)
        ? quill.QuillController.basic()
        : quill.QuillController(
            selection: const TextSelection.collapsed(offset: 0),
            document: quill.Document.fromJson(editor!.content),
          );
    _changesStream = _controller.changes.listen((event) {
      _changeTimer?.cancel();
      _changeTimer = Timer(const Duration(milliseconds: 600), () {
        final newValue = _controller.document.toDelta().toJson();
        if (chapter == null) return;
        provider.registerChangeInChapterEditor(
          ChapterFile(
            chapterId: chapter,
            content: newValue,
            lastModified: DateTime.now(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);
    final chapter = provider.getChapter(provider.selectedTab!.id!);

    return Row(
      key: Key('chapter_editor_${chapter.id}'),
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 40.0,
                color: Colors.grey[900],
                child: ImprovedScrolling(
                  scrollController: _toolbarScroll,
                  enableKeyboardScrolling: true,
                  enableCustomMouseWheelScrolling: true,
                  child: ListView(
                    controller: _toolbarScroll,
                    scrollDirection: Axis.horizontal,
                    children: [
                      quill.QuillToolbar(
                        children: [
                          _toolbarButton(_ToolbarAction.headline1, chapter.id),
                          const SizedBox(width: 10.0),
                          _toolbarButton(_ToolbarAction.bold, chapter.id),
                          _toolbarButton(_ToolbarAction.italic, chapter.id),
                          _toolbarButton(_ToolbarAction.underline, chapter.id),
                          _toolbarButton(
                            _ToolbarAction.strikethrough,
                            chapter.id,
                          ),
                          _toolbarButton(_ToolbarAction.highlight, chapter.id),
                          const SizedBox(width: 10.0),
                          _toolbarButton(_ToolbarAction.alignLeft, chapter.id),
                          _toolbarButton(
                            _ToolbarAction.alignCenter,
                            chapter.id,
                          ),
                          _toolbarButton(_ToolbarAction.alignRight, chapter.id),
                          _toolbarButton(
                            _ToolbarAction.alignJustify,
                            chapter.id,
                          ),
                          const SizedBox(width: 10.0),
                          _toolbarButton(
                            _ToolbarAction.increaseIndent,
                            chapter.id,
                          ),
                          _toolbarButton(
                            _ToolbarAction.decreaseIndent,
                            chapter.id,
                          ),
                          const SizedBox(width: 10.0),
                          _toolbarButton(_ToolbarAction.ol, chapter.id),
                          _toolbarButton(_ToolbarAction.ul, chapter.id),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.keyZ,
                        control: true): () {
                      _controller.undo();
                    },
                    const SingleActivator(LogicalKeyboardKey.keyY,
                        control: true): () {
                      _controller.redo();
                    }
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.text,
                    child: quill.QuillEditor(
                      key: Key('chapter_text_editor_${chapter.id}'),
                      controller: _controller,
                      focusNode: _documentFocus,
                      scrollable: true,
                      scrollController: _documentScroll,
                      readOnly: false,
                      autoFocus: false,
                      expands: true,
                      padding: const EdgeInsets.all(10.0),
                      detectWordBoundary: false,
                      showCursor: true,
                      onImagePaste: (_) async => null,
                      textSelectionControls: DesktopTextSelectionControls(),
                      enableInteractiveSelection: true,
                      enableSelectionToolbar: false,
                      customStyles: quill.DefaultStyles(
                        underline: const TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 16.0,
                          decoration: TextDecoration.underline,
                        ),
                        h1: quill.DefaultTextBlockStyle(
                          const TextStyle(
                            color: Colors.white,
                          ),
                          const Tuple2(10, 10),
                          const Tuple2(0, 0),
                          null,
                        ),
                        paragraph: quill.DefaultTextBlockStyle(
                          const TextStyle(
                            fontFamily: 'NotoSerif',
                            fontSize: 16.0,
                          ),
                          const Tuple2(0, 0),
                          const Tuple2(0, 0),
                          null,
                        ),
                      ),
                      customStyleBuilder: (attribute) {
                        return TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize:
                              attribute == quill.Attribute.h1 ? 32.0 : 16.0,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 250.0,
          height: double.infinity,
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 15.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.edit_outlined),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'editor.edit_chapter_data_hint'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                'editor.outline'.tr(),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView(
                  children: const [
                    // TODO: add chapter outline
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toolbarButton(_ToolbarAction action, String chptr) {
    late final Icon icon;
    late final String name;
    late final quill.Attribute attribute;
    switch (action) {
      case _ToolbarAction.bold:
        icon = const Icon(Icons.format_bold);
        name = 'editor.actions.bold';
        attribute = quill.Attribute.bold;
        break;
      case _ToolbarAction.underline:
        icon = const Icon(Icons.format_underline);
        name = 'editor.actions.underline';
        attribute = quill.Attribute.underline;
        break;
      case _ToolbarAction.italic:
        icon = const Icon(Icons.format_italic);
        name = 'editor.actions.italic';
        attribute = quill.Attribute.italic;
        break;
      case _ToolbarAction.strikethrough:
        icon = const Icon(Icons.format_strikethrough);
        name = 'editor.actions.strikethrough';
        attribute = quill.Attribute.strikeThrough;
        break;
      case _ToolbarAction.highlight:
        icon = const Icon(Icons.highlight_outlined);
        name = 'editor.actions.highlight';
        attribute = quill.Attribute.blockQuote;
        break;
      case _ToolbarAction.ul:
        icon = const Icon(Icons.format_list_bulleted);
        name = 'editor.actions.unnumbered_list';
        attribute = quill.Attribute.ul;
        break;
      case _ToolbarAction.ol:
        icon = const Icon(Icons.format_list_numbered);
        name = 'editor.actions.numbered_list';
        attribute = quill.Attribute.ol;
        break;
      case _ToolbarAction.alignCenter:
        icon = const Icon(Icons.format_align_center);
        name = 'editor.actions.center';
        attribute = quill.Attribute.centerAlignment;
        break;
      case _ToolbarAction.alignLeft:
        icon = const Icon(Icons.format_align_left);
        name = 'editor.actions.left';
        attribute = quill.Attribute.leftAlignment;
        break;
      case _ToolbarAction.alignRight:
        icon = const Icon(Icons.format_align_right);
        name = 'editor.actions.right';
        attribute = quill.Attribute.rightAlignment;
        break;
      case _ToolbarAction.alignJustify:
        icon = const Icon(Icons.format_align_justify);
        name = 'editor.actions.justify';
        attribute = quill.Attribute.justifyAlignment;
        break;
      case _ToolbarAction.decreaseIndent:
        icon = const Icon(Icons.format_indent_decrease);
        name = 'editor.actions.decrease_indent';
        attribute = quill.Attribute.indentL1;
        break;
      case _ToolbarAction.increaseIndent:
        icon = const Icon(Icons.format_indent_increase);
        name = 'editor.actions.increase_indent';
        attribute = quill.Attribute.indentL2;
        break;
      case _ToolbarAction.headline1:
        icon = const Icon(Icons.title);
        name = 'editor.actions.headline_1';
        attribute = quill.Attribute.h1;
        break;
    }

    return quill.ToggleStyleButton(
      attribute: attribute,
      icon: icon.icon!,
      controller: _controller,
      childBuilder: (context, _, __, ___, isToggled, onPressed, ____,
          [iconSize = 20.0, _____]) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: (isToggled ?? false) ? Colors.white10 : Colors.transparent,
          ),
          child: WrtTooltip(
            key: Key('${action.name}_controller_in_editor_of_$chptr'),
            showOnTheBottom: true,
            content: name.tr(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  onPressed!();
                  _documentFocus.requestFocus();
                },
                child: SizedBox(
                  width: 35.0,
                  height: 35.0,
                  child: icon,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _ToolbarAction {
  bold,
  underline,
  italic,
  strikethrough,
  highlight,
  ul,
  ol,
  alignCenter,
  alignLeft,
  alignRight,
  alignJustify,
  decreaseIndent,
  increaseIndent,
  headline1,
}
