import 'package:flappy_bird_ga/utils/helper_functions.dart';
import 'package:flappy_bird_ga/utils/pipe_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'game/bird.dart';
import 'game/pipes.dart';

void main() {
  runApp(const MyApp());
}

// global variables
const double birdWidth = 0.05; // relative to pixels
const double collisionBox = birdWidth * 0.55; // 10% outside collision
const pipeWidth = 0.1;

// [pipeX, gapWidth,gapY]
List<List<double>> pipePositions = [
  [0.80, 0.3, 0.4],
  [1, 0.3, 0.2]
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FlappyBirdGame(),
    );
  }
}

class FlappyBirdGame extends StatefulWidget {
  const FlappyBirdGame({super.key});

  @override
  _FlappyBirdGameState createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double birdY = 0; // Vertical position
  double velocity = 0; // Vertical velocity
  double gravity = 0.002; // Gravity effect
  double jump = -0.04; // Flap strength
  final int targetFPS = 125; // Target refresh rate???
  final Duration frameInterval = const Duration(
      milliseconds: 24); // ~60 FPS (1000ms/16)/ Tracks elapsed time

  late FocusNode _focusNode;

  bool isGameRunning = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.requestFocus();
    _ticker = Ticker(_onTick)..start();
  }

  Duration lastElapsed = Duration.zero; // Track the previous elapsed time
  Duration accumulatedTime = Duration.zero;

  void _onTick(Duration elapsed) {
    final deltaTime = elapsed - lastElapsed; // Calculate time since last tick
    lastElapsed = elapsed; // Update the last elapsed time

    accumulatedTime += deltaTime;

    // Update only if enough time has passed
    while (accumulatedTime >= frameInterval && isGameRunning) {
      _updateBird();

      _updatePipes();
      accumulatedTime -= frameInterval;
    }

    // Prevent accumulated time overflow
    if (accumulatedTime > frameInterval * 10) {
      accumulatedTime = Duration.zero; // Reset to avoid infinite loops
    }
  }

  void _updateBird() {
    setState(() {
      velocity += gravity; // Apply gravity
      birdY += velocity; // Update bird position

      // Constrain bird position and reset velocity if out of bounds
      if (birdY > 1) {
        birdY = 1;
        velocity = 0;

        isGameRunning = false; // Stop ticker when the bird hits the ground
      } else if (birdY < -1) {
        birdY = -1;
        velocity = 0;
        isGameRunning = false;
      }
    });
  }

  bool detectCollision(List<double> pipe) {
    // Extract pipe properties (normalized coordinates from 0 to 1)
    double _pipeX = scaleToPositive(pipe[0]);
    double _birdY = scaleToPositive(birdY);
    double _birdX = 0.5; // Bird is always in the center on the X-axis
    double gapWidth = pipe[1];
    double gapY = pipe[2];

    // Calculate the safe height range (gap boundaries in normalized coordinates)
    double safeTopHeight = gapY; // The top of the gap (where the top pipe ends)
    double safeBottomHeight = (gapY + gapWidth < 1) ? gapY + gapWidth : 1;

    // Calculate pipe's left and right boundaries
    double leftBoundary = _pipeX - pipeWidth / 2;
    double rightBoundary = _pipeX + pipeWidth / 2;

    // Check for vertical collision: Bird should not be within the pipes' area
    bool canTouchVertically = !(_birdY - collisionBox > safeTopHeight &&
        _birdY + collisionBox < safeBottomHeight);

    // Check for horizontal collision: Bird's X position should overlap with the pipe's range
    bool canTouchHorizontally = _birdX + collisionBox > leftBoundary &&
        _birdX - collisionBox < rightBoundary;

    // Return true if both horizontal and vertical collisions happen
    return canTouchHorizontally && canTouchVertically;
  }

  // Horizontal positions of pipes
  double pipeVelocity = 0.02; // Speed of the pipes
  void _updatePipes() {
    setState(() {
      for (int i = 0; i < pipePositions.length; i++) {
        pipePositions[i][0] -= pipeVelocity; // Move pipe to the left
        if (detectCollision(pipePositions[i])) {
          isGameRunning = false;
        }
      }
      // If pipe moves off-screen, reset its position
      if (pipePositions[0][0] < -1 - pipeWidth) {
        pipePositions.removeAt(0);
        pipePositions.add(generatePipe()); // Reposition off-screen to the right
      }
    });
  }

  // handle space bar input to jump or reset game
  void _onKeyInput(event) {
    if (event.logicalKey == LogicalKeyboardKey.space && event is KeyDownEvent) {
      if (isGameRunning) {
        setState(() {
          velocity = jump;
        });
      } else {
        // game ended
        print("game reset: ");
        setState(() {
          birdY = 0;
          velocity = 0;
          isGameRunning = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _onKeyInput,
        child: Stack(
          children: [
            // Background
            Container(color: Colors.blue),
            for (List<double> pipe in pipePositions)
              PipePair(
                pipeX: pipe[0],
                pipeWidth: pipeWidth,
                gapWidth: pipe[1],
                gapY: pipe[2],
              ),
            // Bird
            Align(
              alignment: Alignment(0, birdY), // Initial position (centered)
              child: const Bird(
                boxWidth: birdWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
