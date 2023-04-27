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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.contextMenuOverlay.hide();
          callback();
        },
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 25.0),
          child: Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}
