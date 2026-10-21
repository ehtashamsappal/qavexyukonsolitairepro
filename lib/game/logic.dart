/// Pure-Dart solitaire build engine (Klondike / Spider / FreeCell / Yukon /
/// Scorpion / Forty Thieves / Canfield). No Flutter imports: unit-testable.

class SolCard {
  final int suit; // 0=S 1=H 2=D 3=C
  final int rank; // 1..13
  bool faceUp;
  SolCard(this.suit, this.rank, {this.faceUp = false});
  SolCard.clone(SolCard o)
      : suit = o.suit,
        rank = o.rank,
        faceUp = o.faceUp;
  static const ranks = [
    'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
  ];
  static const suits = ['S', 'H', 'D', 'C'];
  String get rankLabel => ranks[rank - 1];
  String get suitChar => suits[suit];
  bool get isRed => suit == 1 || suit == 2;
  int get color => isRed ? 1 : 0;
}

class SolConfig {
  final int piles;
  final String buildRule; // 'alt' | 'suit' | 'any'
  final String stockMode; // 'draw1' | 'draw3' | 'dealrow' | 'deal3' | 'none'
  final int redeals; // -1 = unlimited
  final int decks;
  final int foundations;
  final int reserves; // freecells
  final int reservePile; // canfield-style stock pile of N cards
  final List<int> downPerPile;
  final List<int> upPerPile;
  final bool seqRemove; // spider: remove complete K..A same-suit runs
  final int suitsUsed; // 4 normal; 1/2 for spider variants
  final bool seqNeedsSuit; // multi-card moves need same-suit runs
  final String foundationBase; // 'A' | 'deal1'
  const SolConfig({
    required this.piles,
    required this.buildRule,
    required this.stockMode,
    required this.redeals,
    required this.decks,
    required this.foundations,
    this.reserves = 0,
    this.reservePile = 0,
    required this.downPerPile,
    required this.upPerPile,
    this.seqRemove = false,
    this.suitsUsed = 4,
    this.seqNeedsSuit = false,
    this.foundationBase = 'A',
  });
}

class _Snap {
  final List<List<SolCard>> tableau;
  final List<List<SolCard>> foundation;
  final List<SolCard> stock;
  final List<SolCard> waste;
  final List<SolCard?> reserve;
  final List<SolCard> reservePile;
  final int score, moves, redealsLeft, seqRemoved;
  _Snap(this.tableau, this.foundation, this.stock, this.waste, this.reserve,
      this.reservePile, this.score, this.moves, this.redealsLeft, this.seqRemoved);
}

List<SolCard> _clonePile(List<SolCard> p) => p.map(SolCard.clone).toList();

class SolitaireEngine {
  final SolConfig cfg;
  late List<List<SolCard>> tableau;
  late List<List<SolCard>> foundation;
  late List<SolCard> stock;
  late List<SolCard> waste;
  late List<SolCard?> reserve;
  late List<SolCard> reservePile;
  late int redealsLeft;
  int score = 0;
  int moves = 0;
  int seqRemoved = 0;
  int _foundationBaseRank = 1;
  bool won = false;
  final List<_Snap> _undo = [];

  SolitaireEngine(this.cfg) {
    newGame();
  }

