import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/themes.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) {
        final t = QxThemes.byId(s.themeId, s.highContrast);
        return QxScaffold(
          title: 'Themes',
          actions: const [Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: CoinChip()),
          )],
          body: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
            itemCount: QxThemes.all.length,
            itemBuilder: (context, i) {
              final th = QxThemes.all[i];
              final owned = QxThemes.owned(s, th);
              final active = s.themeId == th.id;
              return InkWell(
                onTap: !owned
                    ? () => qxToast(context,
                        'Unlock this theme in the Shop for ${th.price} coins.')
                    : () => s.setTheme(th.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: th.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: active ? th.accent : Colors.transparent,
                        width: 3),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  th.primary,
                                  th.accent,
                                  th.background
                                ]),
                          ),
                          child: Center(
                            child: Icon(
                                active
                                    ? Icons.check_circle
                                    : (owned
                                        ? Icons.palette
                                        : Icons.lock),
                                size: 40,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(th.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: th.text)),
                      Text(
                          owned
                              ? (active ? 'Active' : 'Tap to apply')
                              : '${th.price} \u{1FA99} in Shop',
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  t.text.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
