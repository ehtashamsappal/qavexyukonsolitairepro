import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/achievements.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        final acc = s.totalShots == 0
            ? 0
            : (s.totalMakes * 100 / s.totalShots).round();
        final statTiles = <List<String>>[
          ['Games played', '${s.gamesPlayed}'],
          ['Total shots', '${s.totalShots}'],
          ['Total makes', '${s.totalMakes}'],
          ['Accuracy', '$acc%'],
          ['Wins', '${s.totalWins}'],
          ['Best score', '${s.bestScore}'],
          ['Coins earned', '${s.coinsEarned}'],
          ['Day streak', '${s.streak}'],
        ];
        return QxScaffold(
          title: 'Stats & Awards',
          body: ListView(
            children: [
              const SectionTitle('Career stats'),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8),
                itemCount: statTiles.length,
                itemBuilder: (context, i) => Container(
                  decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(statTiles[i][1],
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: t.primary)),
                      Text(statTiles[i][0],
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              SectionTitle(
                  'Achievements (${s.unlocked.length}/${kAchievements.length})'),
              for (final a in kAchievements)
                QxCard(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: s.unlocked.contains(a.id)
                              ? t.primary.withValues(alpha: 0.2)
                              : t.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: s.unlocked.contains(a.id)
                                  ? t.primary
                                  : t.text.withValues(alpha: 0.2)),
                        ),
                        child: Icon(
                            s.unlocked.contains(a.id)
                                ? Icons.emoji_events
                                : Icons.lock_outline,
                            color: s.unlocked.contains(a.id)
                                ? t.primary
                                : t.text.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(a.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(a.desc,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ((s.counters[a.trigger] ?? 0) /
                                        a.goal)
                                    .clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: t.text
                                    .withValues(alpha: 0.15),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        t.accent),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('+${a.coins}',
                          style: TextStyle(
                              color: t.accent,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
