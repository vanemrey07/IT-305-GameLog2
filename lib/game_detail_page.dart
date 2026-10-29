import 'package:flutter/material.dart';
import 'package:gamelog/game_model.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({super.key, required this.game});

  final GameEntry game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _InfoTile(label: 'Status', value: game.status),
            _InfoTile(label: 'Progress', value: '${game.progress}%'),
            _InfoTile(
              label: 'Rating',
              value: '${game.rating.toStringAsFixed(1)}/5',
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.status == 'Completed'
                          ? 'This title is marked complete and ready for your next challenge.'
                          : game.status == 'In Progress'
                          ? 'You are actively playing this title. Keep pushing toward your next milestone.'
                          : 'This game is in your library and waiting to be played.',
                    ),
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
