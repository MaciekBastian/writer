import 'package:flutter/material.dart';

class HowToUseWriter extends StatelessWidget {
  const HowToUseWriter({super.key});

  @override
  Widget build(BuildContext context) {
    /// TODO: implement how to guide
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Text('Hello'),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(),
        ),
      ],
    );
  }
}
