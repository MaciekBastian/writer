import 'package:flutter/material.dart';

class WrtExpandableSection extends StatefulWidget {
  const WrtExpandableSection({
    super.key,
    this.initiallyExpanded = false,
    this.buttonExpanded,
    this.buttonFolded,
    required this.header,
    required this.content,
    this.expandedHeader,
    this.allClickable = false,
    this.hoverEffect = false,
  });
  final bool initiallyExpanded;
  final Widget content;
  final Widget header;
  final Widget? expandedHeader;
  final Widget? buttonExpanded;
  final Widget? buttonFolded;
  final bool allClickable;
  final bool hoverEffect;

  @override
  State<WrtExpandableSection> createState() => _WrtExpandableSectionState();
}

class _WrtExpandableSectionState extends State<WrtExpandableSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: widget.allClickable && widget.hoverEffect
                ? Colors.white10
                : Colors.transparent,
            splashColor: Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
            onTap: widget.allClickable
                ? () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  }
                : null,
            child: Row(
              children: [
                if (widget.expandedHeader == null ||
                    (widget.expandedHeader != null && !_isExpanded))
                  Expanded(child: widget.header),
                if (widget.expandedHeader != null && _isExpanded)
                  Expanded(
                    child: widget.expandedHeader!,
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(6.0),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: widget.buttonExpanded != null &&
                              widget.buttonFolded != null
                          ? _isExpanded
                              ? widget.buttonExpanded
                              : widget.buttonFolded
                          : Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20.0,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) widget.content,
      ],
    );
  }
}
