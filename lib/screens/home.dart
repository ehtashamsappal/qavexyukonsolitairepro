import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';
import 'package:qavexyukonsolitairepro/screens/mode_select.dart';
import 'package:qavexyukonsolitairepro/screens/shop.dart';
import 'package:qavexyukonsolitairepro/screens/settings.dart';
import 'package:qavexyukonsolitairepro/screens/themes_screen.dart';
import 'package:qavexyukonsolitairepro/screens/players.dart';
import 'package:qavexyukonsolitairepro/screens/stats.dart';
import 'package:qavexyukonsolitairepro/screens/howto.dart';
import 'package:qavexyukonsolitairepro/screens/about.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        final items = <_MenuItem>[
          _MenuItem('Play Now', Icons.play_arrow, t.primary,
              () => _go(context, const ModeSelectScreen())),
          _MenuItem('Shop', Icons.shopping_bag, t.accent,
              () => _go(context, const ShopScreen())),
          _MenuItem('Themes', Icons.palette, t.accent,
              () => _go(context, const ThemesScreen())),
          _MenuItem('Players', Icons.group, t.accent,
              () => _go(context, const PlayersScreen())),
          _MenuItem('Stats & Awards', Icons.emoji_events, t.accent,
              () => _go(context, const StatsScreen())),
          _MenuItem('How to Play', Icons.help_outline, t.accent,
              () => _go(context, const HowToScreen())),
          _MenuItem('Settings', Icons.settings, t.accent,
              () => _go(context, const SettingsScreen())),
          _MenuItem('About', Icons.info_outline, t.accent,
              () => _go(context, const AboutScreen())),
        ];
        return QxScaffold(
          title: 'Yukon Pro',
          actions: const [Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: CoinChip()),
          )],
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qavex Yukon Solitaire Pro',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: t.text)),
                    const SizedBox(height: 4),
                    Text('No stock, no mercy: the gold-rush solitaire.',
                        style: TextStyle(
                            fontSize: 15, color: t.accent)),
                    if (s.streak > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: t.surface,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(
                            '\u{1F525}  Day ${s.streak} streak — keep it going!',
                            style: TextStyle(
                                color: t.text,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final m = items[i];
                  return Semantics(
                    button: true,
                    label: m.label,
                    child: InkWell(
                      onTap: m.onTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        constraints:
                            const BoxConstraints(minHeight: 48),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: m.color.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(m.icon, size: 34, color: m.color),
                            const SizedBox(height: 8),
                            Text(m.label,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: t.text)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (s.kidsMode)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                        '\u{1F9D2} Kids Mode is ON — bigger targets, no tricky wind.',
                        style: TextStyle(color: t.text)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _MenuItem(this.label, this.icon, this.color, this.onTap);
}
