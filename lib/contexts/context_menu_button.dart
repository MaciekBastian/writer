import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

class ContextMenuButton extends StatelessWidget {
  const ContextMenuButton({
    super.key,
    required this.callback,
    required this.label,
  });

  final void Function() callback;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.contextMenuOverlay.hide();
            callback();
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: const Color(0x92503BAD),
          borderRadius: BorderRadius.circular(6.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 15.0,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelMedium,
            ),
          ),
        ),
      ),
    );
  }
}
