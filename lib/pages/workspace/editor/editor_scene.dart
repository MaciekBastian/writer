import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:tuple/tuple.dart';

import '../../../helpers/general_helper.dart';
import '../../../models/chapters/chapter_file.dart';
import '../../../providers/project_state.dart';

class SceneEditor extends StatefulWidget {
  const SceneEditor({super.key});

  @override
  State<SceneEditor> createState() => _SceneEditorState();
}

class _SceneEditorState extends State<SceneEditor> {
  late quill.QuillController _controller;
  late StreamSubscription _changesStream;
  final _focus = FocusNode();
  Timer? _changeTimer;
  String? _chapterId;

  final _documentFocus = FocusNode();
  final _documentScroll = ScrollController();
  final _toolbarScroll = ScrollController();

  OverlayEntry? _overlay;

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
    _overlay?.remove();
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
      _analyzeCurrentWord();
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

  void _analyzeCurrentWord() {
    _removeOverlay();
    final provider = Provider.of<ProjectState>(context, listen: false);
    final quickSuggestionsValues = [
      ...provider.characters.values,
      ...GeneralHelper().getUnifiedList(
        provider.openedCharacters.map((e) => e.aliases).toList(),
      ),
    ];
    final cursor = _controller.selection.end;
    final lastWord = _controller.plainTextEditingValue.text
        .substring(cursor - 100 < 0 ? 0 : cursor - 100, cursor)
        .split(' ')
        .last;

    if (lastWord.isEmpty) return;
    final similarities = quickSuggestionsValues
        .map((e) => StringSimilarity.compareTwoStrings(e, lastWord))
        .toList();
    List<String> results = [];
    for (int i = 0; i < similarities.length; i++) {
      var element = similarities[i];
      if (element >= 0.5) {
        results.add(quickSuggestionsValues[i]);
      }
    }

    if (results.isNotEmpty) {
      final resultsTrimmed = results
          .getRange(
            0,
            results.length > 10 ? 10 : results.length,
          )
          .toList();
      _overlay = _buildOverlay(resultsTrimmed);
      Overlay.of(context).insert(_overlay!);
    }
  }

  OverlayEntry _buildOverlay(List<String> quickSuggestions) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context);

    final texts = quickSuggestions.map((e) {
      return TextPainter(
        text: TextSpan(
            text: e,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF242424),
            )),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
    }).toList();
    final maxWidth = texts.map((e) {
      e.layout(maxWidth: 180.0, minWidth: 80.0);
      return e.size.width;
    }).reduce(math.max);

    // TODO: position where cursor

    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Positioned(
          top: _documentFocus.offset.dy,
          left: _documentFocus.offset.dx,
          child: Container(
            width: maxWidth,
            height: quickSuggestions.length * 18.0,
            decoration: const BoxDecoration(
              color: Colors.grey,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: texts.map((e) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.white30,
                    onTap: () {
                      // TODO: insert
                    },
                    child: Container(
                      width: maxWidth,
                      height: 18.0,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(e.text!),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _removeOverlay() {
    if (_overlay != null) {
      _overlay?.remove();
      _overlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TODO: editor
    return CallbackShortcuts(
      bindings: {
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: !Platform.isMacOS,
          meta: Platform.isMacOS,
        ): () {
          _controller.undo();
        },
        if (!Platform.isMacOS)
          const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
            _controller.redo();
          },
        if (Platform.isMacOS)
          const SingleActivator(
            LogicalKeyboardKey.keyZ,
            shift: true,
            meta: true,
          ): () {
            _controller.redo();
          },
        SingleActivator(
          LogicalKeyboardKey.enter,
          control: !Platform.isMacOS,
          meta: Platform.isMacOS,
        ): () {
          // TODO: ADD NEW SCENE
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: quill.QuillEditor(
          // key: Key('chapter_text_editor_${chapter.id}'),
          controller: _controller,
          focusNode: _documentFocus,
          scrollable: true,
          scrollController: _documentScroll,
          readOnly: false,
          autoFocus: false,
          expands: true,
          padding: const EdgeInsets.all(10.0),
          detectWordBoundary: true,
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
              fontSize: attribute == quill.Attribute.h1 ? 32.0 : 16.0,
            );
          },
        ),
      ),
    );
  }
}
