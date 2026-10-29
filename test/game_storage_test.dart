import 'package:flutter_test/flutter_test.dart';
import 'package:gamelog/game_model.dart';
import 'package:gamelog/game_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('game storage saves and loads entries persistently', () async {
    final storage = GameStorage();
    await storage.clear();

    final games = [
      GameEntry(
        id: '1',
        title: 'Elden Ring',
        status: 'Completed',
        progress: 100,
        rating: 4.9,
      ),
      GameEntry(
        id: '2',
        title: 'Hades',
        status: 'In Progress',
        progress: 64,
        rating: 4.8,
      ),
    ];

    await storage.saveGames(games);
    final loaded = await storage.loadGames();

    expect(loaded.length, 2);
    expect(loaded.first.title, 'Elden Ring');
    expect(loaded.last.progress, 64);
  });
}
