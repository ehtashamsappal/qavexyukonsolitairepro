import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/core/sound.dart';
import 'package:qavexyukonsolitairepro/game/logic.dart';
import 'package:qavexyukonsolitairepro/game/cards_ui.dart';
import 'package:qavexyukonsolitairepro/screens/mode_select.dart';

class _Sel {
  final String kind; // tab | waste | res | rpile
  final int pile;
  final int start;
  const _Sel(this.kind, this.pile, this.start);
}

class _Particle {
  double x, y, vx, vy, size;
  Color color;
  _Particle(this.x, this.y, this.vx, this.vy, this.size, this.color);
}

class GameScreen extends StatefulWidget {
  final GameModeDef mode;
  const GameScreen({super.key, required this.mode});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late SolitaireEngine _e;
  Timer? _timer;
  int _elapsed = 0;
  int _timeLeft = 0;
  _Sel? _sel;
  Set<int> _targets = {};
  String _message = '';
  bool _over = false;
  bool _won = false;
  bool _paused = false;
  bool _pickingLevel = false;
  int _puzzleLevel = 1;
  int _puzzleUnlocked = 1;
  int _undosThisGame = 0;
  int _hintsThisGame = 0;
  bool _redealt = false;
  late AnimationController _confetti;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  bool get _isTimed => widget.mode.id == 'timed';
  bool get _isDaily => widget.mode.id == 'daily';
  bool get _isZen => widget.mode.id == 'zen';
  bool get _isPuzzle => widget.mode.id == 'puzzle';
  bool get _isKids => widget.mode.id == 'kids';
  bool get _isPractice => widget.mode.id == 'practice';

  @override
  void initState() {
    super.initState();
    _confetti = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..addListener(() {
        if (_particles.isNotEmpty) setState(() => _tickParticles());
      });
    _init();
  }

  Future<void> _init() async {
    if (_isPuzzle) {
      final prefs = await SharedPreferences.getInstance();
      _puzzleUnlocked =
          prefs.getInt('qavexyukonsolitairepro_puzzle_unlocked') ?? 1;
      setState(() => _pickingLevel = true);
    } else {
      _newDeal(seed: _initialSeed());
    }
  }

  int _initialSeed() {
    if (_isDaily) {
      final n = DateTime.now();
      return n.year * 10000 + n.month * 100 + n.day;
    }
    return DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
  }

