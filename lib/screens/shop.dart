import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/core/iap_service.dart';
import 'package:qavexyukonsolitairepro/core/sound.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final CoffeeIap _iap = CoffeeIap();
  bool _iapReady = false;

  @override
  void initState() {
    super.initState();
    _iap.init().then((_) {
      if (mounted) setState(() => _iapReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        final locked =
            QxThemes.all.where((th) => !QxThemes.owned(s, th)).toList();
        return QxScaffold(
          title: 'Shop',
          actions: const [Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: CoinChip()),
          )],
          body: ListView(
            children: [
              const SectionTitle('Support the developer'),
              QxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('\u2615',
                            style: TextStyle(
                                fontSize: 34, color: t.primary)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Buy Me a Coffee',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(
                                  'One-time \$0.99. Unlocks the Supporter badge and every theme. No gameplay advantage.',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (s.supporter)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: t.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text(
                            '\u2615  You are a Supporter — thank you!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
                      )
                    else
                      QxButton(
                        label: _iapReady &&
                                _iap.product != null
                            ? 'Buy — ${_iap.product!.price}'
                            : 'Buy — ${CoffeeIap.priceLabel}',
                        icon: Icons.coffee,
                        onPressed: () async {
                          final ok = await _iap.buy();
                          if (!context.mounted) return;
                          if (ok) {
                            await s.setSupporter();
                            if (!context.mounted) return;
                            SoundService.I.play('win');
                            qxToast(context,
                                'Thank you for supporting QAVEX!');
                          } else {
                            qxToast(context,
                                _iap.error ?? 'Purchase not completed.');
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SectionTitle('Theme packs (spend Nugget Coins)'),
              if (locked.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                      'All themes unlocked! New packs arrive with updates.'),
                ),
              for (final th in locked)
                QxCard(
                  child: Row(
                    children: [
                      Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Color(0xFF000000 | 0xFFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                th.primary,
                                th.accent
                              ]))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(th.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))),
                      QxButton(
                        label: '${th.price} \u{1FA99}',
                        onPressed: s.coins >= th.price
                            ? () async {
                                final ok = await s.buyTheme(
                                    th.id, th.price);
                                if (!context.mounted) return;
                                qxToast(context,
                                    ok ? 'Theme unlocked!' : 'Not enough coins.');
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'Earn Nugget Coins just by playing — every shot, win and daily streak pays out. No ads, no pay-to-win.',
                    style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }
}