  void newGame({int? seed}) {
    final rng = seed == null ? null : _SeededRandom(seed);
    final deck = <SolCard>[];
    final setsPerSuit = (cfg.decks * 4) ~/ cfg.suitsUsed;
    for (int rep = 0; rep < setsPerSuit; rep++) {
      for (int s = 0; s < 4; s++) {
        if (cfg.suitsUsed == 1 && s != 0) continue;
        if (cfg.suitsUsed == 2 && s != 0 && s != 1) continue;
        for (int r = 1; r <= 13; r++) {
          deck.add(SolCard(s, r));
        }
      }
    }
    if (rng == null) {
      deck.shuffle();
    } else {
      rng.shuffle(deck);
    }
    tableau = List.generate(cfg.piles, (_) => <SolCard>[]);
    for (int i = 0; i < cfg.piles; i++) {
      for (int k = 0; k < cfg.downPerPile[i]; k++) {
        tableau[i].add(deck.removeLast()..faceUp = false);
      }
      for (int k = 0; k < cfg.upPerPile[i]; k++) {
        tableau[i].add(deck.removeLast()..faceUp = true);
      }
    }
    foundation = List.generate(cfg.foundations, (_) => <SolCard>[]);
    _foundationBaseRank = 1;
    if (cfg.foundationBase == 'deal1' && deck.isNotEmpty) {
      final base = deck.removeLast()..faceUp = true;
      foundation[0].add(base);
      _foundationBaseRank = base.rank;
    }
    reservePile = <SolCard>[];
    for (int k = 0; k < cfg.reservePile && deck.isNotEmpty; k++) {
      reservePile.add(deck.removeLast()..faceUp = false);
    }
    if (reservePile.isNotEmpty) reservePile.last.faceUp = true;
    stock = deck;
    waste = <SolCard>[];
    reserve = List<SolCard?>.filled(cfg.reserves, null);
    redealsLeft = cfg.redeals;
    score = 0;
    moves = 0;
    seqRemoved = 0;
    won = false;
    _undo.clear();
  }

  // ---------- helpers ----------

  bool _orderedPair(SolCard lower, SolCard upper) {
    if (upper.rank != lower.rank - 1) return false;
    switch (cfg.buildRule) {
      case 'alt':
        return upper.color != lower.color;
      case 'suit':
        return upper.suit == lower.suit;
      default:
        return true;
    }
  }

  bool _canStackOn(SolCard moving, SolCard target) =>
      _orderedPair(target, moving);

  /// Cards [start..end] of [pile] form a movable run.
  bool isMovableRun(List<SolCard> pile, int start) {
    if (start < 0 || start >= pile.length) return false;
    for (int i = start; i < pile.length; i++) {
      if (!pile[i].faceUp) return false;
      if (i > start) {
        if (cfg.seqNeedsSuit) {
          if (pile[i].suit != pile[i - 1].suit ||
              pile[i].rank != pile[i - 1].rank - 1) return false;
        } else if (!_orderedPair(pile[i - 1], pile[i])) {
          return false;
        }
      }
    }
    return true;
  }

  bool _canFoundation(SolCard c) {
    for (int f = 0; f < foundation.length; f++) {
      if (_canFoundationAt(c, f)) return true;
    }
    return false;
  }

  bool _canFoundationAt(SolCard c, int f) {
    final pile = foundation[f];
    if (cfg.foundationBase == 'deal1') {
      if (pile.isEmpty) return false;
      final top = pile.last;
      final want = top.rank == 13 ? 1 : top.rank + 1;
      return c.suit == top.suit && c.rank == want;
    }
    if (cfg.seqRemove) return false; // spider uses sequence removal
    if (pile.isEmpty) return c.rank == 1;
    final top = pile.last;
    return c.suit == top.suit && c.rank == top.rank + 1;
  }

  void _pushUndo() {
    _undo.add(_Snap(
      tableau.map(_clonePile).toList(),
      foundation.map(_clonePile).toList(),
      _clonePile(stock),
      _clonePile(waste),
      reserve.map((c) => c == null ? null : SolCard.clone(c)).toList(),
      _clonePile(reservePile),
      score, moves, redealsLeft, seqRemoved,
    ));
    if (_undo.length > 200) _undo.removeAt(0);
  }

  bool get canUndo => _undo.isNotEmpty;

  void undo() {
    if (_undo.isEmpty) return;
    final s = _undo.removeLast();
    tableau = s.tableau;
    foundation = s.foundation;
    stock = s.stock;
    waste = s.waste;
    reserve = s.reserve;
    reservePile = s.reservePile;
    score = s.score;
    moves = s.moves;
    redealsLeft = s.redealsLeft;
    seqRemoved = s.seqRemoved;
    won = false;
  }

  void _flipTop(List<SolCard> pile) {
    if (pile.isNotEmpty && !pile.last.faceUp) {
      pile.last.faceUp = true;
      score += 5;
    }
  }

