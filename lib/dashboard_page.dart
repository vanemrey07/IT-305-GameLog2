import 'package:flutter/material.dart';
import 'package:gamelog/add_game_page.dart';
import 'package:gamelog/firebase_service.dart';
import 'package:gamelog/game_detail_page.dart';
import 'package:gamelog/game_library_page.dart';
import 'package:gamelog/game_model.dart';
import 'package:gamelog/game_storage.dart';
import 'package:gamelog/login_page.dart';
import 'package:gamelog/product_catalog_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _storage = GameStorage();
  List<GameEntry> _games = const [];

  @override
  void initState() {
    super.initState();
    _loadGames();
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

  @override
  Widget build(BuildContext context) {
    final playedCount = _games.length;
    final completedCount = _games.where((g) => g.status == 'Completed').length;
    final inProgressCount = _games
        .where((g) => g.status == 'In Progress')
        .length;
    final averageRating = _games.isEmpty
        ? 0.0
        : _games.map((g) => g.rating).reduce((a, b) => a + b) / _games.length;

    final recentGames = _games.length > 3 ? _games.take(3).toList() : _games;

    final stats = [
      _StatCard(
        title: 'Played',
        value: playedCount.toString(),
        color: Colors.deepPurple,
      ),
      _StatCard(
        title: 'In Progress',
        value: inProgressCount.toString(),
        color: Colors.orange,
      ),
      _StatCard(
        title: 'Completed',
        value: completedCount.toString(),
        color: Colors.green,
      ),
      _StatCard(
        title: 'Avg. Rating',
        value: averageRating.toStringAsFixed(1),
        color: Colors.blue,
      ),
    ];

    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: 0,
        onDestinationSelected: (index) async {
          Navigator.of(context).pop();

          if (index == 1) {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GameLibraryPage()));
            if (!mounted) return;
            _loadGames();
          } else if (index == 2) {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductCatalogPage()),
            );
          } else if (index == 3) {
            await FirebaseService().signOut();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 16, 12),
            child: Text(
              'GAMELOG',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: Text('Game library'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: Text('Products & services'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.logout_outlined),
            label: Text('Sign out'),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              _loadGames();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Your gaming snapshot',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: stats,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently played',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GameLibraryPage(),
                      ),
                    );
                    _loadGames();
                  },
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentGames.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No games tracked yet. Add your first game.'),
                ),
              )
            else
              ...recentGames.map(
                (game) => Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameDetailPage(game: game),
                        ),
                      );
                    },
                    title: Text(game.title),
                    subtitle: Text(
                      '${game.status} • ${game.progress}% complete',
                    ),
                    trailing: Text(game.rating.toStringAsFixed(1)),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddGamePage()));
          _loadGames();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add game'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
