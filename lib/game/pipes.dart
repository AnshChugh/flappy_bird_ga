import 'package:flutter/material.dart';

class PipeWidget extends StatelessWidget {
  final double pipeWidth; // Width of the pipe
  final double pipeHeight; // Height of the pipe
  final bool isTopPipe; // Whether this is the top or bottom pipe

  const PipeWidget({
    super.key,
    required this.pipeWidth,
    required this.pipeHeight,
    required this.isTopPipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pipeWidth *
          MediaQuery.of(context).size.width, // Width relative to screen size
      height: pipeHeight *
          MediaQuery.of(context).size.height, // Height relative to screen size
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(color: Colors.green[900]!, width: 3), // Pipe border
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class PipePair extends StatelessWidget {
  final double pipeX; // Horizontal position of the pipes
  final double pipeWidth;
  final double
      gapY; // Gap position (between top and bottom pipes), between 0.0 and 1.0
  final double gapWidth; // Gap width between pipes (relative to screen size)

  const PipePair({
    super.key,
    required this.pipeX,
    required this.pipeWidth,
    required this.gapY,
    required this.gapWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure that gapY is within bounds (0.0 to 1.0)
    final clampedGapY = gapY.clamp(0.0, 1.0);

    // Calculate the heights dynamically so that the pipes fit within the screen
    const totalPipeHeight = 1.0; // Total screen height is 1.0
    final topPipeHeight = clampedGapY * totalPipeHeight; // Top pipe height
    final bottomPipeHeight =
        totalPipeHeight - clampedGapY - gapWidth; // Bottom pipe height

    // Prevent bottom pipe from having a negative height
    final finalBottomPipeHeight = bottomPipeHeight > 0 ? bottomPipeHeight : 0.0;

    return Stack(
      children: [
        // Top pipe
        Align(
          alignment: Alignment(pipeX, -1), // Position top pipe
          child: PipeWidget(
            pipeWidth: pipeWidth,
            pipeHeight: topPipeHeight,
            isTopPipe: true,
          ),
        ),

        // Bottom pipe
        Align(
          alignment: Alignment(pipeX, 1), // Position bottom pipe
          child: PipeWidget(
            pipeWidth: pipeWidth,
            pipeHeight: finalBottomPipeHeight,
            isTopPipe: false,
          ),
        ),
      ],
    );
  }
}