  void _newDeal({int? seed, int level = 0}) {
    _timer?.cancel();
    _e = SolitaireEngine(gameConfig());
    _e.newGame(seed: seed);
    _elapsed = 0;
    _timeLeft = _isTimed ? 600 : 0;
    _sel = null;
    _targets = {};
    _message = '';
    _over = false;
    _won = false;
    _paused = false;
    _pickingLevel = false;
    _undosThisGame = 0;
    _hintsThisGame = 0;
    _redealt = false;
    _puzzleLevel = level;
    _particles.clear();
    _confetti.reset();
    SoundService.I.play('click');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused || _over) return;
      setState(() {
        _elapsed++;
        if (_isTimed) {
          _timeLeft--;
          if (_timeLeft <= 0) {
            _timeLeft = 0;
            _onLose('Time is up!');
          }
        }
      });
    });
    setState(() {});
    if (_isPractice) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && !_over) _showHint(auto: true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _flash(String msg) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _message == msg) setState(() => _message = '');
    });
  }

  void _clearSel() => setState(() {
        _sel = null;
        _targets = {};
      });

  void _select(_Sel s) {
    final targets = <int>{};
    for (int t = 0; t < _e.tableau.length; t++) {
      bool ok = false;
      if (s.kind == 'tab') {
        ok = _e.canTableauToTableau(s.pile, s.start, t);
      } else if (s.kind == 'waste') {
        ok = _e.canWasteToTableau(t);
      } else if (s.kind == 'res') {
        ok = _e.canReserveToTableau(s.pile, t);
      } else if (s.kind == 'rpile') {
        ok = _e.canReservePileToTableau(t);
      }
      if (ok) targets.add(t);
    }
    SoundService.I.play('tap');
    setState(() {
      _sel = s;
      _targets = targets;
    });
    if (targets.isEmpty && !_isZen) _flash('No legal moves for that card.');
  }

  /// Returns true if the tap was consumed as a move attempt.
  bool _tryMoveTo(int t) {
    final s = _sel;
    if (s == null) return false;
    bool ok = false;
    if (s.kind == 'tab') {
      ok = _e.moveTableauToTableau(s.pile, s.start, t);
    } else if (s.kind == 'waste') {
      ok = _e.moveWasteToTableau(t);
    } else if (s.kind == 'res') {
      ok = _e.moveReserveToTableau(s.pile, t);
    } else if (s.kind == 'rpile') {
      ok = _e.moveReservePileToTableau(t);
    }
    if (ok) {
      _afterMove('pop');
      return true;
    }
    return false;
  }

  void _tapTableauCard(int pile, int idx) {
    if (_over || _paused || _pickingLevel) return;
    final p = _e.tableau[pile];
    if (idx >= p.length) {
      if (_sel != null && !_tryMoveTo(pile)) _clearSel();
      return;
    }
    if (_sel != null &&
        _sel!.kind == 'tab' &&
        _sel!.pile == pile &&
        _sel!.start == idx) {
      _clearSel();
      return;
    }
    if (_sel != null) {
      if (_tryMoveTo(pile)) return;
      _clearSel();
    }
    final card = p[idx];
    if (!card.faceUp) {
      if (!_isZen) {
        SoundService.I.play('error');
        _flash('That card is face down.');
      }
      return;
    }
    if (_e.isMovableRun(p, idx)) {
      _select(_Sel('tab', pile, idx));
    }
  }

  void _doubleTapTableauCard(int pile) {
    if (_over || _paused || _pickingLevel) return;
    if (_e.moveTableauToFoundation(pile)) {
      _afterMove('success');
    } else {
      SoundService.I.play('error');
    }
  }

  void _tapWaste() {
    if (_over || _paused || _pickingLevel || _e.waste.isEmpty) return;
    if (_sel != null && _sel!.kind == 'waste') {
      _clearSel();
      return;
    }
    if (_sel != null) _clearSel();
    _select(const _Sel('waste', 0, 0));
  }

  void _doubleTapWaste() {
    if (_over || _paused || _pickingLevel) return;
    if (_e.moveWasteToFoundation()) {
      _afterMove('success');
    } else {
      SoundService.I.play('error');
    }
  }

  void _tapReserve(int r) {
    if (_over || _paused || _pickingLevel) return;
    if (_e.reserve[r] == null) return;
    if (_sel != null && _sel!.kind == 'res' && _sel!.pile == r) {
      _clearSel();
      return;
    }
    if (_sel != null) _clearSel();
    _select(_Sel('res', r, 0));
  }

  void _tapReservePile() {
    if (_over || _paused || _pickingLevel || _e.reservePile.isEmpty) return;
    if (_sel != null && _sel!.kind == 'rpile') {
      _clearSel();
      return;
    }
    if (_sel != null) _clearSel();
    _select(const _Sel('rpile', 0, 0));
  }

  void _tapStock() {
    if (_over || _paused || _pickingLevel) return;
    _clearSel();
    final hadStock = _e.stock.isNotEmpty;
    if (_e.drawFromStock()) {
      if (!hadStock) {
        _redealt = true;
        _flash('Waste redealt into the stock.');
      }
      SoundService.I.play('tap');
      setState(() {});
      _checkWin();
    } else {
      SoundService.I.play('error');
      _flash(_e.stock.isEmpty && _e.waste.isEmpty
          ? 'Stock is empty.'
          : 'No redeals left.');
    }
  }

  void _afterMove(String sound) {
    SoundService.I.play(sound);
    _sel = null;
    _targets = {};
    setState(() {});
    _checkWin();
  }

  void _checkWin() {
    if (_e.isWon && !_over) _onWin();
  }

  int _finalScore() {
    int s = _e.score;
    if (_isTimed) s += _timeLeft * 2;
    if (_isPuzzle) s += max(0, 1200 - _e.moves * 5);
    return s;
  }

  Future<void> _onWin() async {
    _over = true;
    _won = true;
    _timer?.cancel();
    final score = _finalScore();
    SoundService.I.play('win');
    final app = AppScope.of(context);
    await app.recordGame(mode: widget.mode.id, score: score, won: true);
    app.addCounter('nohint_wins', _hintsThisGame == 0 ? 1 : 0);
    app.addCounter('fast_wins', _elapsed < 300 ? 1 : 0);
    app.addCounter('fast_wins_3', _elapsed < 180 ? 1 : 0);
    app.addCounter('noredeal_wins', _redealt ? 0 : 1);
    app.addCounter('flawless_wins',
        (_hintsThisGame == 0 && _undosThisGame == 0) ? 1 : 0);
    app.addCounter('minimal_wins', _e.moves < 80 ? 1 : 0);
    app.addCounter('comeback_wins', _undosThisGame >= 5 ? 1 : 0);
    if (_isDaily) {
      await app.touchDaily();
      app.addCounter('daily_played', 1);
      app.addCounter('daily_wins', 1);
    }
    if (_isTimed) app.addCounter('timed_wins', 1);
    if (_isZen) app.addCounter('zen_games', 1);
    if (_isKids) app.addCounter('kids_games', 1);
    if (_isPractice) app.addCounter('practice_games', 1);
    app.addCounter('modes_played', 1);
    final prefs = await SharedPreferences.getInstance();
    final streak = (prefs.getInt('qk_win_streak') ?? 0) + 1;
    await prefs.setInt('qk_win_streak', streak);
    if (streak == 5) await app.unlock('streak5');
    if (streak == 10) await app.unlock('streak10');
    final modesKey = 'qk_modes_played';
    final modesDone = prefs.getStringList(modesKey) ?? <String>[];
    if (!modesDone.contains(widget.mode.id)) {
      modesDone.add(widget.mode.id);
      await prefs.setStringList(modesKey, modesDone);
      if (modesDone.length >= 7) await app.unlock('allmodes');
    }
    await prefs.setInt('qk_best', max(prefs.getInt('qk_best') ?? 0, score));
    if (_isPuzzle) {
      final key = 'qk_puzzle_best_$_puzzleLevel';
      final prev = prefs.getInt(key) ?? 0;
      if (score > prev) await prefs.setInt(key, score);
      final doneKey = 'qk_puzzle_done';
      final done = prefs.getStringList(doneKey) ?? <String>[];
      if (!done.contains('$_puzzleLevel')) {
        done.add('$_puzzleLevel');
        await prefs.setStringList(doneKey, done);
        app.addCounter('puzzle_levels', 1);
      }
      if (_puzzleLevel >= _puzzleUnlocked && _puzzleUnlocked < 24) {
        _puzzleUnlocked++;
        await prefs.setInt(
            'qavexyukonsolitairepro_puzzle_unlocked', _puzzleUnlocked);
        SoundService.I.play('levelup');
      }
    }
    _spawnConfetti();
    _confetti.forward();
    setState(() {});
  }

  Future<void> _onLose(String reason) async {
    _over = true;
    _won = false;
    _timer?.cancel();
    SoundService.I.play('lose');
    final app = AppScope.of(context);
    await app.recordGame(mode: widget.mode.id, score: _e.score, won: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('qk_win_streak', 0);
    _flash(reason);
    setState(() {});
  }

  void _spawnConfetti() {
    final colors = [
      QCardColors.gold,
      QCardColors.accent,
      Colors.white,
      const Color(0xFFFF6B6B),
      const Color(0xFF4CC9F0),
    ];
    for (int i = 0; i < 90; i++) {
      _particles.add(_Particle(
        _rng.nextDouble(),
        -0.05 - _rng.nextDouble() * 0.2,
        (_rng.nextDouble() - 0.5) * 0.4,
        0.25 + _rng.nextDouble() * 0.45,
        4 + _rng.nextDouble() * 7,
        colors[_rng.nextInt(colors.length)],
      ));
    }
  }

  void _tickParticles() {
    const dt = 1 / 60;
    for (final p in _particles) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 0.35 * dt;
    }
    _particles.removeWhere((p) => p.y > 1.15);
  }

  void _showHint({bool auto = false}) {
    if (_over || _paused) return;
    final h = _e.hint();
    _hintsThisGame++;
    final app = AppScope.of(context);
    app.addCounter('hints_used', 1);
    setState(() {});
    _flash(h.isEmpty
        ? 'No moves left — draw from the stock or start a new deal.'
        : (_isKids ? 'Try this: $h You are doing great!' : h));
    if (!auto) SoundService.I.play('tap');
  }

  void _doUndo() {
    if (_over || _paused) return;
    if (_e.canUndo) {
      _e.undo();
      _undosThisGame++;
      AppScope.of(context).addCounter('undos_game', 0);
      SoundService.I.play('tap');
      _clearSel();
    } else {
      SoundService.I.play('error');
      _flash('Nothing to undo.');
    }
  }

  void _doAuto() {
    if (_over || _paused) return;
    _clearSel();
    final n = _e.autoToFoundation();
    if (n > 0) {
      _afterMove('success');
      _flash('$n card${n == 1 ? '' : 's'} sent home!');
    } else {
      SoundService.I.play('error');
      _flash('No safe auto-moves right now.');
    }
  }

  String _clock() {
    final t = _isTimed ? _timeLeft : _elapsed;
    final m = t ~/ 60;
    final s = t % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ============================ UI ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QCardColors.bgDark,
      body: QFeltScaffold(
        child: _pickingLevel ? _buildLevelPicker() : _buildTable(context),
        overlays: [
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ConfettiPainter(_particles)),
              ),
            ),
          if (_paused && !_over) _buildPauseOverlay(),
          if (_over && _won) _buildWinOverlay(),
          if (_over && !_won) _buildLoseOverlay(),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final piles = _e.tableau.length;
      double cw =
          (constraints.maxWidth - 20 - (piles - 1) * 6) / piles;
      cw = cw.clamp(26.0, 78.0);
      final topH = cw * 1.42 + 26;
      return Column(
        children: [
          _buildHud(cw),
          _buildControls(),
          SizedBox(height: topH, child: _buildTopRow(cw)),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < piles; i++)
                    Padding(
                      padding: EdgeInsets.only(
                          left: i == 0 ? 10 : 3, right: 3),
                      child: _buildPile(i, cw, constraints.maxHeight),
                    ),
                ],
              ),
            ),
          ),
          _buildMessageBar(),
          const SizedBox(height: 4),
        ],
      );
    });
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: QCardColors.gold),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildHud(double cw) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Back',
            iconSize: 26,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(widget.mode.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis),
          ),
          _chip('${_e.score}', Icons.stars),
          const SizedBox(width: 6),
          _chip(_clock(),
              _isTimed ? Icons.timer : Icons.access_time),
          const SizedBox(width: 6),
          _chip('${_e.moves}', Icons.touch_app),
        ],
      ),
    );
  }

  Widget _hudButton(IconData icon, String tip, VoidCallback onTap) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        tooltip: tip,
        iconSize: 25,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _hudButton(Icons.refresh, 'New deal',
              () => _newDeal(seed: _isDaily ? _initialSeed() : null)),
          _hudButton(Icons.undo, 'Undo', _doUndo),
          _hudButton(Icons.lightbulb, 'Hint', () => _showHint()),
          _hudButton(Icons.auto_awesome, 'Auto-finish', _doAuto),
          _hudButton(Icons.pause, 'Pause',
              () => setState(() => _paused = true)),
        ],
      ),
    );
  }

  Widget _buildTopRow(double cw) {
    final ch = cw * 1.42;
    List<Widget> kids = [];
    // stock
    kids.add(GestureDetector(
      onTap: _tapStock,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _e.stock.isEmpty
              ? QCardSlot(
                  width: cw,
                  glyph: (_e.cfg.redeals != 0 && _e.redealsLeft != 0 &&
                          _e.waste.isNotEmpty)
                      ? '\u21BB'
                      : '')
              : QCardBack(width: cw),
          const SizedBox(height: 2),
          Text('${_e.stock.length}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75), fontSize: 11)),
        ],
      ),
    ));
    kids.add(const SizedBox(width: 8));
    // waste (fan of last 3, only top interactive)
    final wn = _e.waste.length;
    final show = wn == 0
        ? <SolCard>[]
        : _e.waste.sublist(max(0, wn - 3));
    kids.add(SizedBox(
      width: cw + (show.isEmpty ? 0 : (show.length - 1) * cw * 0.32),
      height: ch + 20,
      child: show.isEmpty
          ? QCardSlot(width: cw)
          : Stack(
              children: [
                for (int i = 0; i < show.length; i++)
                  Positioned(
                    left: i * cw * 0.32,
                    child: GestureDetector(
                      onTap: i == show.length - 1 ? _tapWaste : null,
                      onDoubleTap:
                          i == show.length - 1 ? _doubleTapWaste : null,
                      child: QCardFace(
                        rank: show[i].rankLabel,
                        suit: show[i].suitChar,
                        width: cw,
                        selected: _sel != null && _sel!.kind == 'waste',
                      ),
                    ),
                  ),
              ],
            ),
    ));
    kids.add(const Spacer());
    // foundations
    for (int f = 0; f < _e.foundation.length; f++) {
      final pile = _e.foundation[f];
      kids.add(Padding(
        padding: const EdgeInsets.only(left: 6),
        child: pile.isEmpty
            ? QCardSlot(width: cw, glyph: 'A')
            : QCardFace(
                rank: pile.last.rankLabel,
                suit: pile.last.suitChar,
                width: cw),
      ));
    }
    // freecells
    for (int r = 0; r < _e.reserve.length; r++) {
      final c = _e.reserve[r];
      kids.add(Padding(
        padding: const EdgeInsets.only(left: 6),
        child: GestureDetector(
          onTap: () => _tapReserve(r),
          child: c == null
              ? QCardSlot(width: cw * 0.9)
              : QCardFace(
                  rank: c.rankLabel,
                  suit: c.suitChar,
                  width: cw * 0.9,
                  selected:
                      _sel != null && _sel!.kind == 'res' && _sel!.pile == r,
                ),
        ),
      ));
    }
    // canfield-style reserve pile
    if (_e.reservePile.isNotEmpty || _e.cfg.reservePile > 0) {
      final c = _e.reservePile.isEmpty ? null : _e.reservePile.last;
      kids.add(Padding(
        padding: const EdgeInsets.only(left: 6),
        child: GestureDetector(
          onTap: _tapReservePile,
          child: c == null
              ? QCardSlot(width: cw * 0.9, glyph: 'R')
              : QCardFace(
                  rank: c.rankLabel,
                  suit: c.suitChar,
                  width: cw * 0.9,
                  selected: _sel != null && _sel!.kind == 'rpile',
                ),
        ),
      ));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: kids,
    );
  }

  Widget _buildPile(int i, double cw, double maxH) {
    final pile = _e.tableau[i];
    final ch = cw * 1.42;
    double up = 30, down = 11;
    double need = ch;
    for (final c in pile) {
      need += c.faceUp ? up : down;
    }
    final avail = max(200.0, maxH - 320);
    if (need > avail && pile.isNotEmpty) {
      final f = (avail - ch) / (need - ch);
      up = max(9.0, up * f);
      down = max(4.0, down * f);
    }
    final targeted = _targets.contains(i);
    List<Widget> stack = [];
    double y = 0;
    for (int j = 0; j < pile.length; j++) {
      final c = pile[j];
      final idx = j;
      final selected =
          _sel != null && _sel!.kind == 'tab' && _sel!.pile == i && idx >= _sel!.start;
      stack.add(Positioned(
        top: y,
        child: GestureDetector(
          onTap: () => _tapTableauCard(i, idx),
          onDoubleTap: () => _doubleTapTableauCard(i),
          child: c.faceUp
              ? QCardFace(
                  rank: c.rankLabel,
                  suit: c.suitChar,
                  width: cw,
                  selected: selected)
              : QCardBack(width: cw),
        ),
      ));
      y += c.faceUp ? up : down;
    }
    final totalH = pile.isEmpty ? ch : y - (pile.last.faceUp ? up : down) + ch;
    Widget body = SizedBox(
      width: cw,
      height: totalH,
      child: Stack(
        children: [
          if (pile.isEmpty)
            QCardSlot(width: cw, highlight: targeted),
          ...stack,
        ],
      ),
    );
    if (targeted && pile.isNotEmpty) {
      body = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: QCardColors.gold, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: QCardColors.gold.withOpacity(0.5), blurRadius: 10)
          ],
        ),
        child: body,
      );
    }
    return GestureDetector(
      onTap: () => _tapTableauCard(i, pile.length),
      child: body,
    );
  }

  Widget _buildMessageBar() {
    return SizedBox(
      height: 30,
      child: Center(
        child: AnimatedOpacity(
          opacity: _message.isEmpty ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(_message,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }

  Widget _overlayCard(Widget child) {
    return Container(
      color: Colors.black.withOpacity(0.62),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: QCardColors.bgMid,
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: QCardColors.gold.withOpacity(0.6), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 24)
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _menuButton(String label, IconData icon, VoidCallback onTap,
      {bool primary = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: primary ? QCardColors.bgDark : Colors.white),
        label: Text(label,
            style: TextStyle(
                color: primary ? QCardColors.bgDark : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              primary ? QCardColors.gold : Colors.white.withOpacity(0.12),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return _overlayCard(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Paused',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(widget.mode.name,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontSize: 14)),
        const SizedBox(height: 18),
        _menuButton('Resume', Icons.play_arrow,
            () => setState(() => _paused = false),
            primary: true),
        const SizedBox(height: 10),
        _menuButton('New Deal', Icons.refresh,
            () => _newDeal(seed: _isDaily ? _initialSeed() : null)),
        const SizedBox(height: 10),
        _menuButton('Quit to Menu', Icons.home,
            () => Navigator.of(context).maybePop()),
      ],
    ));
  }

  int _starsForWin() {
    if (!_isPuzzle) {
      final s = _finalScore();
      if (s >= 900) return 3;
      if (s >= 500) return 2;
      return 1;
    }
    final par2 = 350 + _puzzleLevel * 15;
    final par3 = 550 + _puzzleLevel * 20;
    final s = _finalScore();
    if (s >= par3) return 3;
    if (s >= par2) return 2;
    return 1;
  }

  Widget _buildWinOverlay() {
    final stars = _starsForWin();
    return _overlayCard(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: const Text('Congratulations!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              Icon(Icons.star,
                  size: 40,
                  color: i < stars
                      ? QCardColors.gold
                      : Colors.white.withOpacity(0.25)),
          ],
        ),
        const SizedBox(height: 10),
        Text('Score ${_finalScore()}  •  ${_e.moves} moves  •  ${_clock()}',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.85), fontSize: 14)),
        if (_isPuzzle)
          Text('Puzzle level $_puzzleLevel cleared!',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        _menuButton(
            _isPuzzle && _puzzleLevel < 24 ? 'Next Level' : 'New Deal',
            Icons.arrow_forward,
            () {
              if (_isPuzzle && _puzzleLevel < 24) {
                final lv = _puzzleLevel + 1;
                _newDeal(seed: 1000 + lv * 37 + 7, level: lv);
              } else {
                _newDeal(
                    seed: _isDaily ? _initialSeed() : null,
                    level: _puzzleLevel);
              }
            },
            primary: true),
        const SizedBox(height: 10),
        _menuButton('Back to Menu', Icons.home,
            () => Navigator.of(context).maybePop()),
      ],
    ));
  }

  Widget _buildLoseOverlay() {
    return _overlayCard(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Out of Time',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('Score ${_e.score} — so close! Try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8), fontSize: 14)),
        const SizedBox(height: 18),
        _menuButton('Try Again', Icons.refresh,
            () => _newDeal(seed: _isDaily ? _initialSeed() : null),
            primary: true),
        const SizedBox(height: 10),
        _menuButton('Back to Menu', Icons.home,
            () => Navigator.of(context).maybePop()),
      ],
    ));
  }

  Widget _buildLevelPicker() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Expanded(
                child: Text('Puzzle Levels',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Clear a level to unlock the next one.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 24,
              itemBuilder: (context, i) {
                final lv = i + 1;
                final locked = lv > _puzzleUnlocked;
                return GestureDetector(
                  onTap: locked
                      ? null
                      : () => _newDeal(seed: 1000 + lv * 37 + 7, level: lv),
                  child: Container(
                    decoration: BoxDecoration(
                      color: locked
                          ? Colors.white.withOpacity(0.06)
                          : QCardColors.accent.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: locked
                              ? Colors.white.withOpacity(0.15)
                              : QCardColors.gold),
                    ),
                    child: Center(
                      child: locked
                          ? Icon(Icons.lock,
                              color: Colors.white.withOpacity(0.35))
                          : Text('$lv',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color;
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(p.x * size.width, p.y * size.height),
            width: p.size,
            height: p.size * 0.6),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
