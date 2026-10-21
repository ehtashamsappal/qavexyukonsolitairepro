import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) => QxScaffold(
        title: 'How to Play',
        body: ListView(
          children: const [
            QxCard(
              child: Text('HOW TO PLAY\n\nGoal: move all 52 cards to the four foundations, each suit Ace to King.\n\n- Yukon is Klondike with NO stock: every card is in the seven columns from the first deal.\n- Build columns downward in alternating colors (red 6 on black 7).\n- Any face-up stack may move as one, even if it mixes suits, as long as the bottom card lands legally.\n- Only a King (or a stack led by a King) may fill an empty column.\n- Tap a card to select it, then tap a glowing target. Double-tap to send a card home.\n\nMODES\n- Classic: the pure dig, no timer.\n- Timed Run: 10 minutes; leftover time becomes bonus points.\n- Daily Challenge: one seeded claim per day; streaks earn bonus Nugget Coins.\n- Zen Table: no timer, free hints and undo.\n- Puzzle Levels: 24 curated claims with par scores; clear one to unlock the next.\n- Kids Mode: extra hints and friendly guidance.\n- Practice: free play with auto-hints.',
                  style: TextStyle(fontSize: 15, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
