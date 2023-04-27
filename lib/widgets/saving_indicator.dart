import 'dart:async';

import 'package:flutter/material.dart';

/// A blinking container
class SavingIndicator extends StatefulWidget {
  const SavingIndicator({super.key});

  @override
  State<SavingIndicator> createState() => _SavingIndicatorState();
}

class _SavingIndicatorState extends State<SavingIndicator> {
  bool _isWhite = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      setState(() {
        _isWhite = !_isWhite;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 12.0,
        height: 12.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isWhite ? Colors.white : Colors.yellow,
        ),
      ),
    );
  }
}
