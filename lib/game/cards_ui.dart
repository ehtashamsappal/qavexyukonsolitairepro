import 'package:flutter/material.dart';

// Generated shared card widgets for Qavex Yukon Solitaire Pro.
// Palette: #6B41EA, #9E7C22, #100D19, #201B2F, #E4DEF7, #DEDAED

class QCardColors {
  static const accent = Color(0xFF6B41EA);
  static const gold = Color(0xFF9E7C22);
  static const bgDark = Color(0xFF100D19);
  static const bgMid = Color(0xFF201B2F);
  static const cardFace = Color(0xFFE4DEF7);
  static const textLight = Color(0xFFDEDAED);
  static const redSuit = Color(0xFFC0392B);
  static const blackSuit = Color(0xFF1F2A37);
}

String suitGlyph(String suit) {
  switch (suit) {
    case 'S':
      return '\u2660';
    case 'H':
      return '\u2665';
    case 'D':
      return '\u2666';
    case 'C':
      return '\u2663';
    default:
      return suit;
  }
}

bool isRedSuit(String suit) => suit == 'H' || suit == 'D';

/// A single playing card face. rank like 'A','2'..'10','J','Q','K',
/// suit one of 'S','H','D','C'.
class QCardFace extends StatelessWidget {
  final String rank;
  final String suit;
  final double width;
  final bool dimmed;
  final bool selected;

  const QCardFace({
    super.key,
    required this.rank,
    required this.suit,
    this.width = 64,
    this.dimmed = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = width * 1.42;
    final red = isRedSuit(suit);
    final ink = red ? QCardColors.redSuit : QCardColors.blackSuit;
    final fs = width * 0.24;
    return Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, QCardColors.cardFace],
        ),
        border: Border.all(
          color: selected ? QCardColors.gold : QCardColors.blackSuit.withOpacity(0.35),
          width: selected ? 3 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(selected ? 0.45 : 0.28),
            blurRadius: selected ? 14 : 6,
            offset: Offset(0, selected ? 5 : 3),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.55),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Opacity(
        opacity: dimmed ? 0.45 : 1.0,
        child: Stack(
          children: [
            Positioned(
              left: width * 0.08,
              top: h * 0.05,
              child: Column(
                children: [
                  Text(rank,
                      style: TextStyle(
                          color: ink,
                          fontSize: fs,
                          fontWeight: FontWeight.w800,
                          height: 1.0)),
                  Text(suitGlyph(suit),
                      style: TextStyle(color: ink, fontSize: fs * 0.95, height: 1.0)),
                ],
              ),
            ),
            Center(
              child: (rank == 'J' || rank == 'Q' || rank == 'K')
                  ? Container(
                      padding: EdgeInsets.all(width * 0.08),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.08),
                        border: Border.all(color: ink.withOpacity(0.5), width: 1.4),
                        gradient: LinearGradient(
                          colors: [
                            QCardColors.gold.withOpacity(0.35),
                            QCardColors.gold.withOpacity(0.08)
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(suitGlyph(suit),
                              style: TextStyle(color: ink, fontSize: width * 0.42)),
                          Text(rank,
                              style: TextStyle(
                                  color: ink,
                                  fontSize: width * 0.30,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    )
                  : Text(suitGlyph(suit),
                      style: TextStyle(color: ink, fontSize: width * 0.52)),
            ),
            Positioned(
              right: width * 0.08,
              bottom: h * 0.05,
              child: RotatedBox(
                quarterTurns: 2,
                child: Column(
                  children: [
                    Text(rank,
                        style: TextStyle(
                            color: ink,
                            fontSize: fs,
                            fontWeight: FontWeight.w800,
                            height: 1.0)),
                    Text(suitGlyph(suit),
                        style:
                            TextStyle(color: ink, fontSize: fs * 0.95, height: 1.0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card back. Uses the generated card_back.png art when bundled.
class QCardBack extends StatelessWidget {
  final double width;
  const QCardBack({super.key, this.width = 64});

  @override
  Widget build(BuildContext context) {
    final h = width * 1.42;
    return Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.12),
        border: Border.all(color: Colors.white.withOpacity(0.75), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/card_back.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [QCardColors.accent, QCardColors.bgDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text('\u2660',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: width * 0.5)),
          ),
        ),
      ),
    );
  }
}

/// Empty slot placeholder (foundation / tableau target).
class QCardSlot extends StatelessWidget {
  final double width;
  final String glyph;
  final bool highlight;
  const QCardSlot(
      {super.key, this.width = 64, this.glyph = '', this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final h = width * 1.42;
    return Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.12),
        color: Colors.black.withOpacity(0.22),
        border: Border.all(
          color: highlight
              ? QCardColors.gold
              : Colors.white.withOpacity(0.28),
          width: highlight ? 2.6 : 1.4,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                    color: QCardColors.gold.withOpacity(0.55),
                    blurRadius: 12)
              ]
            : null,
      ),
      child: glyph.isEmpty
          ? null
          : Center(
              child: Text(glyph,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: width * 0.4))),
    );
  }
}

/// Felt-table background scaffold used by every card game screen.
class QFeltScaffold extends StatelessWidget {
  final Widget child;
  final List<Widget> overlays;
  const QFeltScaffold({super.key, required this.child, this.overlays = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [QCardColors.bgDark, QCardColors.bgMid, QCardColors.bgDark],
        ),
      ),
      child: Stack(
        children: [
          // subtle vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.05,
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
              ),
            ),
          ),
          SafeArea(child: child),
          ...overlays,
        ],
      ),
    );
  }
}
