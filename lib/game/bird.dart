import 'package:flutter/material.dart';

// Bird Widget
class Bird extends StatelessWidget {
  final double boxWidth;
  const Bird({super.key, required this.boxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * boxWidth,
      height: MediaQuery.of(context).size.width * boxWidth,
      decoration: const BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
      ),
    );
  }
}
