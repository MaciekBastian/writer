import 'package:flutter/material.dart';

class WrtDropdownSelect<T> extends StatefulWidget {
  const WrtDropdownSelect({
    super.key,
    this.title,
    required this.initiallySelected,
    required this.onSelected,
    required this.values,
    required this.labels,
    this.smaller = false,
  });

  final T initiallySelected;
  final List<T> values;
  final void Function(T value) onSelected;
  final String? title;
  final Map<T, String> labels;
  final bool smaller;

  @override
  State<WrtDropdownSelect<T>> createState() => _WrtDropdownSelectState<T>();
}

class _WrtDropdownSelectState<T> extends State<WrtDropdownSelect<T>> {
  final _globalKey = GlobalKey();
  T? _selected;

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
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _overlayEntry?.remove();
    super.dispose();
  }

  OverlayEntry _getOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context);
    final containerRenderBox =
        _globalKey.currentContext?.findRenderObject() as RenderBox?;
    final screenSize = MediaQuery.of(context).size;

    final shouldBeOnTheBottom = offset.dy >= screenSize.height - 220.0;
    final height = widget.labels.length * 33.0;

    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: offset.dy +
              (shouldBeOnTheBottom
                  ? -(height > 220.0 ? 220.0 : height) - 8.0
                  : size.height - 5.0),
          width: containerRenderBox?.size.width ?? 270.0,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 220.0),
            decoration: BoxDecoration(
              color: const Color(0xFF5D5D5D),
              borderRadius: BorderRadius.only(
                bottomLeft: shouldBeOnTheBottom
                    ? Radius.zero
                    : const Radius.circular(6.0),
                bottomRight: shouldBeOnTheBottom
                    ? Radius.zero
                    : const Radius.circular(6.0),
                topLeft: !shouldBeOnTheBottom
                    ? Radius.zero
                    : const Radius.circular(6.0),
                topRight: !shouldBeOnTheBottom
                    ? Radius.zero
                    : const Radius.circular(6.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                  offset: Offset(5, shouldBeOnTheBottom ? -15.0 : 15),
                )
              ],
            ),
            child: Container(
              margin: EdgeInsets.only(
                left: 2.0,
                right: 2.0,
                bottom: shouldBeOnTheBottom ? 0.0 : 2.0,
                top: !shouldBeOnTheBottom ? 0.0 : 2.0,
              ),
              color: const Color(0xFF242424),
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
                    children: widget.values.map((e) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(8.0),
                        hoverColor: const Color.fromARGB(146, 80, 59, 173),
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          widget.onSelected(e);
                          _focusNode.unfocus();
                          setState(() {
                            _selected = e;
                          });
                        },
                        child: Container(
                          height: 33.0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 20.0,
                          ),
                          child: Text(
                            widget.labels[e] ?? '',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.grey[400],
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusNode: _focusNode,
        onTap: () {
          _focusNode.requestFocus();
        },
        child: Container(
          key: _globalKey,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
          decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: const Color(0xFF5D5D5D),
              width: 2.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, bottom: 5.0),
                  child: Text(
                    widget.title!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  widget.labels[_selected ?? widget.initiallySelected] ?? '',
                  style: widget.smaller
                      ? theme.textTheme.bodyMedium
                      : theme.textTheme.titleMedium,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