  void _checkSeqRemove() {
    if (!cfg.seqRemove) return;
    for (int pi = 0; pi < tableau.length; pi++) {
      final pile = tableau[pi];
      while (pile.length >= 13) {
      final n = pile.length;
      bool ok = true;
      final suit = pile[n - 1].suit;
      for (int i = 0; i < 13; i++) {
        final c = pile[n - 1 - i];
        if (!c.faceUp || c.suit != suit || c.rank != i + 1) {
          ok = false;
          break;
        }
      }
      if (!ok) break;
      _pushUndo();
      final removed = pile.sublist(n - 13);
      pile.removeRange(n - 13, n);
      int f = seqRemoved % foundation.length;
      foundation[f].addAll(removed);
      seqRemoved++;
      score += 100;
      moves++;
        _flipTop(pile);
        _updateWon();
      }
    }
  }

  void _updateWon() {
    if (cfg.seqRemove) {
      won = seqRemoved >= cfg.decks * 4;
    } else {
      int total = 0;
      for (final f in foundation) {
        total += f.length;
      }
      won = total == cfg.foundations * 13;
    }
  }

  // ---------- moves ----------

  bool drawFromStock() {
    if (cfg.stockMode == 'none') return false;
    if (stock.isEmpty) {
      if (waste.isEmpty || cfg.redeals == 0 || redealsLeft == 0) return false;
      _pushUndo();
      while (waste.isNotEmpty) {
        stock.add(waste.removeLast()..faceUp = false);
      }
      if (redealsLeft > 0) redealsLeft--;
      score = (score - 20).clamp(0, 1 << 30).toInt();
      moves++;
      return true;
    }
    if (cfg.stockMode == 'dealrow') {
      if (tableau.any((p) => p.isEmpty)) return false;
      _pushUndo();
      for (final p in tableau) {
        p.add(stock.removeLast()..faceUp = true);
      }
      moves++;
      _checkSeqRemove();
      _updateWon();
      return true;
    }
    if (cfg.stockMode == 'deal3') {
      _pushUndo();
      for (int i = 0; i < 3 && i < tableau.length && stock.isNotEmpty; i++) {
        tableau[i].add(stock.removeLast()..faceUp = true);
      }
      moves++;
      return true;
    }
    _pushUndo();
    final n = cfg.stockMode == 'draw3' ? 3 : 1;
    for (int i = 0; i < n && stock.isNotEmpty; i++) {
      waste.add(stock.removeLast()..faceUp = true);
    }
    moves++;
    return true;
  }

  bool _takeTop(List<SolCard> pile) {
    if (pile.isEmpty || !pile.last.faceUp) return false;
    return true;
  }

  bool moveWasteToTableau(int t) {
    if (waste.isEmpty) return false;
    final c = waste.last;
    final pile = tableau[t];
    if (pile.isEmpty) {
      if (c.rank != 13) return false;
    } else if (!_canStackOn(c, pile.last)) {
      return false;
    }
    _pushUndo();
    waste.removeLast();
    pile.add(c);
    moves++;
    score += 5;
    _checkSeqRemove();
    _updateWon();
    return true;
  }

  bool moveWasteToFoundation() {
    if (waste.isEmpty || !_canFoundation(waste.last)) return false;
    _pushUndo();
    final c = waste.removeLast();
    for (int f = 0; f < foundation.length; f++) {
      if (_canFoundationAt(c, f)) {
        foundation[f].add(c);
        break;
      }
    }
    moves++;
    score += 10;
    _updateWon();
    return true;
  }

  bool moveTableauToFoundation(int pileIdx) {
    final pile = tableau[pileIdx];
    if (!_takeTop(pile)) return false;
    final c = pile.last;
    if (!_canFoundation(c)) return false;
    _pushUndo();
    pile.removeLast();
    for (int f = 0; f < foundation.length; f++) {
      if (_canFoundationAt(c, f)) {
        foundation[f].add(c);
        break;
      }
    }
    moves++;
    score += 10;
    _flipTop(pile);
    _updateWon();
    return true;
  }

