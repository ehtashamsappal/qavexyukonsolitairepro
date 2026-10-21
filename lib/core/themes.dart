import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';

/// Visual theme: a full palette plus an unlock price in Nugget Coins.
class QxTheme {
  final String id;
  final String name;
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color field;
  final int price;

  const QxTheme({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.field,
    required this.price,
  });

  QxTheme get highContrast => QxTheme(
        id: id,
        name: '$name (HC)',
        primary: const Color(0xFFFFFF00),
        accent: const Color(0xFF00FFFF),
        background: Colors.black,
        surface: const Color(0xFF141414),
        text: Colors.white,
        field: const Color(0xFF2A2A2A),
        price: price,
      );

  ThemeData toTheme() {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.black,
      secondary: accent,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: text,
      error: const Color(0xFFFF5252),
      onError: Colors.white,
    );
    ButtonStyle btn(Color bg, Color fg) => ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: text,
          centerTitle: true),
      elevatedButtonTheme:
          ElevatedButtonThemeData(style: btn(primary, Colors.black)),
      filledButtonTheme: FilledButtonThemeData(
          style: btn(primary, Colors.black)),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              minimumSize: const Size(48, 48), foregroundColor: accent)),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: text,
              side: BorderSide(color: accent))),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
      sliderTheme: SliderThemeData(
          activeTrackColor: accent, thumbColor: primary),
      switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(primary),
          trackColor: WidgetStateProperty.all(accent.withValues(alpha: 0.4))),
      cardTheme: CardThemeData(
          color: surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16))),
      dialogTheme: DialogThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20))),
      textTheme: Typography.whiteMountainView.apply(
          bodyColor: text, displayColor: text),
      snackBarTheme: SnackBarThemeData(
          backgroundColor: surface,
          contentTextStyle: TextStyle(color: text)),
    );
  }
}

class QxThemes {
  static const List<QxTheme> all = <QxTheme>[
    QxTheme(id: 'signature', name: 'Gold Rush Camp', primary: Color(0xFF6B41EA), accent: Color(0xFF9E7C22), background: Color(0xFF100D19), surface: Color(0xFF201B2F), text: Color(0xFFDEDAED), field: Color(0xFF201B2F), price: 0),
    QxTheme(id: 'midnight', name: 'Midnight Felt', primary: Color(0xFF7C9EFF), accent: Color(0xFF9E7C22), background: Color(0xFF0A0F1E), surface: Color(0xFF141B2E), text: Color(0xFFF2F5FF), field: Color(0xFF1C2740), price: 150),
    QxTheme(id: 'royal', name: 'Royal Velvet', primary: Color(0xFFD4AF37), accent: Color(0xFF9D4EDD), background: Color(0xFF1E0F2E), surface: Color(0xFF2A1545), text: Color(0xFFFFF6E0), field: Color(0xFF3A1F5C), price: 200),
    QxTheme(id: 'ocean', name: 'Ocean Table', primary: Color(0xFF4CC9F0), accent: Color(0xFFFFD166), background: Color(0xFF08222E), surface: Color(0xFF0C3140), text: Color(0xFFEFFBFF), field: Color(0xFF134052), price: 150),
    QxTheme(id: 'sunset', name: 'Sunset Club', primary: Color(0xFFFF8C42), accent: Color(0xFFFFD166), background: Color(0xFF2B1408), surface: Color(0xFF3D2010), text: Color(0xFFFFF3E6), field: Color(0xFF4E2C14), price: 200),
    QxTheme(id: 'sakura', name: 'Sakura Night', primary: Color(0xFFFF8FAB), accent: Color(0xFFFFD166), background: Color(0xFF2A0F1C), surface: Color(0xFF3A1626), text: Color(0xFFFFF0F4), field: Color(0xFF4C1F31), price: 250),
    QxTheme(id: 'forest', name: 'Deep Forest', primary: Color(0xFF95D5B2), accent: Color(0xFFFFD166), background: Color(0xFF08140F), surface: Color(0xFF0F241A), text: Color(0xFFF0FFF4), field: Color(0xFF1A3A28), price: 200),
    QxTheme(id: 'ivory', name: 'Ivory & Ink', primary: Color(0xFF1F2A37), accent: Color(0xFFC0392B), background: Color(0xFFF5F1E6), surface: Color(0xFFFFFFFF), text: Color(0xFF1F2A37), field: Color(0xFFE8E0CF), price: 250),
  ];

  static QxTheme byId(String id, bool hc) {
    final t = all.firstWhere((t) => t.id == id, orElse: () => all.first);
    return hc ? t.highContrast : t;
  }

  static bool owned(AppState s, QxTheme t) =>
      t.price == 0 || s.supporter || s.themesOwned.contains(t.id);
}
