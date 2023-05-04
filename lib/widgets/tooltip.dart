import 'package:flutter/material.dart';

class WrtTooltip extends StatefulWidget {
  const WrtTooltip({
    required super.key,
    required this.child,
    required this.content,
    this.showOnTheLeft = false,
    this.showOnTheBottom = false,
    this.aboveVersion = false,
    this.onMouseEvent,
  });

  final String content;
  final bool showOnTheLeft;
  final bool showOnTheBottom;
  final bool aboveVersion;
  final Widget child;
  final void Function(bool hovering)? onMouseEvent;

  @override
  State<WrtTooltip> createState() => _WrtTooltipState();
}

class _WrtTooltipState extends State<WrtTooltip> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (_overlayEntry != null) {
          _overlayEntry?.remove();
          setState(() {
            _overlayEntry = null;
          });
        }
      },
      onTap: () {
        if (_overlayEntry != null) {
          _overlayEntry?.remove();
          setState(() {
            _overlayEntry = null;
          });
        }
      },
      child: MouseRegion(
        onEnter: (event) {
          if (widget.onMouseEvent != null) {
            widget.onMouseEvent!(true);
          }
          if (event.down) {
            _overlayEntry = null;
            return;
          }
          _overlayEntry = _createOverlayEntry();
          Overlay.of(context).insert(_overlayEntry!);
        },
        onExit: (event) {
          if (widget.onMouseEvent != null) {
            widget.onMouseEvent!(false);
          }
          _overlayEntry?.remove();
          setState(() {
            _overlayEntry = null;
          });
        },
        child: widget.child,
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    final text = TextPainter(
      text: TextSpan(
        text: widget.content,
        style: Theme.of(context).textTheme.labelMedium,
      ),
      textDirection: TextDirection.ltr,
    );
    text.layout(maxWidth: 150.0);

    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: widget.showOnTheBottom
            ? widget.showOnTheLeft
                ? offset.dx - text.size.width
                : offset.dx
            : widget.showOnTheLeft
                ? offset.dx - text.size.width - size.width
                : offset.dx + size.width + 10.0,
        top: widget.showOnTheBottom
            ? offset.dy + size.height + 5.0
            : offset.dy + ((size.height - 25.0) / 2),
        height: 25.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 49, 49, 49),
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.grey[600]!,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                )
              ],
            ),
            child: Text(
              widget.content,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
      ),
    );
  }
}