  bool moveTableauToTableau(int from, int start, int to) {
    if (from == to) return false;
    final src = tableau[from];
    final dst = tableau[to];
    if (!isMovableRun(src, start)) return false;
    final moving = src[start];
    if (dst.isEmpty) {
      if (moving.rank != 13) return false;
    } else if (!_canStackOn(moving, dst.last)) {
      return false;
    }
    _pushUndo();
    final run = src.sublist(start);
    src.removeRange(start, src.length);
    dst.addAll(run);
    moves++;
    score += 5;
    _flipTop(src);
    _checkSeqRemove();
    _updateWon();
    return true;
  }

  bool moveTableauToReserve(int pileIdx) {
    final pile = tableau[pileIdx];
    if (!_takeTop(pile)) return false;
    final slot = reserve.indexWhere((c) => c == null);
    if (slot < 0) return false;
    if (pile.length != 1 && pile.length > 1) {
      // only single top cards may go to a freecell
    }
    _pushUndo();
    // freecell holds exactly one card: only the top card moves
    reserve[slot] = pile.removeLast();
    moves++;
    _flipTop(pile);
    return true;
  }

  bool moveReserveToTableau(int r, int t) {
    final c = reserve[r];
    if (c == null) return false;
    final pile = tableau[t];
    if (pile.isEmpty) {
      if (c.rank != 13) return false;
    } else if (!_canStackOn(c, pile.last)) {
      return false;
    }
    _pushUndo();
    reserve[r] = null;
    pile.add(c);
    moves++;
    score += 5;
    _checkSeqRemove();
    _updateWon();
    return true;
  }

  bool moveReserveToFoundation(int r) {
    final c = reserve[r];
    if (c == null || !_canFoundation(c)) return false;
    _pushUndo();
    reserve[r] = null;
    for (int f = 0; f < foundation.length; f++) {
      if (_canFoundationAt(c, f)) {
        foundation[f].add(c);
        break;
      }
    }
    moves++;
    score += 10;
    _updateWon();
    return true;
  }

  bool moveReservePileToTableau(int t) {
    if (reservePile.isEmpty) return false;
    final c = reservePile.last;
    final pile = tableau[t];
    if (pile.isEmpty) {
      if (c.rank != 13) return false;
    } else if (!_canStackOn(c, pile.last)) {
      return false;
    }
    _pushUndo();
    reservePile.removeLast();
    pile.add(c);
    if (reservePile.isNotEmpty) reservePile.last.faceUp = true;
    moves++;
    score += 5;
    _checkSeqRemove();
    _updateWon();
    return true;
  }

  bool moveReservePileToFoundation() {
    if (reservePile.isEmpty || !_canFoundation(reservePile.last)) return false;
    _pushUndo();
    final c = reservePile.removeLast();
    for (int f = 0; f < foundation.length; f++) {
      if (_canFoundationAt(c, f)) {
        foundation[f].add(c);
        break;
      }
    }
    if (reservePile.isNotEmpty) reservePile.last.faceUp = true;
    moves++;
    score += 10;
    _updateWon();
    return true;
  }

  /// Non-mutating validators for target highlighting.
  bool canWasteToTableau(int t) {
    if (waste.isEmpty) return false;
    final c = waste.last;
    final pile = tableau[t];
    if (pile.isEmpty) return c.rank == 13;
    return _canStackOn(c, pile.last);
  }

  bool canTableauToTableau(int from, int start, int to) {
    if (from == to || from < 0 || to < 0) return false;
    if (from >= tableau.length || to >= tableau.length) return false;
    final src = tableau[from];
    final dst = tableau[to];
    if (!isMovableRun(src, start)) return false;
    final moving = src[start];
    if (dst.isEmpty) return moving.rank == 13;
    return _canStackOn(moving, dst.last);
  }

  bool canReserveToTableau(int r, int t) {
    final c = (r >= 0 && r < reserve.length) ? reserve[r] : null;
    if (c == null) return false;
    final pile = tableau[t];
    if (pile.isEmpty) return c.rank == 13;
    return _canStackOn(c, pile.last);
  }

  bool canReservePileToTableau(int t) {
    if (reservePile.isEmpty) return false;
    final c = reservePile.last;
    final pile = tableau[t];
    if (pile.isEmpty) return c.rank == 13;
    return _canStackOn(c, pile.last);
  }

