import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../contexts/text_context_menu.dart';

import '../../providers/project_state.dart';

class ChapterSnippet extends StatelessWidget {
  const ChapterSnippet({
    super.key,
    required this.chapterId,
  });

  final String chapterId;

  TextSpan _buildText(String text, String highlightWord, TextStyle? style) {
    if (highlightWord.isEmpty) {
      return TextSpan(text: text, style: style);
    } else {
      final input = text.toLowerCase();
      final matches = highlightWord.allMatches(input.toLowerCase()).toList();
      if (matches.isEmpty) return TextSpan(text: text, style: style);
      final rangeFirst = TextRange(
        start: matches.first.start,
        end: matches.first.end,
      );
      return TextSpan(
        style: style,
        children: [
          TextSpan(
            text: rangeFirst.textBefore(text),
            style: style,
          ),
          ...List.generate(matches.length, (index) {
            final e = matches[index];
            final range = TextRange(start: e.start, end: e.end);
            final next =
                index == matches.length - 1 ? null : matches[index + 1];
            return TextSpan(
              children: [
                TextSpan(
                  text: range.textInside(text),
                  style: style?.copyWith(
                    backgroundColor: Colors.yellow[900]?.withOpacity(0.6),
                  ),
                ),
                TextSpan(
                  text: text.substring(
                    range.end,
                    next?.start,
                  ),
                ),
              ],
            );
          }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    final chapter = provider.getChapter(chapterId);
    final highlightWord = provider.projectSearchQuery.trim().toLowerCase();

    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 15.0,
      ),
      children: [
        SelectableText.rich(
          _buildText(
            chapter.name,
            highlightWord,
            theme.textTheme.headlineSmall,
          ),
          contextMenuBuilder: (context, editableTextState) {
            return TextContextMenu(editableTextState: editableTextState);
          },
        ),
        const SizedBox(height: 4.0),
        const Divider(),
        const SizedBox(height: 4.0),
        if (chapter.description.trim().isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText.rich(
                _buildText(
                  chapter.description,
                  highlightWord,
                  theme.textTheme.bodyMedium,
                ),
                textAlign: TextAlign.justify,
                contextMenuBuilder: (context, editableTextState) {
                  return TextContextMenu(editableTextState: editableTextState);
                },
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        Text(
          'right_sidebar.scenes'.tr(),
          style: theme.textTheme.bodySmall,
        ),
        ...chapter.scenes.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 3.0, top: 2.0),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ((e.name?.isEmpty ?? true) ? null : e.name) ??
                      '${'right_sidebar.scene'.tr()}: ${e.index + 1}',
                  style: theme.textTheme.titleMedium,
                ),
                const Divider(),
                const SizedBox(height: 4.0),
                if (e.description.trim().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText.rich(
                        _buildText(
                          e.description,
                          highlightWord,
                          theme.textTheme.bodyMedium,
                        ),
                        textAlign: TextAlign.justify,
                        contextMenuBuilder: (context, editableTextState) {
                          return TextContextMenu(
                              editableTextState: editableTextState);
                        },
                      ),
                      const SizedBox(height: 12.0),
                    ],
                  ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 50.0),
      ],
    );
  }
}
