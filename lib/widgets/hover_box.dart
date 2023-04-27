import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_state.dart';

class HoverBox extends StatefulWidget {
  const HoverBox({
    super.key,
    required this.child,
    required this.content,
    this.onMouseEvent,
    this.showOnTheBottom = false,
    this.showOnTheLeft = false,
    this.size = const Size(500.0, 150.0),
    this.waitTime = const Duration(milliseconds: 500),
    this.autoDecideIfBottom = false,
    this.autoDecideIfLeft = false,
  });
  final Widget child;
  final Widget content;
  final bool showOnTheBottom;
  final bool showOnTheLeft;
  final Size size;
  final void Function(bool hovering)? onMouseEvent;
  final Duration waitTime;
  final bool autoDecideIfBottom;
  final bool autoDecideIfLeft;

  @override
  State<HoverBox> createState() => _HoverBoxState();
}

class _HoverBoxState extends State<HoverBox> {
  OverlayEntry? _overlayEntry;
  bool _hovering = false;
  Timer? _timer;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _removeOverlay() {
    if (!_hovering) {
      _timer?.cancel();
      setState(() {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);

    return MouseRegion(
      onEnter: (event) {
        if (provider.tooltips) {
          if (_hovering || _overlayEntry != null) {
            return;
          }
          _timer?.cancel();
          _timer = Timer(widget.waitTime, () {
            setState(() {
              _overlayEntry = _createOverlayEntry();
              _hovering = true;
            });
            Overlay.of(context).insert(_overlayEntry!);
          });
        }
      },
      onExit: (event) {
        _timer?.cancel();
        if (provider.tooltips) {
          setState(() {
            _hovering = false;
          });
          Future.delayed(const Duration(milliseconds: 100), () {
            _removeOverlay();
          });
        }
      },
      child: widget.child,
    );
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    final shouldBeOnTheBottom = offset.dy <= widget.size.height;
    final shouldBeOnTheLeft = offset.dx >= screenSize.width - widget.size.width;

    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        left: widget.showOnTheLeft
            ? (offset.dx - widget.size.width)
            : widget.autoDecideIfLeft
                ? shouldBeOnTheLeft
                    ? (offset.dx - widget.size.width)
                    : offset.dx
                : offset.dx,
        top: offset.dy +
            ((widget.autoDecideIfBottom
                    ? shouldBeOnTheBottom
                    : widget.showOnTheBottom)
                ? (widget.autoDecideIfBottom
                    ? widget.showOnTheBottom
                        ? size.height
                        : 0
                    : size.height)
                : -widget.size.height),
        height: widget.size.height,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _hovering = false;
            });
            _removeOverlay();
          },
          child: MouseRegion(
            onEnter: (event) {
              setState(() {
                _hovering = true;
              });
            },
            onExit: (event) {
              setState(() {
                _hovering = false;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                _removeOverlay();
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                width: widget.size.width,
                height: widget.size.height,
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
                child: widget.content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
