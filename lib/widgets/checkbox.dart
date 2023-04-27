import 'package:flutter/material.dart';

class WrtCheckbox extends StatefulWidget {
  const WrtCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.callback,
  });

  final bool value;
  final String label;
  final VoidCallback callback;

  @override
  State<WrtCheckbox> createState() => _WrtCheckboxState();
}

class _WrtCheckboxState extends State<WrtCheckbox> {
  bool _focusing = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _focusing = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _focusing = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _focusing = false;
        });
      },
      onTap: () {
        widget.callback();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 20.0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _focusing ? 19.0 : 20.0,
            height: _focusing ? 19.0 : 20.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.grey[800],
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: widget.value
                ? const Icon(
                    Icons.done,
                    size: 15.0,
                  )
                : null,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 22.0,
              child: Text(
                widget.label,
                style: theme.textTheme.labelMedium,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
      ),
    );
  }
}
