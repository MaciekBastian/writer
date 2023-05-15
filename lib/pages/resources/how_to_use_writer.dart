import 'package:flutter/material.dart';

class HowToUseWriter extends StatelessWidget {
  static const pageName = '/about';
  const HowToUseWriter({super.key});

  @override
  Widget build(BuildContext context) {
    /// TODO: implement how to guide
    return const Row(
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
