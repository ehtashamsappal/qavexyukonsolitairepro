import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qavexyukonsolitairepro/core/achievements.dart';

/// Global app state: settings, wallet, stats, streaks, players,
/// achievements. Persisted with SharedPreferences.
class AppState extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool ready = false;

  // ---- settings ----
  double textScale = 1.0;
  bool highContrast = false;
  bool kidsMode = false;
  bool soundOn = true;
  String themeId = 'classic';

  // ---- wallet ----
  int coins = 0;
  bool supporter = false;
  final Set<String> themesOwned = <String>{'classic'};

  // ---- streak ----
  int streak = 0;
  String lastPlay = '';

  // ---- players ----
  List<String> players = <String>['Player 1'];
  int activePlayer = 0;

  // ---- stats ----
  int gamesPlayed = 0;
  int totalShots = 0;
  int totalMakes = 0;
  int totalWins = 0;
  int bestScore = 0;
  int coinsEarned = 0;
  final Map<String, int> modeBest = <String, int>{};

  // ---- achievements ----
  final Set<String> unlocked = <String>{};
  final Map<String, int> counters = <String, int>{};

  String _k(String s) => 'qavexyukonsolitairepro_$s';

  static String todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    textScale = _prefs.getDouble(_k('textScale')) ?? 1.0;
    highContrast = _prefs.getBool(_k('highContrast')) ?? false;
    kidsMode = _prefs.getBool(_k('kidsMode')) ?? false;
    soundOn = _prefs.getBool(_k('soundOn')) ?? true;
    themeId = _prefs.getString(_k('themeId')) ?? 'classic';
    coins = _prefs.getInt(_k('coins')) ?? 0;
    supporter = _prefs.getBool(_k('supporter')) ?? false;
    themesOwned.addAll(_prefs.getStringList(_k('themesOwned')) ?? const ['classic']);
    streak = _prefs.getInt(_k('streak')) ?? 0;
    lastPlay = _prefs.getString(_k('lastPlay')) ?? '';
    players = _prefs.getStringList(_k('players')) ?? <String>['Player 1'];
    activePlayer = _prefs.getInt(_k('activePlayer')) ?? 0;
    if (activePlayer >= players.length) activePlayer = 0;
    gamesPlayed = _prefs.getInt(_k('gamesPlayed')) ?? 0;
    totalShots = _prefs.getInt(_k('totalShots')) ?? 0;
    totalMakes = _prefs.getInt(_k('totalMakes')) ?? 0;
    totalWins = _prefs.getInt(_k('totalWins')) ?? 0;
    bestScore = _prefs.getInt(_k('bestScore')) ?? 0;
    coinsEarned = _prefs.getInt(_k('coinsEarned')) ?? 0;
    final mb = _prefs.getString(_k('modeBest'));
    if (mb != null && mb.isNotEmpty) {
      for (final e in (jsonDecode(mb) as Map<String, dynamic>).entries) {
        modeBest[e.key] = (e.value as num).toInt();
      }
    }
    unlocked.addAll(_prefs.getStringList(_k('unlocked')) ?? const <String>[]);
    final cb = _prefs.getString(_k('counters'));
    if (cb != null && cb.isNotEmpty) {
      for (final e in (jsonDecode(cb) as Map<String, dynamic>).entries) {
        counters[e.key] = (e.value as num).toInt();
      }
    }
    touchDaily(silent: true);
    ready = true;
    notifyListeners();
  }

  Future<void> _save() async {
    await _prefs.setDouble(_k('textScale'), textScale);
    await _prefs.setBool(_k('highContrast'), highContrast);
    await _prefs.setBool(_k('kidsMode'), kidsMode);
    await _prefs.setBool(_k('soundOn'), soundOn);
    await _prefs.setString(_k('themeId'), themeId);
    await _prefs.setInt(_k('coins'), coins);
    await _prefs.setBool(_k('supporter'), supporter);
    await _prefs.setStringList(_k('themesOwned'), themesOwned.toList());
    await _prefs.setInt(_k('streak'), streak);
    await _prefs.setString(_k('lastPlay'), lastPlay);
    await _prefs.setStringList(_k('players'), players);
    await _prefs.setInt(_k('activePlayer'), activePlayer);
    await _prefs.setInt(_k('gamesPlayed'), gamesPlayed);
    await _prefs.setInt(_k('totalShots'), totalShots);
    await _prefs.setInt(_k('totalMakes'), totalMakes);
    await _prefs.setInt(_k('totalWins'), totalWins);
    await _prefs.setInt(_k('bestScore'), bestScore);
    await _prefs.setInt(_k('coinsEarned'), coinsEarned);
    await _prefs.setString(_k('modeBest'), jsonEncode(modeBest));
    await _prefs.setStringList(_k('unlocked'), unlocked.toList());
    await _prefs.setString(_k('counters'), jsonEncode(counters));
  }

  // ---------- settings ----------
  Future<void> setTextScale(double v) async {
    textScale = v.clamp(0.8, 1.6);
    notifyListeners();
    await _save();
  }

  Future<void> toggleHighContrast() async {
    highContrast = !highContrast;
    notifyListeners();
    await _save();
  }

  Future<void> toggleKidsMode() async {
    kidsMode = !kidsMode;
    notifyListeners();
    await _save();
  }

  Future<void> toggleSound() async {
    soundOn = !soundOn;
    notifyListeners();
    await _save();
  }

  Future<void> setTheme(String id) async {
    themeId = id;
    notifyListeners();
    await _save();
  }

  // ---------- wallet ----------
  Future<void> addCoins(int n) async {
    if (n <= 0) return;
    coins += n;
    coinsEarned += n;
    addCounter('coins', n);
    notifyListeners();
    await _save();
  }

  Future<bool> spendCoins(int n) async {
    if (coins < n) return false;
    coins -= n;
    notifyListeners();
    await _save();
    return true;
  }

  Future<void> setSupporter() async {
    supporter = true;
    addCounter('supporter', 1);
    notifyListeners();
    await _save();
  }

  Future<bool> buyTheme(String id, int price) async {
    if (themesOwned.contains(id)) return true;
    if (!await spendCoins(price)) return false;
    themesOwned.add(id);
    themeId = id;
    addCounter('themes', 1);
    notifyListeners();
    await _save();
    return true;
  }

  // ---------- streak ----------
  /// Updates the daily streak. Returns coins bonus granted (0 if none).
  Future<int> touchDaily({bool silent = false}) async {
    final today = todayStr();
    if (lastPlay == today) return 0;
    final y = DateTime.now().subtract(const Duration(days: 1));
    final yesterday =
        '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    if (lastPlay == yesterday) {
      streak += 1;
    } else {
      streak = 1;
    }
    lastPlay = today;
    counters['streak'] = streak;
    _check('streak');
    final bonus = 5 + (streak > 30 ? 30 : streak);
    if (!silent) {
      await addCoins(bonus);
    } else {
      coins += bonus;
      coinsEarned += bonus;
    }
    notifyListeners();
    await _save();
    return bonus;
  }

  // ---------- players ----------
  Future<void> addPlayer(String name) async {
    if (players.length >= 4 || name.trim().isEmpty) return;
    players.add(name.trim());
    notifyListeners();
    await _save();
  }

  Future<void> renamePlayer(int i, String name) async {
    if (i < 0 || i >= players.length || name.trim().isEmpty) return;
    players[i] = name.trim();
    notifyListeners();
    await _save();
  }

  Future<void> removePlayer(int i) async {
    if (players.length <= 1 || i < 0 || i >= players.length) return;
    players.removeAt(i);
    if (activePlayer >= players.length) activePlayer = 0;
    notifyListeners();
    await _save();
  }

  Future<void> setActivePlayer(int i) async {
    if (i < 0 || i >= players.length) return;
    activePlayer = i;
    notifyListeners();
    await _save();
  }

  // ---------- gameplay records ----------
  Future<void> recordShot(bool make) async {
    totalShots += 1;
    if (make) {
      totalMakes += 1;
      addCounter('makes', 1);
    }
    addCounter('shots', 1);
    notifyListeners();
    await _save();
  }

  Future<void> recordGame(
      {required String mode, required int score, required bool won}) async {
    gamesPlayed += 1;
    addCounter('games', 1);
    if (score > bestScore) bestScore = score;
    final prev = modeBest[mode] ?? 0;
    if (score > prev) {
      modeBest[mode] = score;
      addCounter('best_$mode', 1);
    }
    if (won) {
      totalWins += 1;
      addCounter('wins', 1);
    }
    addCounter('score', score);
    final reward = 5 + (score ~/ 10) + (won ? 10 : 0);
    notifyListeners();
    await _save();
    await addCoins(reward);
  }

  // ---------- achievements ----------
  void addCounter(String trigger, int by) {
    counters[trigger] = (counters[trigger] ?? 0) + by;
    _check(trigger);
  }

  void _check(String trigger) {
    for (final a in kAchievements) {
      if (a.trigger == trigger &&
          !unlocked.contains(a.id) &&
          (counters[trigger] ?? 0) >= a.goal) {
        unlocked.add(a.id);
        coins += a.coins;
        coinsEarned += a.coins;
      }
    }
  }

  Future<void> unlock(String id) async {
    if (unlocked.contains(id)) return;
    final def = kAchievements.firstWhere((a) => a.id == id,
        orElse: () => const Achievement(
            id: '', name: '', desc: '', coins: 0, trigger: '', goal: 0));
    if (def.id.isEmpty) return;
    unlocked.add(id);
    await addCoins(def.coins);
  }

  Future<void> resetProgress() async {
    coins = 0;
    supporter = false;
    themesOwned
      ..clear()
      ..add('classic');
    themeId = 'classic';
    streak = 0;
    lastPlay = '';
    players = <String>['Player 1'];
    activePlayer = 0;
    gamesPlayed = 0;
    totalShots = 0;
    totalMakes = 0;
    totalWins = 0;
    bestScore = 0;
    coinsEarned = 0;
    modeBest.clear();
    unlocked.clear();
    counters.clear();
    notifyListeners();
    await _save();
  }
}

class AppScope extends InheritedWidget {
  final AppState state;
  const AppScope({super.key, required this.state, required super.child});

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.state;

  @override
  bool updateShouldNotify(AppScope oldWidget) => state != oldWidget.state;
}

class AppBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AppState state) builder;
  const AppBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => builder(context, state),
    );
  }
}
