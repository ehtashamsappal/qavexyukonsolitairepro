import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';
import 'package:qavexyukonsolitairepro/screens/game.dart';

class GameModeDef {
  final String id;
  final String name;
  final String desc;
  final String iconKey;
  const GameModeDef(
      {required this.id,
      required this.name,
      required this.desc,
      required this.iconKey});
}

const List<GameModeDef> kModes = <GameModeDef>[
  GameModeDef(id: 'classic', name: 'Classic', desc: 'The pure game, no timer.', iconKey: 'star'),
  GameModeDef(id: 'timed', name: 'Timed Run', desc: 'Beat the clock for bonus points.', iconKey: 'timer'),
  GameModeDef(id: 'daily', name: 'Daily Challenge', desc: 'One seeded deal per day. Streaks pay bonus.', iconKey: 'calendar'),
  GameModeDef(id: 'zen', name: 'Zen Table', desc: 'No timer, no pressure. Free hints and undo.', iconKey: 'wind'),
  GameModeDef(id: 'kids', name: 'Kids Mode', desc: 'Gentle guidance and extra help.', iconKey: 'group'),
  GameModeDef(id: 'practice', name: 'Practice', desc: 'Learn with auto-hints.', iconKey: 'school'),
  GameModeDef(id: 'puzzle', name: 'Puzzle Levels', desc: '24 curated deals with par scores.', iconKey: 'target'),
];

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        return QxScaffold(
          title: 'Game Modes',
          body: ListView.builder(
            itemCount: kModes.length,
            itemBuilder: (context, i) {
              final m = kModes[i];
              final best = s.modeBest[m.id];
              return QxCard(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => GameScreen(mode: m))),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(qxModeIcon(m.iconKey),
                          color: t.primary, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(m.desc,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: t.text
                                      .withValues(alpha: 0.7))),
                          if (best != null && best > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Best: $best',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: t.accent,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: t.accent),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