  /// Move every possible card to the foundations. Returns moves made.
  int autoToFoundation() {
    int made = 0;
    bool progress = true;
    while (progress && !won && made < 500) {
      progress = false;
      for (int i = 0; i < tableau.length; i++) {
        if (moveTableauToFoundation(i)) {
          made++;
          progress = true;
        }
      }
      if (moveWasteToFoundation()) {
        made++;
        progress = true;
      }
      for (int r = 0; r < reserve.length; r++) {
        if (moveReserveToFoundation(r)) {
          made++;
          progress = true;
        }
      }
      if (moveReservePileToFoundation()) {
        made++;
        progress = true;
      }
    }
    return made;
  }

  /// Human-readable hint for one legal move, or '' when none exists.
  String hint() {
    for (int i = 0; i < tableau.length; i++) {
      final p = tableau[i];
      if (p.isNotEmpty && p.last.faceUp && _canFoundation(p.last)) {
        return 'Move ${p.last.rankLabel}${p.last.suitChar} to the foundation.';
      }
    }
    if (waste.isNotEmpty && _canFoundation(waste.last)) {
      return 'Move ${waste.last.rankLabel}${waste.last.suitChar} from the waste to the foundation.';
    }
    for (int i = 0; i < tableau.length; i++) {
      final p = tableau[i];
      if (p.isEmpty) continue;
      for (int s = 0; s < p.length; s++) {
        if (!p[s].faceUp || !isMovableRun(p, s)) continue;
        final moving = p[s];
        for (int t = 0; t < tableau.length; t++) {
          if (t == i) continue;
          final d = tableau[t];
          if (d.isEmpty) {
            if (moving.rank == 13 && s > 0) {
              return 'Move the King stack to the empty column.';
            }
            continue;
          }
          if (_canStackOn(moving, d.last)) {
            final reveals = s > 0 && !p[s - 1].faceUp;
            return 'Move ${moving.rankLabel}${moving.suitChar} onto '
                '${d.last.rankLabel}${d.last.suitChar}'
                '${reveals ? ' to reveal a hidden card' : ''}.';
          }
        }
      }
    }
    if (waste.isNotEmpty) {
      final c = waste.last;
      for (int t = 0; t < tableau.length; t++) {
        final d = tableau[t];
        if ((d.isEmpty && c.rank == 13) ||
            (d.isNotEmpty && _canStackOn(c, d.last))) {
          return 'Play ${c.rankLabel}${c.suitChar} from the waste.';
        }
      }
    }
    for (int r = 0; r < reserve.length; r++) {
      final c = reserve[r];
      if (c == null) continue;
      if (_canFoundation(c)) {
        return 'Move the free ${c.rankLabel}${c.suitChar} to the foundation.';
      }
      for (int t = 0; t < tableau.length; t++) {
        final d = tableau[t];
        if ((d.isEmpty && c.rank == 13) ||
            (d.isNotEmpty && _canStackOn(c, d.last))) {
          return 'Play the free ${c.rankLabel}${c.suitChar} to the tableau.';
        }
      }
    }
    if (reservePile.isNotEmpty) {
      return 'Play ${reservePile.last.rankLabel}${reservePile.last.suitChar} from the reserve.';
    }
    if (stock.isNotEmpty) return 'Draw from the stock.';
    if (waste.isNotEmpty && (cfg.redeals != 0 && redealsLeft != 0)) {
      return 'Redeal the waste back into the stock.';
    }
    return '';
  }

  bool get isWon => won;
}

/// Deterministic shuffle helper (seeded daily / puzzle deals).
class _SeededRandom {
  int _s;
  _SeededRandom(int seed) : _s = seed & 0x7fffffff;
  int _next() {
    _s = (_s * 1103515245 + 12345) & 0x7fffffff;
    return _s;
  }

  void shuffle(List<SolCard> list) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = _next() % (i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
  }
}

