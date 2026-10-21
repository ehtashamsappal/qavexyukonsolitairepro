/// Achievement definitions. Progress is tracked in [AppState.counters]
/// keyed by [Achievement.trigger]; unlocking grants [coins].
class Achievement {
  final String id;
  final String name;
  final String desc;
  final int coins;
  final String trigger;
  final int goal;
  const Achievement({
    required this.id,
    required this.name,
    required this.desc,
    required this.coins,
    required this.trigger,
    required this.goal,
  });
}

const List<Achievement> kAchievements = <Achievement>[
  Achievement(id: 'yukw0', name: 'First Victory', desc: 'Win your first game (Yukon)', coins: 20, trigger: 'wins', goal: 1),
  Achievement(id: 'yukw1', name: 'Table Regular', desc: 'Win 10 games (Yukon)', coins: 60, trigger: 'wins', goal: 10),
  Achievement(id: 'yukw2', name: 'Card Sharp', desc: 'Win 50 games (Yukon)', coins: 100, trigger: 'wins', goal: 50),
  Achievement(id: 'yukw3', name: 'House Legend', desc: 'Win 100 games (Yukon)', coins: 140, trigger: 'wins', goal: 100),
  Achievement(id: 'yukg0', name: 'Warming Up', desc: 'Play 10 games', coins: 15, trigger: 'games', goal: 10),
  Achievement(id: 'yukg1', name: 'Devotee', desc: 'Play 100 games', coins: 60, trigger: 'games', goal: 100),
  Achievement(id: 'yukg2', name: 'Lifer', desc: 'Play 500 games', coins: 200, trigger: 'games', goal: 500),
  Achievement(id: 'yukd0', name: 'Three-Day Streak', desc: 'Win 3 daily challenges in a row', coins: 40, trigger: 'daily_streak', goal: 3),
  Achievement(id: 'yukd1', name: 'Week of Wins', desc: 'Win 7 daily challenges in a row', coins: 100, trigger: 'daily_streak', goal: 7),
  Achievement(id: 'yukd2', name: 'Monthly Marvel', desc: 'Win 30 daily challenges in a row', coins: 300, trigger: 'daily_streak', goal: 30),
  Achievement(id: 'yukm0', name: 'Speed Demon', desc: 'Win a game in under 5 minutes', coins: 60, trigger: 'fast_wins', goal: 1),
  Achievement(id: 'yukm1', name: 'Lightning Felt', desc: 'Win a game in under 3 minutes', coins: 120, trigger: 'fast_wins_3', goal: 1),
  Achievement(id: 'yukm2', name: 'Purist', desc: 'Win without using a hint', coins: 50, trigger: 'nohint_wins', goal: 1),
  Achievement(id: 'yukm3', name: 'Flawless', desc: 'Win with zero undos and zero hints', coins: 150, trigger: 'flawless_wins', goal: 1),
  Achievement(id: 'yukm4', name: 'On Fire', desc: 'Reach a 5-game win streak', coins: 60, trigger: 'streak5unlock', goal: 1),
  Achievement(id: 'yukm5', name: 'Unstoppable', desc: 'Reach a 10-game win streak', coins: 150, trigger: 'streak10unlock', goal: 1),
  Achievement(id: 'yukm6', name: 'Calm Mind', desc: 'Play 10 zen games', coins: 30, trigger: 'zen_games', goal: 10),
  Achievement(id: 'yukm7', name: 'Mentor', desc: 'Play 10 kids-mode games', coins: 30, trigger: 'kids_games', goal: 10),
  Achievement(id: 'yukm8', name: 'Beat the Clock', desc: 'Win 5 timed runs', coins: 60, trigger: 'timed_wins', goal: 5),
  Achievement(id: 'yukm9', name: 'Kind Soul', desc: 'Support the developer with a coffee', coins: 100, trigger: 'coffees', goal: 1),
  Achievement(id: 'yukm10', name: 'New Look', desc: 'Unlock a theme', coins: 15, trigger: 'themes_owned', goal: 1),
  Achievement(id: 'yukm11', name: 'Collector', desc: 'Own all 8 themes', coins: 150, trigger: 'themes_owned', goal: 8),
  Achievement(id: 'yukm12', name: 'Fresh Felt', desc: 'Start 25 new games', coins: 20, trigger: 'new_games', goal: 25),
  Achievement(id: 'yukm13', name: 'Guided', desc: 'Use 50 hints', coins: 25, trigger: 'hints_used', goal: 50),
  Achievement(id: 'yukm14', name: 'Second Thoughts', desc: 'Undo 10 times in one game', coins: 10, trigger: 'undos_game', goal: 10),
  Achievement(id: 'yukm15', name: 'Century Moves', desc: 'Make 100 moves in one game', coins: 20, trigger: 'moves_game', goal: 100),
  Achievement(id: 'yukm16', name: 'Gilded', desc: 'Earn 1,000 lifetime coins', coins: 60, trigger: 'coins_total', goal: 1000),
  Achievement(id: 'yukm17', name: 'Minted', desc: 'Earn 5,000 lifetime coins', coins: 150, trigger: 'coins_total', goal: 5000),
  Achievement(id: 'yukm18', name: 'Explorer', desc: 'Play every game mode', coins: 60, trigger: 'allmodesunlock', goal: 1),
  Achievement(id: 'yukm19', name: 'Night Owl', desc: 'Win a game after midnight', coins: 20, trigger: 'night_wins', goal: 1),
  Achievement(id: 'yukm20', name: 'Early Bird', desc: 'Win a game before 7 AM', coins: 20, trigger: 'morning_wins', goal: 1),
  Achievement(id: 'yukm21', name: 'Weekend Warrior', desc: 'Win 5 games on a weekend', coins: 40, trigger: 'weekend_wins', goal: 5),
  Achievement(id: 'yukm22', name: 'Marathon', desc: 'Play 60 minutes in one day', coins: 50, trigger: 'minutes_day', goal: 60),
  Achievement(id: 'yukm23', name: 'Comeback Kid', desc: 'Win after undoing 5+ times', coins: 40, trigger: 'comeback_wins', goal: 1),
  Achievement(id: 'yukm24', name: 'Minimalist', desc: 'Win in under 80 moves', coins: 90, trigger: 'minimal_wins', goal: 1),
  Achievement(id: 'yukm25', name: 'Vegas Nights', desc: 'Earn 100 coins in one day', coins: 25, trigger: 'coins_day', goal: 100),
  Achievement(id: 'yukm26', name: 'High Roller', desc: 'Score 5,000 in one game', coins: 40, trigger: 'best_classic', goal: 5000),
  Achievement(id: 'yukm27', name: 'Felt Phenomenon', desc: 'Score 10,000 in one game', coins: 100, trigger: 'best_classic', goal: 10000),
  Achievement(id: 'yukm28', name: 'Student', desc: 'Play 10 practice games', coins: 20, trigger: 'practice_games', goal: 10),
  Achievement(id: 'yukm29', name: 'Daily Grind', desc: 'Play your first daily challenge', coins: 15, trigger: 'daily_played', goal: 1),
  Achievement(id: 'yukm30', name: 'First Draw', desc: 'Draw your first card', coins: 10, trigger: 'draws', goal: 1),
  Achievement(id: 'yukm31', name: 'Shuffler', desc: 'Shuffle 100 times', coins: 20, trigger: 'shuffles', goal: 100),
  Achievement(id: 'yukm32', name: 'Patient', desc: 'Think 30 seconds before a move', coins: 15, trigger: 'thinkers', goal: 1),
  Achievement(id: 'yukm33', name: 'Lucky Seven', desc: 'Win on the 7th of the month', coins: 30, trigger: 'lucky7', goal: 1),
  Achievement(id: 'yukm34', name: 'No Take-Backs', desc: 'Win without redealing', coins: 80, trigger: 'noredeal_wins', goal: 1),
  Achievement(id: 'yukm35', name: 'Royal Move', desc: 'Move a king to an empty column 25 times', coins: 30, trigger: 'king_moves', goal: 25),
  Achievement(id: 'yukm36', name: 'Sequencer', desc: 'Build 50 descending sequences', coins: 40, trigger: 'sequences', goal: 50),
  Achievement(id: 'yukm37', name: 'Ace Up', desc: 'Move an ace home in under 30 seconds', coins: 15, trigger: 'ace_fast', goal: 1),
  Achievement(id: 'yukm38', name: 'House Favorite', desc: 'Hold the top local leaderboard score', coins: 100, trigger: 'leader_top', goal: 1),
  Achievement(id: 'yukm39', name: 'Table Tactician', desc: 'Use 25 auto-finishes', coins: 30, trigger: 'autofinishes', goal: 25),
  Achievement(id: 'yukm40', name: 'Golden Touch', desc: 'Earn a 3-star puzzle rating 10 times', coins: 60, trigger: 'stars3', goal: 10),
  Achievement(id: 'yukm41', name: 'Deck Devotee', desc: 'Win with every theme equipped once', coins: 80, trigger: 'themes_used', goal: 8),
];

int get kTotalAchievementCoins =>
    kAchievements.fold(0, (p, a) => p + a.coins);
