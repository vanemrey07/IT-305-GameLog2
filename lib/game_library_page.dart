import 'package:flutter/material.dart';
import 'package:gamelog/add_game_page.dart';
import 'package:gamelog/firebase_service.dart';
import 'package:gamelog/game_detail_page.dart';
import 'package:gamelog/game_model.dart';
import 'package:gamelog/game_storage.dart';

class GameLibraryPage extends StatefulWidget {
  const GameLibraryPage({super.key});

  @override
  State<GameLibraryPage> createState() => _GameLibraryPageState();
}

class _GameLibraryPageState extends State<GameLibraryPage> {
  final _storage = GameStorage();
  final _searchController = TextEditingController();
  String _filter = 'All';
  List<GameEntry> _games = const [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    final firebaseGames = await FirebaseService().loadGamesFromCloud(
      FirebaseService().currentUserId,
    );
    final games = firebaseGames.isNotEmpty
        ? firebaseGames
        : await _storage.loadGames();

    if (mounted) {
      setState(() {
        _games = games;
      });
    }
  }

  Future<void> _deleteGame(GameEntry game) async {
    final updated = List<GameEntry>.from(_games)
      ..removeWhere((item) => item.id == game.id);
    await _storage.saveGames(updated);
    _loadGames();
  }

  List<GameEntry> get _filteredGames {
    final query = _searchController.text.trim().toLowerCase();

    return _games.where((game) {
      final matchesQuery =
          query.isEmpty || game.title.toLowerCase().contains(query);
      final matchesFilter = _filter == 'All' || game.status == _filter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = _filteredGames;

    return Scaffold(
      appBar: AppBar(title: const Text('Game library')),
      body: RefreshIndicator(
        onRefresh: _loadGames,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search games',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'All', label: Text('All')),
                  ButtonSegment(value: 'Played', label: Text('Played')),
                  ButtonSegment(
                    value: 'In Progress',
                    label: Text('In Progress'),
                  ),
                  ButtonSegment(value: 'Completed', label: Text('Completed')),
                ],
                selected: {_filter},
                onSelectionChanged: (value) {
                  setState(() => _filter = value.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredGames.isEmpty
                  ? const Center(child: Text('No games match your search.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredGames.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final game = filteredGames[index];
                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GameDetailPage(game: game),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.withValues(
                                alpha: 0.12,
                              ),
                              child: const Icon(
                                Icons.videogame_asset_rounded,
                                color: Colors.deepPurple,
                              ),
                            ),
                            title: Text(game.title),
                            subtitle: Text(
                              '${game.status} • ${game.progress}% complete',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(game.rating.toStringAsFixed(1)),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddGamePage(game: game),
                                        ),
                                      );
                                      _loadGames();
                                    } else if (value == 'delete') {
                                      await _deleteGame(game);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddGamePage()));
          _loadGames();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
