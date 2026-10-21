import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/core/sound.dart';

/// Shared UI atoms. Every interactive element is at least 48dp.
class QxScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  const QxScaffold(
      {super.key,
      required this.title,
      required this.body,
      this.actions,
      this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}

class QxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  const QxButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.secondary = false});

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22),
          const SizedBox(width: 8),
        ],
        Flexible(
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16))),
      ],
    );
    final style = ElevatedButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12));
    if (secondary) {
      return OutlinedButton(
          onPressed: onPressed == null
              ? null
              : () {
                  SoundService.I.play('click');
                  onPressed!();
                },
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 52),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12)),
          child: child);
    }
    return ElevatedButton(
        onPressed: onPressed == null
            ? null
            : () {
                SoundService.I.play('click');
                onPressed!();
              },
        style: style,
        child: child);
  }
}

class QxCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const QxCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
          padding: const EdgeInsets.all(14), child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: () {
        SoundService.I.play('click');
        onTap!();
      },
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}

class CoinChip extends StatelessWidget {
  const CoinChip({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: QxThemes.byId(s.themeId, s.highContrast)
              .surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: QxThemes.byId(s.themeId, s.highContrast).accent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1FA99}', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text('${s.coins}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            if (s.supporter) ...[
              const SizedBox(width: 6),
              const Text('\u2615',
                  style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

/// Shows a short toast-style message.
void qxToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
  );
}

IconData qxModeIcon(String key) {
  switch (key) {
    case 'target':
      return Icons.track_changes;
    case 'timer':
      return Icons.timer;
    case 'bolt':
      return Icons.bolt;
    case 'star':
      return Icons.star;
    case 'trophy':
      return Icons.emoji_events;
    case 'group':
      return Icons.group;
    case 'calendar':
      return Icons.calendar_month;
    case 'sports':
      return Icons.sports;
    case 'casino':
      return Icons.casino;
    case 'wind':
      return Icons.air;
    case 'crosshair':
      return Icons.my_location;
    default:
      return Icons.play_arrow;
  }
}
