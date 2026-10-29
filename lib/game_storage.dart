import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_model.dart';

class GameStorage {
  static const String _key = 'gamelog_games';

  Future<void> saveGames(List<GameEntry> games) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(games.map((game) => game.toJson()).toList());
    await prefs.setString(_key, data);
  }

  Future<List<GameEntry>> loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => GameEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
