import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/threads/thread.dart';
import '../../providers/project_state.dart';

class ThreadSnippet extends StatelessWidget {
  const ThreadSnippet({
    super.key,
    required this.threadId,
  });

  final String threadId;

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
    final provider = Provider.of<ProjectState>(context);
    final theme = Theme.of(context);

    final highlightWord = provider.projectSearchQuery.trim().toLowerCase();

    return FutureBuilder<Thread?>(
      future: provider.getUpToDateThreadWithoutOpening(threadId),
      builder: (context, snapshot) {
        if (snapshot.data == null) return Container();
        final thread = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Text.rich(
              _buildText(
                thread.name,
                highlightWord,
                theme.textTheme.headlineSmall,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            const Divider(),
            const SizedBox(height: 4.0),
            SelectableText.rich(
              _buildText(
                thread.description,
                highlightWord,
                theme.textTheme.bodyMedium,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'thread.conflict'.tr(),
                        textAlign: TextAlign.justify,
                        style: theme.textTheme.bodySmall,
                      ),
                      SelectableText.rich(
                        _buildText(
                          thread.conflict.isEmpty ? '--' : thread.conflict,
                          highlightWord,
                          theme.textTheme.bodyMedium,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'thread.result'.tr(),
                        textAlign: TextAlign.justify,
                        style: theme.textTheme.bodySmall,
                      ),
                      SelectableText.rich(
                        _buildText(
                          thread.result.isEmpty ? '--' : thread.result,
                          highlightWord,
                          theme.textTheme.bodyMedium,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    provider.openThread(thread.id);
                  },
                  child: Text(
                    'errors.open_in_editor'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color.fromARGB(255, 88, 111, 230),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50.0),
          ],
        );
      },
    );
  }
}
