import 'package:flutter/material.dart';
import 'package:qavexyukonsolitairepro/core/app_state.dart';
import 'package:qavexyukonsolitairepro/widgets/ui.dart';

class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  Future<void> _askName(BuildContext context, AppState s,
      {String? initial, required void Function(String) onOk}) async {
    final ctrl = TextEditingController(text: initial ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(initial == null ? 'Add player' : 'Rename player'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 16,
          decoration:
              const InputDecoration(hintText: 'Player name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(c).pop(ctrl.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) onOk(name);
  }

  @override
  Widget build(BuildContext context) {
    return AppBuilder(
      builder: (context, s) => QxScaffold(
        title: 'Players',
        body: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                  'Up to 4 local players. Pass-and-play modes rotate through this list.',
                  style: TextStyle(fontSize: 13)),
            ),
            for (int i = 0; i < s.players.length; i++)
              QxCard(
                child: Row(
                  children: [
                    CircleAvatar(child: Text('${i + 1}')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(s.players[i],
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold))),
                    if (s.activePlayer == i)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('ACTIVE',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Rename',
                      onPressed: () => _askName(context, s,
                          initial: s.players[i],
                          onOk: (n) => s.renamePlayer(i, n)),
                    ),
                    if (s.players.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Remove',
                        onPressed: () => s.removePlayer(i),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: QxButton(
                label: 'Add player (${s.players.length}/4)',
                icon: Icons.person_add,
                onPressed: s.players.length >= 4
                    ? null
                    : () => _askName(context, s,
                        onOk: (n) => s.addPlayer(n)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
