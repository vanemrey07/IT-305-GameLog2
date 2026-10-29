import 'package:flutter/material.dart';
import 'package:gamelog/firebase_service.dart';
import 'package:gamelog/game_model.dart';
import 'package:gamelog/game_storage.dart';

class AddGamePage extends StatefulWidget {
  const AddGamePage({super.key, this.game});

  final GameEntry? game;

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final _titleController = TextEditingController();
  final _progressController = TextEditingController(text: '0');
  final _ratingController = TextEditingController(text: '0.0');
  String _status = 'Played';
  final storage = GameStorage();

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _titleController.text = widget.game!.title;
      _status = widget.game!.status;
      _progressController.text = widget.game!.progress.toString();
      _ratingController.text = widget.game!.rating.toString();
    }
  }

  Future<void> _saveGame() async {
    final title = _titleController.text.trim();
    final progress = int.tryParse(_progressController.text) ?? 0;
    final rating = double.tryParse(_ratingController.text) ?? 0.0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a game title.')),
      );
      return;
    }

    final existing = await storage.loadGames();
    final updated = [...existing];

    final entry = GameEntry(
      id: widget.game?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      status: _status,
      progress: progress.clamp(0, 100),
      rating: rating.clamp(0.0, 5.0),
    );

    if (widget.game != null) {
      final index = updated.indexWhere((item) => item.id == widget.game!.id);
      if (index >= 0) {
        updated[index] = entry;
      }
    } else {
      updated.add(entry);
    }

    await storage.saveGames(updated);
    await FirebaseService().saveGamesToCloud(
      FirebaseService().currentUserId,
      updated,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _progressController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game == null ? 'Add game' : 'Edit game'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Game title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Completion status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Played', child: Text('Played')),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _progressController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Progress %',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ratingController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Rating (0-5)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveGame,
                icon: const Icon(Icons.save_rounded),
                label: Text(widget.game == null ? 'Save game' : 'Update game'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
