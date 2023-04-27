import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/project_state.dart';

class StyledTextController extends TextEditingController {
  StyledTextController({String? text}) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final highlightWord = provider.isProjectOpened
        ? provider.shouldHighlightSearchResults
            ? provider.projectSearchQuery.trim().toLowerCase()
            : null
        : null;
    if (highlightWord == null) {
      return super.buildTextSpan(
        context: context,
        withComposing: withComposing,
        style: style,
      );
    } else {
      if (!(text.toLowerCase().contains(highlightWord))) {
        return super.buildTextSpan(
          context: context,
          withComposing: withComposing,
          style: style,
        );
      }
      final input = text.toLowerCase();
      final matches = highlightWord.allMatches(input.toLowerCase()).toList();
      if (matches.isEmpty) {
        return super.buildTextSpan(
          context: context,
          withComposing: withComposing,
          style: style,
        );
      }
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
                  style: style,
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
}