/// All solitaire-build variants. Spec modules select one via [solVariant].
class SolitaireConfigs {
  static const klondikeDraw1 = SolConfig(
    piles: 7,
    buildRule: 'alt',
    stockMode: 'draw1',
    redeals: -1,
    decks: 1,
    foundations: 4,
    downPerPile: [0, 1, 2, 3, 4, 5, 6],
    upPerPile: [1, 1, 1, 1, 1, 1, 1],
  );
  static const klondikeDraw3 = SolConfig(
    piles: 7,
    buildRule: 'alt',
    stockMode: 'draw3',
    redeals: 2,
    decks: 1,
    foundations: 4,
    downPerPile: [0, 1, 2, 3, 4, 5, 6],
    upPerPile: [1, 1, 1, 1, 1, 1, 1],
  );
  static const doubleKlondike = SolConfig(
    piles: 9,
    buildRule: 'alt',
    stockMode: 'draw1',
    redeals: -1,
    decks: 2,
    foundations: 8,
    downPerPile: [0, 1, 2, 3, 4, 5, 6, 7, 8],
    upPerPile: [1, 1, 1, 1, 1, 1, 1, 1, 1],
  );
  static const spider4Suit = SolConfig(
    piles: 10,
    buildRule: 'any',
    stockMode: 'dealrow',
    redeals: -1,
    decks: 2,
    foundations: 8,
    downPerPile: [5, 5, 5, 5, 4, 4, 4, 4, 4, 4],
    upPerPile: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    seqRemove: true,
    suitsUsed: 4,
    seqNeedsSuit: true,
  );
  static const spider1Suit = SolConfig(
    piles: 10,
    buildRule: 'any',
    stockMode: 'dealrow',
    redeals: -1,
    decks: 2,
    foundations: 8,
    downPerPile: [5, 5, 5, 5, 4, 4, 4, 4, 4, 4],
    upPerPile: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    seqRemove: true,
    suitsUsed: 1,
    seqNeedsSuit: true,
  );
  static const freeCell = SolConfig(
    piles: 8,
    buildRule: 'alt',
    stockMode: 'none',
    redeals: 0,
    decks: 1,
    foundations: 4,
    reserves: 4,
    downPerPile: [0, 0, 0, 0, 0, 0, 0, 0],
    upPerPile: [7, 7, 7, 7, 6, 6, 6, 6],
  );
  static const yukon = SolConfig(
    piles: 7,
    buildRule: 'alt',
    stockMode: 'none',
    redeals: 0,
    decks: 1,
    foundations: 4,
    downPerPile: [0, 1, 2, 3, 4, 5, 6],
    upPerPile: [1, 5, 5, 5, 5, 5, 5],
  );
  static const scorpion = SolConfig(
    piles: 7,
    buildRule: 'suit',
    stockMode: 'deal3',
    redeals: 0,
    decks: 1,
    foundations: 4,
    downPerPile: [3, 3, 3, 3, 0, 0, 0],
    upPerPile: [4, 4, 4, 4, 7, 7, 7],
  );
  static const fortyThieves = SolConfig(
    piles: 10,
    buildRule: 'suit',
    stockMode: 'draw1',
    redeals: -1,
    decks: 2,
    foundations: 8,
    downPerPile: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    upPerPile: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
  );
  static const canfield = SolConfig(
    piles: 4,
    buildRule: 'alt',
    stockMode: 'draw3',
    redeals: -1,
    decks: 1,
    foundations: 4,
    reservePile: 13,
    foundationBase: 'deal1',
    downPerPile: [0, 0, 0, 0],
    upPerPile: [1, 1, 1, 1],
  );

  static SolConfig byName(String name) {
    switch (name) {
      case 'klondike_draw3':
        return klondikeDraw3;
      case 'double_klondike':
        return doubleKlondike;
      case 'spider_4suit':
        return spider4Suit;
      case 'spider_1suit':
        return spider1Suit;
      case 'freecell':
        return freeCell;
      case 'yukon':
        return yukon;
      case 'scorpion':
        return scorpion;
      case 'forty_thieves':
        return fortyThieves;
      case 'canfield':
        return canfield;
      default:
        return klondikeDraw1;
    }
  }
}

/// Variant selector — spec modules override this single line.
const String solVariant = 'yukon';

SolConfig gameConfig() => SolitaireConfigs.byName(solVariant);
