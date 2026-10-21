import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/core/sound.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        return QxScaffold(
          title: 'Settings',
          body: ListView(
            children: [
              const SectionTitle('Accessibility'),
              QxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Text size: ${(s.textScale * 100).round()}%',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Slider(
                      value: s.textScale,
                      min: 0.8,
                      max: 1.6,
                      divisions: 8,
                      label: '${(s.textScale * 100).round()}%',
                      onChanged: (v) => s.setTextScale(v),
                    ),
                    SwitchListTile(
                      title: const Text('High contrast'),
                      subtitle: const Text(
                          'Maximum contrast palette for low vision'),
                      value: s.highContrast,
                      onChanged: (_) => s.toggleHighContrast(),
                    ),
                    SwitchListTile(
                      title: const Text('Kids Mode'),
                      subtitle: const Text(
                          'Bigger targets, gentler wind, simpler play'),
                      value: s.kidsMode,
                      onChanged: (_) => s.toggleKidsMode(),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Audio'),
              QxCard(
                child: SwitchListTile(
                  title: const Text('Sound & music'),
                  value: s.soundOn,
                  onChanged: (_) async {
                    await s.toggleSound();
                    SoundService.I.enabled = s.soundOn;
                    if (s.soundOn) {
                      SoundService.I.startBgm();
                    } else {
                      SoundService.I.stopBgm();
                    }
                  },
                ),
              ),
              const SectionTitle('Data'),
              QxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QxButton(
                      label: 'Reset all progress',
                      icon: Icons.delete_forever,
                      secondary: true,
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Reset everything?'),
                            content: const Text(
                                'Coins, stats, achievements, players and streaks will be erased.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(c).pop(false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.of(c).pop(true),
                                  child: const Text('Reset')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await s.resetProgress();
                          if (context.mounted) {
                            qxToast(context, 'Progress reset.');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    'Made by QAVEX · v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: t.text.withValues(alpha: 0.6))),
              ),
            ],
          ),
        );
      },
    );
  }
}
