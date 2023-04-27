import 'package:flutter/material.dart';

class WrtButton extends StatelessWidget {
  const WrtButton({
    super.key,
    required this.callback,
    required this.label,
    this.color,
  });

  final String label;
  final void Function() callback;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: callback,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: color ?? Colors.grey[700]!,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
