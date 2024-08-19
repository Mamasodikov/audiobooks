import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CardRow extends StatelessWidget {
  final VoidCallback onCard1Tap;
  final VoidCallback onCard2Tap;

  // Constructor to accept callbacks
  CardRow({
    required this.onCard1Tap,
    required this.onCard2Tap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // First Card

        Expanded(
          child: ZoomTapAnimation(
            onTap: onCard1Tap,
            child: Card(
              color: Colors.red, // Card color
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white), // Icon
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Playlist', // Text
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10), // Spacing between cards
        // Second Card
        Expanded(
          child: ZoomTapAnimation(
            onTap: onCard2Tap,
            child: Card(
              color: Colors.blue, // Card color
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.white), // Icon
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'About', // Text
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
