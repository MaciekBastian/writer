import 'package:flutter/material.dart';

class WrtMenuItem {
  final String label;
  final bool? checked;
  final String? shortcut;
  final void Function() callback;

  WrtMenuItem({
    required this.label,
    required this.callback,
    this.checked,
    this.shortcut,
  });
}

class WtrMenuButton extends StatefulWidget {
  const WtrMenuButton({
    required this.items,
    super.key,
    this.icon,
    this.showOnLeft = false,
    this.autoDecideIfShowOnLeft = false,
  });

  final List<WrtMenuItem> items;
  final Widget? icon;
  final bool showOnLeft;
  final bool autoDecideIfShowOnLeft;

  @override
  State<WtrMenuButton> createState() => _WtrMenuButtonState();
}

class _WtrMenuButtonState extends State<WtrMenuButton> {
  OverlayEntry? _overlayEntry;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _getOverlay();
        Overlay.of(context).insert(_overlayEntry!);
      } else {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _overlayEntry?.remove();
  }

  OverlayEntry _getOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final height = (widget.items.length * 35.0 > 400
            ? 400.0
            : widget.items.length * 35.0) +
        15.0;

    final shouldBeOnTheBottom = offset.dy + (height) >= screenSize.height;
    final shouldBeOnTheLeft = offset.dx + 300.0 >= screenSize.width;

    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Positioned(
          left: offset.dx -
              (widget.showOnLeft
                  ? 300.0 - 25.0
                  : widget.autoDecideIfShowOnLeft
                      ? shouldBeOnTheLeft
                          ? 300.0 - 25.0
                          : 0
                      : 0),
          top: shouldBeOnTheBottom
              ? (offset.dy - height)
              : (offset.dy + size.height),
          width: 300.0,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 49, 49, 49),
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.grey[600]!,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 5.0,
            ),
            child: MouseRegion(
              onEnter: (_) {
                _focusNode.requestFocus();
              },
              onExit: (_) {
                Future.delayed(const Duration(milliseconds: 150), () {
                  _focusNode.unfocus();
                });
              },
              child: Material(
                color: Colors.transparent,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: widget.items.map((e) {
                    return SizedBox(
                      height: 35.0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        hoverColor: const Color.fromARGB(146, 80, 59, 173),
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          e.callback();
                          _focusNode.unfocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 20.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  e.label,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                              ),
                              if (e.shortcut != null)
                                Text(
                                  e.shortcut!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _focusNode.requestFocus();
        },
        focusNode: _focusNode,
        hoverColor: Colors.grey[850],
        splashColor: Colors.transparent,
        focusColor: Colors.grey[850],
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        child: SizedBox(
          width: 25.0,
          height: 25.0,
          child: widget.icon ??
              Icon(
                Icons.more_vert,
                color: Colors.grey[400],
                size: 20.0,
              ),
        ),
      ),
    );
  }
}
